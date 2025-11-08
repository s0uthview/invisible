module Invisible
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        copy_file "invisible.rb", "config/initializers/invisible.rb"
      end

      def create_javascript
        copy_file "invisible.js", "app/javascript/invisible.js"
      end
    end
  end
end
