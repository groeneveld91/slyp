require File.expand_path("../boot", __FILE__)
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
Bundler.require(*Rails.groups)
module SlypApp
  class Application < Rails::Application
    config.i18n.enforce_available_locales = true
    config.quiet_assets = true
    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end
    config.action_controller.action_on_unpermitted_parameters = :log
    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :delayed_job
    config.assets.paths << Rails.root.join("vendor",
                                           "assets",
                                           "bower_components"
                                          )
    config.assets.paths << Rails.root.join("vendor",
                                           "assets",
                                           "bower_components",
                                           "semantic-ui", "dist"
                                          )
    config.autoload_paths += %W(#{config.root}/lib)

    config.middleware.insert_before(Rack::Runtime, Rack::ReverseProxy) do
      reverse_proxy_options preserve_host: true
      reverse_proxy(%r{^/$}, "https://slypio.wordpress.com/") # Landing page
      reverse_proxy(%r{^/terms$}, "https://slypio.wordpress.com/") # Terms
      reverse_proxy(%r{^/privacy$}, "https://slypio.wordpress.com/") # Privacy
    end
  end
end
