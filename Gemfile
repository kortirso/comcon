source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.3'

# Use postgresql as the database for Active Record
gem 'pg', '0.21'

# Use Puma as the app server
gem 'puma', '3.7'

# Use Slim as the templating engine. Better than ERB
gem 'slim'

# Code analyzation
gem 'rubocop', '~> 0.57.2', require: false

# Different
gem 'therubyracer', platforms: :ruby

# Background Jobs
gem 'sidekiq', '5.2.5'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'foreman', '0.84.0'
gem 'webpacker', '4.0.7'
gem 'webpacker-react', '0.3.2'

# Model Serializers
gem 'active_model_serializers', '~> 0.10.0'
gem 'oj'
gem 'oj_mimic_json'

# Form objects
gem 'virtus'

# Separate business logic
gem 'interactor'

# User auth
gem 'devise'

# secrets
gem 'figaro'

group :development, :test do
  gem 'parallel_tests'
end

group :development do
  gem 'listen', '~> 3.1.5'
  gem 'rb-readline'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'json_spec'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end
