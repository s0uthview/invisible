require "spec_helper"

RSpec.describe "bot protection integration", type: :controller do
  controller(ActionController::Base) do
    include Invisible::ControllerConcern

    protect_from_bots

    def create
      render plain: "created", status: :ok
    end
  end

  before do
    Invisible.config.on_fail = :render_422
    Invisible.config.honeypot_name = "website"
    Invisible.config.min_time = 2.0
    Invisible.config.token_timeout = 300.0

    routes.draw do
      post "/create", to: "anonymous#create"
    end
  end

  it "allows legitimate form submissions" do
    post :create, params: {
      website: "",
      _invisible_start: (Time.now.to_f - 3.0).to_s,
      _invisible_token: (Time.now.to_f - 10.0).to_s
    }
    expect(response).to have_http_status(:ok)
  end

  it "blocks honeypot filled submissions" do
    post :create, params: {
      website: "spam",
      _invisible_start: (Time.now.to_f - 3.0).to_s,
      _invisible_token: (Time.now.to_f - 10.0).to_s
    }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "blocks fast submissions" do
    post :create, params: {
      website: "",
      _invisible_start: (Time.now.to_f - 0.5).to_s,
      _invisible_token: (Time.now.to_f - 10.0).to_s
    }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "blocks submissions with invalid token" do
    post :create, params: {
      website: "",
      _invisible_start: (Time.now.to_f - 3.0).to_s,
      _invisible_token: (Time.now.to_f - 400.0).to_s
    }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
