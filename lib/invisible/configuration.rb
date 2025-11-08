module Invisible
  class Configuration
    attr_accessor :honeypot_name, :min_time, :token_timeout, :token_param,
                  :start_time_param, :on_fail

    def initialize
      @honeypot_name = "website"
      @min_time = 2.0
      @token_timeout = 300.0
      @token_param = "_invisible_token"
      @start_time_param = "_invisible_start"
      @on_fail = :render_422
    end
  end
end
