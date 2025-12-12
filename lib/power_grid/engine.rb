require "rails/all"
require "rails/engine"
require "turbo-rails"

module PowerGrid
  class Engine < ::Rails::Engine
    isolate_namespace PowerGrid

    initializer "power_grid.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("app/components")
      end
    end

    # Removed importmap auto-configuration to prevent "Is a directory" errors.
    # Users can pin the controller manually if needed.
  end
end
