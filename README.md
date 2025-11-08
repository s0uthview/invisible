# invisible

![CI](https://github.com/s0uthview/invisible/actions/workflows/ci.yml/badge.svg)

a rails plugin that blocks bots without showing any captchas.

## features

invisible uses three lightweight strategies to detect bots silently:

- **honeypot field** - adds a hidden input that must stay empty
- **time-based** - rejects forms submitted too fast
- **behavior token** - adds a hidden token updated by javascript when users type or focus fields

## installation

add to your gemfile:

```ruby
gem "invisible"
```

then run:

```bash
bundle install
rails generate invisible:install
```

this creates:
- `config/initializers/invisible.rb` - configuration file
- `app/javascript/invisible.js` - behavior token updater

## usage

### in controllers

use the `protect_from_bots` macro to enable detection:

```ruby
class ContactController < ApplicationController
  protect_from_bots

  def create
    # your action code
  end
end
```

### in views

use `form_with_invisible` instead of `form_with`:

```erb
<%= form_with_invisible model: @contact, local: true do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :email %>
  <%= f.submit "send" %>
<% end %>
```

the helper automatically injects:
- a hidden honeypot field
- a start time field
- a behavior token field
- javascript to update the token on user interaction

### configuration

configure in `config/initializers/invisible.rb`:

```ruby
Invisible.setup do |config|
  # honeypot field name (default: "website")
  config.honeypot_name = "website"

  # minimum time in seconds before form can be submitted (default: 2.0)
  config.min_time = 2.0

  # behavior token timeout in seconds (default: 300.0)
  config.token_timeout = 300.0

  # custom handler when bot is detected (default: :render_422)
  # options: :render_422, a proc, or a symbol method name
  config.on_fail = :render_422
end
```

### custom bot handler

you can customize what happens when a bot is detected:

```ruby
Invisible.setup do |config|
  # use a proc
  config.on_fail = proc { |controller|
    controller.redirect_to root_path, alert: "bot detected"
  }

  # or a controller method
  config.on_fail = :handle_bot
end

class ApplicationController < ActionController::Base
  private

  def handle_bot
    # your custom logic
  end
end
```

## how it works

1. **honeypot**: bots often fill all fields, including hidden ones. if the honeypot field has a value, it's a bot.

2. **time-based**: legitimate users take time to fill forms. if a form is submitted faster than `min_time`, it's likely a bot.

3. **behavior token**: the token is updated by javascript when users interact with the page. if the token is missing or too old, it's a bot.

all three strategies work together - if any one detects a bot, the request is blocked.

## testing

run the test suite:

```bash
bundle exec rspec
```

## development

after checking out the repo, run:

```bash
bundle install
cd test/dummy
rails db:create db:migrate
cd ../..
bundle exec rspec
```

## license

the gem is available as open source under the terms of the [mit license](https://opensource.org/licenses/mit).
