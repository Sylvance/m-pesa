# frozen_string_literal: true

require_relative "lib/mobile/pesa/version"

Gem::Specification.new do |spec|
  spec.name          = "mobile-pesa"
  spec.version       = Mobile::Pesa::VERSION
  spec.authors       = ["Sylvance"]
  spec.email         = ["9350722+Sylvance@users.noreply.github.com"]

  spec.summary       = "Mpesa gem."
  spec.description   = "This gem helps you carry out operations for Mpesa the easy way."
  spec.homepage      = "https://github.com/Sylvance/mobile-pesa"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Sylvance/mobile-pesa"
  spec.metadata["changelog_uri"] = "https://github.com/Sylvance/mobile-pesa/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "colorize"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
