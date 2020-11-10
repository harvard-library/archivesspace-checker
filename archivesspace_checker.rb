set :root, File.dirname(__FILE__)

# EadChecker is a Sinatra App
class ArchivesspaceChecker < Sinatra::Base

  # site-specific configuration
  CONFIG = if File.exists?(File.join('config', 'config.yml'))
               YAML.safe_load(IO.read(File.join('config', 'config.yml'))) || {}
             else
               {}
             end

  register Sinatra::Partial

  set :haml, :format => :html5

  # Output options
  OUTPUT_OPTS = {
    'xml' => {name: 'xml', value: 'xml', mime: 'application/xml', :checked => "checked"},
    'csv' => {name: 'csv', value: 'csv', mime: 'text/csv'}
  }

  # Processor configuration
  # ========================
  Saxon::Processor.default.config[:line_numbering] = true

  # Disable a bunch of stuff in parser to prevent XXE vulnerabilities
  parser_options = Saxon::Processor.default.to_java.getUnderlyingConfiguration.parseOptions
  # TODO: figure out how to allow EADs with doctype declaration without weakening security? (AS-56)
  # parser_options.add_parser_feature("http://apache.org/xml/features/disallow-doctype-decl", true)
  parser_options.add_parser_feature("http://xml.org/sax/features/external-general-entities", false)
  parser_options.add_parser_feature("http://xml.org/sax/features/external-parameter-entities", false)



  # The schematron used by the application to check XML
  SCHEMATRON = IO.read(CONFIG['schematron'] ||
                       File.join('schematron', 'archivesspace_checker_sch.xml'))

  # A tagged string class, used to attach phase information to the rule descriptions
  #
  # Delegates most functionality to String
  class RuleKeyStr < Delegator
    attr_writer :manual

    # @param [String] obj internal string instance to delegate to
    def initialize(obj)
      super
      @str = obj
      @manual = nil
    end

    # Requires manual intervention to fix this error?
    def manual?
      @manual
    end

    # @!visibility private
    def __getobj__
      @str
    end

    # @!visibility private
    def __setobj__(obj)
      @str = obj
    end
  end

  class Runner
    def initialize(schematron)
      # Default Schematronium instance used for checking files
      @checker = Schematronium.new(schematron)
    end

    # Runs schematron over a particular file
    #
    # @param [File] f a file to check
    def check_file(f)
      s_xml = Saxon.XML(f)
      xml = @checker.check(s_xml.to_s)
      xml.remove_namespaces!
      xml = xml.xpath("//failed-assert") + xml.xpath("//successful-report")
      xml.each do |el|
        el["line-number"] = s_xml.xpath(el.attr("location")).get_line_number
      end
      xml
    end
  end

  stron_xml = Nokogiri::XML(SCHEMATRON).remove_namespaces!

  # Representation of Schematronium structure used for generating help
  STRON_REP = stron_xml.xpath('//rule').reduce({}) do |result, rule|
    key = RuleKeyStr.new(rule.xpath('./comment()').text.strip)
    key.manual = rule.ancestors('pattern').first['id'].match(/-manual\Z/)
    result[key] = rule.xpath('./assert').map(&:text).map(&:strip)
    result
  end.sort_by {|k,v| k}.to_h

  # @!group Helper Methods

  # Stream XML as generated to out
  #
  # @param [Nokogiri::XML::NodeSet] xml results from schematron processing
  # @param [String] orig_name name of EAD as uploaded
  # @param [IO] out stream to write output to
  # @return [nil]
  def xml_output(xml, orig_name, out)
    counts = xml.group_by {|el| el.element_children.first.text.strip.gsub(/\s+/, ' ')}.map {|k,v| [k,v.count]}.to_h

    out << "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
    out << "<file file_name='#{orig_name}' total_errors='#{xml.count}'>\n"
    out << "<error_counts>\n"
    counts.each do |k,v|
      out << "<message count='#{v}'>#{k}</message>\n"
    end
    out << "</error_counts>\n"
    out << "<errors>\n"
    xml.each do |n|
      out << n.to_xml
    end
    out << "</errors>\n"
    out << "</file>"

    nil # Return value is not for use
  end

  # Produce CSV output method
  # @param [Nokogiri::XML::NodeSet] xml results from schematron processing
  # @param [String] orig_name name of EAD as uploaded
  # @param [IO] out stream to write output to
  # @return [nil]
  def csv_output(xml, orig_name, out)
    opts = {encoding: 'utf-8'}
    out << CSV.generate_line( %w|filename type location line-number message|, opts)

    xml.each do |el|
      out << CSV.generate_line( [orig_name,
                                 el.name,
                                 el['location'],
                                 el['line-number'],
                                 el.xpath('.//text').first.content.strip], opts)
    end
    return nil
  end

  # @!endgroup

  # @!group Routes

  # Index route, entry point. This is the tool's UI
  get "/" do
    haml :index
  end

  # Form submissions post to this route, the response is information on errors
  #   in XML or CSV
  #
  # Output is streamed, due to issues with using Nokogiri to build large XML response sets.
  #
  # @see #xml_output
  # @see #csv_output
  post "/result.:filetype" do
    up = params['eadFile']

    # If Saxon throws, set headers and just return the response
    begin
      result_of_check = Runner.new(SCHEMATRON).check_file(up[:tempfile])
    rescue Java::NetSfSaxonS9api::SaxonApiException => e
      headers "Content-Type" => "#{OUTPUT_OPTS['xml'][:mime]}; charset=utf8"
      return <<-ERROR.lines.map(&:lstrip).join
        <?xml version="1.0" encoding="UTF-8"?>
        <fatal-error>
          Possible causes include parse error, DOCTYPE declaration, or entity expansion in the EAD file you're checking. DOCTYPE declarations and entity resolution are disallowed for security reasons.

          Original error message:

          #{ e.message.split(/;/).map(&:strip).last(3).join("\n") }
        </fatal-error>
      ERROR
    end
    # Stream because otherwise large XML output will blow up the heap
    headers "Content-Type" => "#{OUTPUT_OPTS[params[:filetype]][:mime]}; charset=utf8"
    stream do |out|
      case params[:filetype]
      when 'xml'
        xml_output(result_of_check,
                   up[:filename],
                   out)
      when 'csv'
        csv_output(result_of_check,
                   up[:filename],
                   out)
      end
    end
  end

  # Help page which lists errors that the tool can check for
  get "/possible-errors" do
    haml :possible_errors
  end

  # The schematron file
  get "/schematron.xml" do
    headers "Content-Type" => "application/xml; charset=utf8"
    SCHEMATRON
  end

  # @!endgroup
end
