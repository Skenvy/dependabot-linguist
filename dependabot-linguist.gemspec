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
  # https://github.com/dependabot/dependabot-core/blob/v0.217.0/common/dependabot-common.gemspec#L23-L24
  spec.required_ruby_version = ">= 3.1.0"
  spec.required_rubygems_version = ">= 3.3.7"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Skenvy/dependabot-linguist/tree/main/"
  spec.metadata["github_repo"] = "https://github.com/Skenvy/dependabot-linguist"

  spec.require_paths = ["lib"]
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features|smoke-test)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.add_dependency "rugged", "1.7.1"
  spec.add_dependency "github-linguist", "7.25.0"
  # All ecosystem gems from https://rubygems.org/profiles/dependabot can be
  # required via https://rubygems.org/gems/dependabot-omnibus/versions/0.217.0
  # which will include all dependencies of omnibus (16 ecosystems and common).
  # https://github.com/dependabot/dependabot-core/blob/v0.217.0/omnibus/dependabot-omnibus.gemspec#L29-L45
  spec.add_dependency "dependabot-omnibus", "0.236.0"

  spec.add_development_dependency "aruba", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rdoc", "~> 6.5"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.51"
end
