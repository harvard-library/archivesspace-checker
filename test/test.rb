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

  def test_post_csv
    post '/result.csv', "eadFile" => Rack::Test::UploadedFile.new('test/data/ajp00004.xml', 'text/xml'), 'phase' => "'#ALL'"
    assert last_request.env["CONTENT_TYPE"].include?("multipart/form-data"), "didn't set multipart/form-data"
    tmpfile = last_request.POST["eadFile"][:tempfile]
    assert tmpfile.is_a?(::Tempfile), "no tempfile"
    assert last_response.ok?, "Response not ok"
    assert last_response.body.index('filename,total_errors'), 'CSV output is wrong'
  end

  def test_refuses_doctype
    post '/result.xml', "eadFile" => Rack::Test::UploadedFile.new('test/data/doctype.xml', 'text/xml'), 'phase' => "'#ALL'"
    assert last_response.ok?, 'Response not ok'
    assert last_response.body.index('fatal-error'), 'XML with DOCTYPE declaration must return error'
  end
end
