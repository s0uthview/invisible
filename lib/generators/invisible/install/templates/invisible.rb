Invisible.setup do |config|
  # honeypot field name (default: "website")
  # config.honeypot_name = "website"

  # minimum time in seconds before form can be submitted (default: 2.0)
  # config.min_time = 2.0

  # behavior token timeout in seconds (default: 300.0)
  # config.token_timeout = 300.0

  # custom handler when bot is detected (default: :render_422)
  # options: :render_422, a proc, or a symbol method name
  # config.on_fail = :render_422
end
