module Invisible
  class Detector
    attr_reader :request, :params, :config

    def initialize(request, params, config)
      @request = request
      @params = params
      @config = config
    end

    def bot?
      honeypot_filled? || submitted_too_fast? || invalid_behavior_token?
    end

    private

    def honeypot_filled?
      honeypot_value = params[config.honeypot_name]
      honeypot_value.present? && honeypot_value != ""
    end

    def submitted_too_fast?
      return false unless config.min_time

      start_time = params[config.start_time_param]
      return false unless start_time

      elapsed = Time.now.to_f - start_time.to_f
      elapsed < config.min_time
    end

    def invalid_behavior_token?
      return false unless config.token_timeout

      token = params[config.token_param]
      return true unless token

      token_time = token.to_f
      current_time = Time.now.to_f
      age = current_time - token_time

      age > config.token_timeout || age < 0
    end
  end
end
