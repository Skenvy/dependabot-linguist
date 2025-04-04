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
  # https://github.com/dependabot/dependabot-core/blob/v0.303.0/common/dependabot-common.gemspec#L23-L24
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

  spec.add_dependency "rugged", "1.9.0"
  spec.add_dependency "github-linguist", "9.0.0"
  # All ecosystem gems from https://rubygems.org/profiles/dependabot can be
  # required via https://rubygems.org/gems/dependabot-omnibus/versions/0.303.0
  # which will include all dependencies of omnibus (16 ecosystems and common).
  # https://github.com/dependabot/dependabot-core/blob/v0.303.0/omnibus/dependabot-omnibus.gemspec#L29-L52
  spec.add_dependency "dependabot-omnibus", "0.303.0"
  # We can't update from this json version without getting some weird
  # uninitialized constant Dependabot::FileFetchers::Base::OpenStruct
  # ~= https://github.com/ruby/json/compare/v2.7.1...v2.7.2 but idk
  # But also dependabot-* >= 0.238.0 introduce requiring json < 2.7
  spec.add_dependency "json", "2.6.3"
  # stringio (>= 0) leads to ambiguous spec so lock it too.
  spec.add_dependency "stringio", "3.1.5"

  spec.add_development_dependency "aruba", "~> 2.3"
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rdoc", "~> 6.12"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.73"
end
