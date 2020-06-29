require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you"ve limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DnEDocument
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.time_zone = Settings.time_zone
    config.active_job.queue_adapter = :sidekiq
    config.active_storage.queue = :low_priority
    I18n.available_locales = [:vi, :en]
    I18n.default_locale = :en
  end
end
