require "spec_helper"
require "invisible/detector"

RSpec.describe Invisible::Detector do
  let(:config) { Invisible::Configuration.new }
  let(:request) { double("request") }
  let(:params) { {} }

  describe "#bot?" do
    context "with honeypot strategy" do
      before do
        config.token_timeout = nil
        config.min_time = nil
      end

      it "returns false when honeypot is empty" do
        params[config.honeypot_name] = ""
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be false
      end

      it "returns true when honeypot is filled" do
        params[config.honeypot_name] = "spam"
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be true
      end
    end

    context "with time-based strategy" do
      before do
        config.min_time = 2.0
        config.token_timeout = nil
      end

      it "returns false when form submitted after min_time" do
        params[config.start_time_param] = (Time.now.to_f - 3.0).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be false
      end

      it "returns true when form submitted too fast" do
        params[config.start_time_param] = (Time.now.to_f - 0.5).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be true
      end

      it "returns false when start_time is missing" do
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be false
      end

      it "returns false when min_time is nil" do
        config.min_time = nil
        params[config.start_time_param] = (Time.now.to_f - 0.5).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be false
      end
    end

    context "with behavior token strategy" do
      before do
        config.token_timeout = 300.0
        config.min_time = nil
      end

      it "returns false when token is recent" do
        params[config.token_param] = (Time.now.to_f - 10.0).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be false
      end

      it "returns true when token is too old" do
        params[config.token_param] = (Time.now.to_f - 400.0).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be true
      end

      it "returns true when token is missing" do
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be true
      end

      it "returns false when token_timeout is nil" do
        config.token_timeout = nil
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be false
      end

      it "returns true when token is in the future" do
        params[config.token_param] = (Time.now.to_f + 100.0).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be true
      end
    end

    context "with multiple strategies" do
      it "returns true if any strategy detects a bot" do
        config.min_time = 2.0
        config.token_timeout = 300.0
        params[config.honeypot_name] = "spam"
        params[config.start_time_param] = (Time.now.to_f - 3.0).to_s
        params[config.token_param] = (Time.now.to_f - 10.0).to_s
        detector = described_class.new(request, params, config)
        expect(detector.bot?).to be true
      end
    end
  end
end
