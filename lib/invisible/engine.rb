module Invisible
  class Engine < ::Rails::Engine
    isolate_namespace Invisible

    config.to_prepare do
      ActionController::Base.include Invisible::ControllerConcern
      ActionView::Base.include Invisible::ApplicationHelper
    end
  end
end
