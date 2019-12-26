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
gem 'puma', '>= 3.12.2'

# Use Slim as the templating engine. Better than ERB
gem 'slim'

# Code analyzation
gem 'rubocop', '~> 0.57.2', require: false

# Different
gem 'therubyracer', platforms: :ruby

# Background Jobs
gem 'redis-rails'
gem 'sidekiq', '5.2.5'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'foreman', '0.84.0'
gem 'webpacker', '~> 4.x'
gem 'webpacker-react', '0.3.2'

# Model Serializers
gem 'active_model_serializers', '~> 0.10.0'
gem 'fast_jsonapi'
gem 'oj'
gem 'oj_mimic_json'

# Form objects
gem 'dry-struct', '~> 1.2.0'
gem 'dry-types', '~> 1.2.2'
gem 'dry-validation', '~> 1.4.0'
gem 'virtus'

# Separate business logic
gem 'interactor'

# User auth
gem 'devise'
gem 'jwt', '2.1.0'

# secrets
gem 'figaro'

# Authorization
gem 'action_policy', '~> 0.3.0'

# localize
gem 'route_translator'

# Friendly url
gem 'babosa'
gem 'friendly_id', '~> 5.2.4'

# API documentation
gem 'apipie-rails', '0.5.8'

# Search engine
gem 'mysql2', '~> 0.3', platform: :ruby
gem 'thinking-sphinx', '~> 4.4'

# Cron job
gem 'whenever', require: false

# Discord bot
gem 'discord_bot', '0.2.0'

# discord omniauth
gem 'omniauth-discord', git: 'https://github.com/kortirso/omniauth-discord'
gem 'omniauth-rails_csrf_protection', '~> 0.1'

# Mailer styles
gem 'premailer-rails'

# DB triggers
gem 'hairtrigger'

group :development, :test do
  gem 'bullet'
  gem 'parallel_tests'
end

group :development do
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-rvm', require: false
  gem 'letter_opener'
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
