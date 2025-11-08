require "spec_helper"

RSpec.describe "form submission integration", type: :request do
  before do
    Invisible.config.on_fail = :render_422
    Invisible.config.honeypot_name = "website"
    Invisible.config.min_time = 2.0
    Invisible.config.token_timeout = 300.0

    # define a simple controller for testing
    controller_class = Class.new(ActionController::Base) do
      include Invisible::ControllerConcern

      protect_from_bots

      def new
        # use a view template approach that has access to all helpers
        render inline: <<~ERB, type: :erb
          <%= form_with_invisible url: "/contacts", local: true do |f| %>
            <%= f.text_field :name %>
            <%= f.submit "submit" %>
          <% end %>
        ERB
      end

      def create
        render plain: "created", status: :ok
      end
    end

    stub_const("ContactsController", controller_class)

    Rails.application.routes.draw do
      get "/contacts/new", to: "contacts#new"
      post "/contacts", to: "contacts#create"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  it "renders a form with invisible protection fields" do
    get "/contacts/new"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('name="website"')
    expect(response.body).to include('name="_invisible_start"')
    expect(response.body).to include('name="_invisible_token"')
    expect(response.body).to include("updateToken")
  end

  it "allows legitimate form submissions with proper timing" do
    # simulate a user filling out the form over 3 seconds
    start_time = Time.now.to_f - 3.0
    token_time = Time.now.to_f - 1.0

    post "/contacts", params: {
      name: "test",
      website: "",
      _invisible_start: start_time.to_s,
      _invisible_token: token_time.to_s
    }

    expect(response).to have_http_status(:ok)
  end

  it "blocks submissions with filled honeypot" do
    start_time = Time.now.to_f - 3.0
    token_time = Time.now.to_f - 1.0

    post "/contacts", params: {
      name: "test",
      website: "spam",
      _invisible_start: start_time.to_s,
      _invisible_token: token_time.to_s
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "blocks submissions that are too fast" do
    start_time = Time.now.to_f - 0.5
    token_time = Time.now.to_f - 0.3

    post "/contacts", params: {
      name: "test",
      website: "",
      _invisible_start: start_time.to_s,
      _invisible_token: token_time.to_s
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "blocks submissions with missing token" do
    start_time = Time.now.to_f - 3.0

    post "/contacts", params: {
      name: "test",
      website: "",
      _invisible_start: start_time.to_s
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "blocks submissions with expired token" do
    start_time = Time.now.to_f - 3.0
    token_time = Time.now.to_f - 400.0

    post "/contacts", params: {
      name: "test",
      website: "",
      _invisible_start: start_time.to_s,
      _invisible_token: token_time.to_s
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "extracts start_time and token from rendered form" do
    get "/contacts/new"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('_invisible_start')
    expect(response.body).to include('_invisible_token')

    # extract the actual values from the rendered form using a more flexible regex
    # matches: <input ... name="_invisible_start" ... value="123.456" ...>
    start_time_match = response.body.match(/name=["']_invisible_start["'][^>]*value=["']([^"']+)["']|value=["']([^"']+)["'][^>]*name=["']_invisible_start["']/)
    token_match = response.body.match(/name=["']_invisible_token["'][^>]*value=["']([^"']+)["']|value=["']([^"']+)["'][^>]*name=["']_invisible_token["']/)

    expect(start_time_match).to be_present, "start_time field not found. Response body: #{response.body[0..1000]}"
    expect(token_match).to be_present, "token field not found. Response body: #{response.body[0..1000]}"

    start_time = (start_time_match[1] || start_time_match[2]).to_f
    token_time = (token_match[1] || token_match[2]).to_f

    expect(start_time).to be > 0
    expect(token_time).to be > 0

    # wait a bit to simulate user interaction
    sleep 2.1

    # submit with the extracted values (token should be updated by JS in real scenario)
    post "/contacts", params: {
      name: "test",
      website: "",
      _invisible_start: start_time.to_s,
      _invisible_token: (Time.now.to_f - 0.5).to_s  # updated token
    }

    expect(response).to have_http_status(:ok)
  end
end
