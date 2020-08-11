# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'carbonyte/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'carbonyte'
  spec.version     = Carbonyte::VERSION
  spec.authors     = ['iMacTia']
  spec.email       = ['giuffrida.mattia@gmail.com']
  spec.homepage    = 'https://github.com/iMacTia/carbonyte'
  spec.summary     = 'Build Microservices-oriented Architectures with ease'
  spec.description = 'Carbonyte is the core of great Microservices-oriented Architectures.'
  spec.license     = 'Copyright'
  spec.files = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']

  spec.add_dependency 'interactor-rails', '~> 2.0'
  spec.add_dependency 'jsonapi-serializer', '~> 2.0'
  spec.add_dependency 'pundit', '~> 2.1'
  spec.add_dependency 'rails', '~> 6.0.3', '>= 6.0.3.2'

  spec.add_development_dependency 'inch', '~> 0.8.0'
  spec.add_development_dependency 'rspec-rails', '~> 4.0'
end
