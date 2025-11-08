require "invisible/version"
require "invisible/configuration"
require "invisible/detector"
require "invisible/controller_concern"
require "invisible/engine"

module Invisible
  class << self
    def setup
      yield(config) if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    def config=(config)
      @config = config
    end
  end
end
