require "spec_helper"

RSpec.describe Invisible::ApplicationHelper, type: :helper do
  include Invisible::ApplicationHelper

  before do
    Invisible.config.honeypot_name = "website"
    Invisible.config.token_param = "_invisible_token"
    Invisible.config.start_time_param = "_invisible_start"
  end

  describe "#form_with_invisible" do
    it "includes honeypot field" do
      output = form_with_invisible(url: "/test") do |f|
        f.text_field :name
      end
      expect(output).to include('name="website"')
      expect(output).to include('style="position:absolute;left:-9999px;"')
    end

    it "includes start time field" do
      output = form_with_invisible(url: "/test") do |f|
        f.text_field :name
      end
      expect(output).to include('name="_invisible_start"')
    end

    it "includes behavior token field" do
      output = form_with_invisible(url: "/test") do |f|
        f.text_field :name
      end
      expect(output).to include('name="_invisible_token"')
    end

    it "includes behavior token script" do
      output = form_with_invisible(url: "/test") do |f|
        f.text_field :name
      end
      expect(output).to include("updateToken")
      expect(output).to include("keydown")
      expect(output).to include("focus")
    end
  end
end
