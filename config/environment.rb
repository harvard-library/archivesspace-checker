Bundler.require(:default, :assets)
if ENV['RACK_ENV'] == 'development'
  Bundler.require(:development)
end
Dir['./**/*.rb'].reject {|s| s.match(/\A\.\/(test|config\/deploy)/)}.map { |s| require s.sub(/\.rb\z/, '')}

