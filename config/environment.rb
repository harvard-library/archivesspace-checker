Bundler.require(:default, :assets)
Dir['./**/*.rb'].reject {|s| s.match(/\A\.\/test/)}.map { |s| require s.sub(/\.rb\z/, '')}
