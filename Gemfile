# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development do
  gem 'rspec-rails', '~> 4.0'
  gem 'simplecov', '~> 0.12'
  gem 'sqlite3', '~> 1.4'
end

group :linting do
  gem 'inch', '~> 0.8.0'
  gem 'rubocop-performance', '~> 1.5'
  gem 'rubocop-rails', '~> 2.7'
end
