# frozen_string_literal: true

require_relative "lib/dependabot/linguist/version"

Gem::Specification.new do |spec|
  spec.name = "dependabot-linguist"
  spec.version = Dependabot::Linguist::VERSION
  spec.licenses = ["GPL-3.0-only", "Nonstandard"]
  spec.authors = ["Nathan Levett"]
  spec.email   = ["nathan.a.z.levett@gmail.com"]
  spec.summary = "Automate generating dependabot config with linguist and dependabot-core!"
  spec.description = "Use linguist to check the contents of a repository,
  and then scan for dependabot-core ecosystems relevant to those languages!"
  spec.homepage = "https://skenvy.github.io/dependabot-linguist"
  spec.required_ruby_version = ">= 2.7.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Skenvy/dependabot-linguist/tree/main/"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
