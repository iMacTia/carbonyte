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
  spec.license     = 'MIT'
  # Expose spec folder and spec/support to plugins
  spec.files = Dir['{app,config,db,lib,spec}/**/*', 'Rakefile', 'README.md']
  spec.require_paths = %w[lib spec/support]

  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.add_dependency 'interactor-rails', '~> 2.0'
  spec.add_dependency 'jsonapi-serializer', '~> 2.0'
  spec.add_dependency 'lograge', '~> 0.11'
  spec.add_dependency 'logstash-event', '~> 1.2'
  spec.add_dependency 'pundit', '~> 2.1'
  spec.add_dependency 'rails', '~> 6.0.3', '>= 6.0.3.2'
  spec.add_dependency 'request_store', '~> 1.5'
end
