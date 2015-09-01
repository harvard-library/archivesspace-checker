source 'https://rubygems.org'

gem 'haml'
gem 'puma'
gem 'rake'
gem 'sinatra-asset-pipeline', :require => 'sinatra/asset_pipeline'
gem 'sinatra-partial'
gem 'uglifier'
gem 'therubyrhino'

group :development do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'pry'
end

group 'test' do
  gem 'rack-test'
end

group :assets do
  gem 'bourbon'
  gem 'neat'
  gem 'bitters'
end

gem 'sinatra'
gem 'schematronium', platform: :jruby, git: 'https://github.com/harvard-library/schematronium.git'
gem 'saxon-xslt', '~> 0.6.0', platform: :jruby, git: 'https://github.com/harvard-library/saxon-xslt.git', ref: "dave"
gem 'nokogiri'
