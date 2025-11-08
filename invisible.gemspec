require_relative "lib/invisible/version"

Gem::Specification.new do |spec|
  spec.name        = "invisible"
  spec.version     = Invisible::VERSION
  spec.authors     = [ "s0uthview" ]
  spec.email       = [ "saoirse@foureyeddeer.com" ]
  spec.homepage    = "https://github.com/s0uthview/invisible"
  spec.summary     = "a rails plugin that blocks bots without showing captchas"
  spec.description = "invisible uses lightweight strategies (honeypot, time-based, behavior token) to detect and block bots silently"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"] +
      Dir["lib/generators/**/*"]
  end

  spec.add_dependency "rails", ">= 8.1.1"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "capybara"
end
