# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_storage/engine'

Bundler.require(*Rails.groups)

module ComCon
  # base
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    I18n.available_locales = %i[en ru]
    config.i18n.default_locale = :en

    config.active_record.schema_format = :ruby
    config.generators do |g|
      g.test_framework :rspec, fixtures: true, views: false, view_specs: false, helper_specs: false,
          routing_specs: false, controller_specs: true, request_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.stylesheets false
      g.javascripts false
      g.helper false
    end

    config.autoload_paths += %W[#{config.root}/app/jobs]
    config.active_job.queue_adapter = :sidekiq

    config.generators.system_tests = nil
    config.action_mailer.preview_path = 'spec/mailers/previews'

    # Catch 404s
    config.after_initialize do |app|
      app.routes.append { match '*path', to: 'application#catch_route_error', via: :all }
    end
  end
end
