module Invisible
  class Engine < ::Rails::Engine
    isolate_namespace Invisible

    # remove model paths since we don't use ActiveRecord
    # do this in an initializer that runs before paths are frozen
    initializer "invisible.remove_model_paths", before: :set_autoload_paths do
      if config.paths["app/models"]
        config.paths["app/models"].existent.clear
      end
    end

    config.to_prepare do
      ActionController::Base.include Invisible::ControllerConcern
      ActionView::Base.include Invisible::ApplicationHelper
    end
  end
end
