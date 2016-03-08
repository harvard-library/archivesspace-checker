require './config/environment'
Bundler.require(:test)

require 'minitest/autorun'

class ArchivesspaceChecker::Test < Minitest::Test
  include Rack::Test::Methods

  def app
    ArchivesspaceChecker
  end

  def test_index
    get '/'
    assert last_response.ok?, "Response not ok - body:\n #{last_response.body}"
  end

  def test_post
    post '/result.xml', "eadFile" => Rack::Test::UploadedFile.new('test/data/ajp00004.xml', 'text/xml'), 'phase' => "'#ALL'"
    assert last_request.env["CONTENT_TYPE"].include?("multipart/form-data"), "didn't set multipart/form-data"
    tmpfile = last_request.POST["eadFile"][:tempfile]
    assert tmpfile.is_a?(::Tempfile), "no tempfile"
    assert last_response.ok?, "Response not ok"
    assert Nokogiri.XML(last_response.body).xpath('//failed-assert'), 'XML is wrong'
  end

  def test_brobdingnagian_post
    skip('slow') if ENV['SKIP_SLOW_TESTS']
    post 'result.xml', 'eadFile' => Rack::Test::UploadedFile.new('test/data/hou01965.xml', 'text/xml'), 'phase' => "'#ALL'"
    assert last_request.env["CONTENT_TYPE"].include?("multipart/form-data"), "didn't set multipart/form-data"
    tmpfile = last_request.POST["eadFile"][:tempfile]
    assert tmpfile.is_a?(::Tempfile), "no tempfile"
    assert last_response.ok?, "Response not ok"
    assert Nokogiri.XML(last_response.body).xpath('//failed-assert'), 'XML is wrong'
  end

  def test_post_csv
    post '/result.csv', "eadFile" => Rack::Test::UploadedFile.new('test/data/ajp00004.xml', 'text/xml'), 'phase' => "'#ALL'"
    assert last_request.env["CONTENT_TYPE"].include?("multipart/form-data"), "didn't set multipart/form-data"
    tmpfile = last_request.POST["eadFile"][:tempfile]
    assert tmpfile.is_a?(::Tempfile), "no tempfile"
    assert last_response.ok?, "Response not ok"
    assert last_response.body.index('filename,total_errors'), 'CSV output is wrong'
  end

  def test_checks_errors_regardless_of_namespace
    post '/result.xml', 'eadFile' => Rack::Test::UploadedFile.new('test/data/ns_problems.xml', 'text/xml'), 'phase' => "'#ALL'"
    assert last_request.env["CONTENT_TYPE"].include?("multipart/form-data"), "didn't set multipart/form-data"
    tmpfile = last_request.POST["eadFile"][:tempfile]
    assert tmpfile.is_a?(::Tempfile), "no tempfile"
    assert last_response.ok?, "Response not ok"
    assert(Integer(Nokogiri.XML(last_response.body).xpath('//file').first['total_errors'], 10) > 0,
           'Errors should be found in this XML file')
  end

  def test_refuses_doctype
    out, err = capture_subprocess_io do
      post '/result.xml', "eadFile" => Rack::Test::UploadedFile.new('test/data/doctype.xml', 'text/xml'), 'phase' => "'#ALL'"
    end
    assert err.match(/SXXP0003/), "Did not find expected Saxon-level error in STDERR"
    assert last_response.ok?, 'Response not ok'
    assert last_response.body.index('fatal-error'), 'XML with DOCTYPE declaration must return error'
  end
end
