module Invisible
  module ApplicationHelper
    def form_with_invisible(options = {}, &block)
      options = options.dup
      html_options = options.delete(:html) || {}

      honeypot_name = Invisible.config.honeypot_name
      token_param = Invisible.config.token_param
      start_time_param = Invisible.config.start_time_param

      start_time = Time.now.to_f
      behavior_token = Time.now.to_f

      html_options[:data] ||= {}
      html_options[:data][:invisible_start] = start_time
      html_options[:data][:invisible_token] = behavior_token

      form_output = form_with(**options, html: html_options) do |form|
        if block_given?
          block.call(form)
        end
        concat hidden_field_tag(honeypot_name, "", id: nil, tabindex: -1, autocomplete: "off", style: "position:absolute;left:-9999px;")
        concat hidden_field_tag(start_time_param, start_time)
        concat hidden_field_tag(token_param, behavior_token)
      end

      form_output + invisible_behavior_script.html_safe
    end

    private

    def invisible_behavior_script
      token_param = Invisible.config.token_param
      <<~HTML
        <script>
          (function() {
            var tokenField = document.querySelector('input[name="#{token_param}"]');
            if (!tokenField) return;
        #{'    '}
            var updateToken = function() {
              tokenField.value = Date.now() / 1000;
            };
        #{'    '}
            document.addEventListener('keydown', updateToken);
            document.addEventListener('keypress', updateToken);
            document.addEventListener('focus', updateToken, true);
            document.addEventListener('click', updateToken, true);
          })();
        </script>
      HTML
    end
  end
end
