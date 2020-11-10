require './config/environment'
Bundler.require(:test)

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
  t.warning = false
end

task :default => :test

# rake analyze_eads EADS=/path/to/EADs FILE=/path/to/schematron
desc "Run ArchivesSpace Checker over a set of EADs."
task :analyze_eads do
  raise "EADS environment variable must be set to directory with input EADs" unless ENV['EADS']
  raise "Must have 'FILE' provided in ENV" unless ENV['FILE']

  puts 'Started at: ' + DateTime.now.strftime('%H:%M:%S')

  schematron = IO.read(ENV['FILE'])
  eads = File.expand_path(ENV['EADS'])

  csv_filename = "tmp/result_#{DateTime.now.strftime('%m_%d_%Y_%H%M%S')}.csv"
  CSV.open(csv_filename, 'w+') do |csv|
    csv << %w|filename type location line-number message|

    ead_n = 0  # Start ead counter
    Dir[File.join(eads, "*.xml")].sort.each do |ead|
      ead_filename = URI(ead).path.split('/').last
      puts "Checking #{ead_filename}..."

      xml = ArchivesspaceChecker::Runner.new(schematron).check_file(IO.read(ead))
      xml.each do |el|
        csv << [ead_filename,
                el.name,
                el['location'],
                el['line-number'],
                el.xpath('.//text').first.content.strip]
      end

      # Increment ead counter
      ead_n += 1
      puts "Checked #{ead_n} EADs at #{DateTime.now.strftime('%H:%M:%S')}..." if ead_n % 100 == 0
    end
  end

  puts 'Finished at: ' + DateTime.now.strftime('%H:%M:%S')
  puts "CREATED CSV >> #{csv_filename}"
end