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

  spec.require_paths = ["lib"]
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.add_dependency "github-linguist", "~> 7.23.0"
  # All ecosystem gems from https://rubygems.org/profiles/dependabot can be
  # required via https://rubygems.org/gems/dependabot-omnibus/versions/0.212.0
  spec.add_dependency "dependabot-omnibus", "0.212.0"
  # Which is equivalent to..
  # spec.add_dependency "dependabot-common", "0.212.0"
  # spec.add_dependency "dependabot-bundler", "0.212.0"
  # spec.add_dependency "dependabot-cargo", "0.212.0"
  # spec.add_dependency "dependabot-composer", "0.212.0"
  # spec.add_dependency "dependabot-docker", "0.212.0"
  # spec.add_dependency "dependabot-elm", "0.212.0"
  # spec.add_dependency "dependabot-github_actions", "0.212.0"
  # spec.add_dependency "dependabot-git_submodule", "0.212.0"
  # spec.add_dependency "dependabot-go_modules", "0.212.0"
  # spec.add_dependency "dependabot-gradle", "0.212.0"
  # spec.add_dependency "dependabot-hex", "0.212.0"
  # spec.add_dependency "dependabot-maven", "0.212.0"
  # spec.add_dependency "dependabot-npm_and_yarn", "0.212.0"
  # spec.add_dependency "dependabot-nuget", "0.212.0"
  # spec.add_dependency "dependabot-pub", "0.212.0"
  # spec.add_dependency "dependabot-python", "0.212.0"
  # spec.add_dependency "dependabot-terraform", "0.212.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rdoc", "~> 6.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.37"
end
