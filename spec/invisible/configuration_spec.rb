require "spec_helper"

RSpec.describe Invisible::Configuration do
  describe "default values" do
    let(:config) { Invisible::Configuration.new }

    it "has default honeypot_name" do
      expect(config.honeypot_name).to eq("website")
    end

    it "has default min_time" do
      expect(config.min_time).to eq(2.0)
    end

    it "has default token_timeout" do
      expect(config.token_timeout).to eq(300.0)
    end

    it "has default token_param" do
      expect(config.token_param).to eq("_invisible_token")
    end

    it "has default start_time_param" do
      expect(config.start_time_param).to eq("_invisible_start")
    end

    it "has default on_fail" do
      expect(config.on_fail).to eq(:render_422)
    end
  end

  describe "Invisible.setup" do
    it "allows configuration" do
      Invisible.setup do |config|
        config.honeypot_name = "custom_field"
        config.min_time = 5.0
      end

      expect(Invisible.config.honeypot_name).to eq("custom_field")
      expect(Invisible.config.min_time).to eq(5.0)
    end
  end
end
