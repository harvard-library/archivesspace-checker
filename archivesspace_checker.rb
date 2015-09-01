set :root, File.dirname(__FILE__)

class ArchivesspaceChecker < Sinatra::Base
  set :assets_precompile, %w(application.js application.css *.png *.jpg)
  set :assets_css_compressor, :scss
  set :assets_js_compressor, :uglifier

  register Sinatra::AssetPipeline
  register Sinatra::Partial

  set :haml, :format => :html5

  PHASE_OPTS = [
    {name: "Manual", value: "manual", checked: true},
    {name: "Automatic", value: "auto"},
    {name: "Everything", value: "all"}

  ]

  Saxon::Processor.default = Saxon::Processor.create(<<-EOF)
    <configuration xmlns="http://saxon.sf.net/ns/configuration" edition="HE">
      <global
        lineNumbering="true" />
    </configuration>
  EOF

  Checker = Schematronium.new(IO.read('schematron/descgrp.sch'))

  def check_file(f, orig_name)
    s_xml = Saxon.XML(f)
    xml = Checker.check(s_xml.to_s)
    xml.remove_namespaces!
    xml = xml.xpath("//failed-assert") + xml.xpath("//successful-report")
    xml.each do |el|
      el["line-number"] = s_xml.xpath(el.attr("location")).get_line_number
    end
    output = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
    file = output.add_child("<file file_name='#{orig_name}' total_errors='#{xml.count}'/>").first
    counts = xml.group_by {|el| el.children.map(&:text).join.strip.gsub(/\s+/, ' ')}.map {|k,v| [k,v.count]}.to_h
    err_count = file.add_child("<error_counts />").first
    counts.each do |k,v|
      err_count.add_child("<message count='#{v}'>#{k}</message>")
    end
    errs = file.add_child("<errors />").first
    errs.children = xml

    output
  end

  # Routes
  get "/" do
    haml :index
  end

  post "/" do
    headers "Content-Type" => "text/xml; charset=utf8"
    up = params['eadFile']
    return check_file(up[:tempfile], up[:filename]).to_s
  end
end
