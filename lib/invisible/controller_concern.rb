module Invisible
  module ControllerConcern
    extend ActiveSupport::Concern

    included do
      before_action :check_bot_protection, if: -> { bot_protection_enabled? }
    end

    class_methods do
      def protect_from_bots(options = {})
        @bot_protection_enabled = true
        @bot_protection_options = options
      end

      def bot_protection_enabled?
        @bot_protection_enabled == true
      end

      def bot_protection_options
        @bot_protection_options || {}
      end
    end

    private

    def bot_protection_enabled?
      self.class.bot_protection_enabled? ||
        (respond_to?(:bot_protection_enabled) && bot_protection_enabled)
    end

    def check_bot_protection
      # only check bots on state-changing requests (POST, PUT, PATCH, DELETE)
      # GET requests don't need bot protection
      return unless request.post? || request.put? || request.patch? || request.delete?

      detector = Detector.new(request, params, Invisible.config)

      if detector.bot?
        handle_bot_detection
      end
    end

    def handle_bot_detection
      handler = Invisible.config.on_fail

      case handler
      when :render_422
        head :unprocessable_entity
      when Proc
        instance_exec(&handler)
      when Symbol
        send(handler) if respond_to?(handler, true)
      end
    end
  end
end
