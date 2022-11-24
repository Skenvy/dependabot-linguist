# frozen_string_literal: true

# Provides the contexts for which "linguist languages" map to which dependabot
# managers, and the reasons why the mapping has been added. Some are more
# intuitively obvious and accurate, like "Git Config" mapping to git submodules.
# But some are limited to generic languages that cast a wide net, like JSON,
# YAML, and TOML. The only manager that isn't mapped to, is "GitHub Actions",
# as it's source directory is not the directory it is valid to "fetch" from.

# For a list of "linguist languages", see
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist/languages.yml

require_relative "manager_ecosystem_maps"

# rubocop:disable Metrics/ModuleLength

module Dependabot
  module Linguist # rubocop:disable Style/Documentation
    # ContextRule are the impetus for a certain language
    # pointing to a given package manager.
    module ContextRule
      # FETCH_FILES implies the suggestion that a language should be relevant
      # is derived from inspecting the rules the file fetcher class actually
      # uses itself to determine if it can "fetch files" for a directory.
      # Possibly also based on the `def self.required_files_message` message.
      FETCH_FILES = "def fetch_files"
      # PRIMARY_LANGUAGES implies that the language should be the main or only
      # languages that that package manager could be used for, and the presence
      # of that language should likely necessitate the presence of versioning.
      PRIMARY_LANGUAGES = "primary languages"
      # RELEVANT_LANGUAGES are satellites to the PRIMARY_LANGUAGES. They are
      # other languages that are commonly built with this package manager.
      RELEVANT_LANGUAGES = "relevant languages"
    end

    # Now apply the list of context rules to add `PackageManagers::`'s to
    # the LANGUAGE_TO_PACKAGE_MANAGER map.
    CONTEXT_RULES = {
      PackageManagers::BUNDLER => {},
      PackageManagers::CARGO => {},
      PackageManagers::COMPOSER => {},
      PackageManagers::DOCKER => {},
      PackageManagers::HEX => {},
      PackageManagers::ELM_PACKAGE => {},
      PackageManagers::GIT_SUBMODULE => {},
      PackageManagers::GITHUB_ACTIONS => {},
      PackageManagers::GO_MODULES => {},
      PackageManagers::GRADLE => {},
      PackageManagers::MAVEN => {},
      PackageManagers::NPM => {},
      PackageManagers::NUGET => {},
      PackageManagers::PIP => {},
      PackageManagers::PIPENV => {},
      PackageManagers::PIP_COMPILE => {},
      PackageManagers::POETRY => {},
      PackageManagers::PUB => {},
      PackageManagers::TERRAFORM => {},
      PackageManagers::YARN => {}
  }.freeze # rubocop:disable Layout/FirstHashElementIndentation

    ##
    CONTEXT_RULES[PackageManagers::BUNDLER][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/bundler/lib/dependabot/bundler/file_fetcher.rb#L22-L24
      "Gemfile.lock", # Gemfile.lock
      "Ruby" # Gemfile or .gemspec
    ]
    CONTEXT_RULES[PackageManagers::BUNDLER][ContextRule::PRIMARY_LANGUAGES] = ["Ruby"]
    CONTEXT_RULES[PackageManagers::BUNDLER][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::CARGO][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/cargo/lib/dependabot/cargo/file_fetcher.rb#L19-L21
      "TOML" # Cargo.toml and Cargo.lock
    ]
    CONTEXT_RULES[PackageManagers::CARGO][ContextRule::PRIMARY_LANGUAGES] = ["Rust"]
    CONTEXT_RULES[PackageManagers::CARGO][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::COMPOSER][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/composer/lib/dependabot/composer/file_fetcher.rb#L16-L18
      "JSON" # composer.json and composer.lock
    ]
    CONTEXT_RULES[PackageManagers::COMPOSER][ContextRule::PRIMARY_LANGUAGES] = ["PHP"]
    CONTEXT_RULES[PackageManagers::COMPOSER][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::DOCKER][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/docker/lib/dependabot/docker/file_fetcher.rb#L17-L19
      "Dockerfile", # Dockerfile
      "YAML" # .yaml, if kubernetes option is set
    ]
    CONTEXT_RULES[PackageManagers::DOCKER][ContextRule::PRIMARY_LANGUAGES] = []
    CONTEXT_RULES[PackageManagers::DOCKER][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::HEX][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/hex/lib/dependabot/hex/file_fetcher.rb#L20-L22
      "Elixir" # mix.lock and mix.exs by extension
    ]
    CONTEXT_RULES[PackageManagers::HEX][ContextRule::PRIMARY_LANGUAGES] = ["Elixir"]
    CONTEXT_RULES[PackageManagers::HEX][ContextRule::RELEVANT_LANGUAGES] = ["Erlang"]

    ##
    CONTEXT_RULES[PackageManagers::ELM_PACKAGE][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/elm/lib/dependabot/elm/file_fetcher.rb#L13-L15
      "JSON" # elm-package.json or an elm.json, only seeks via .json extension though.
    ]
    CONTEXT_RULES[PackageManagers::ELM_PACKAGE][ContextRule::PRIMARY_LANGUAGES] = ["Elm"]
    CONTEXT_RULES[PackageManagers::ELM_PACKAGE][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::GIT_SUBMODULE][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L15-L17
      "Git Config" # ".gitmodules"
    ]
    CONTEXT_RULES[PackageManagers::GIT_SUBMODULE][ContextRule::PRIMARY_LANGUAGES] = []
    CONTEXT_RULES[PackageManagers::GIT_SUBMODULE][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::GITHUB_ACTIONS][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/github_actions/lib/dependabot/github_actions/file_fetcher.rb#L15-L17
      # "YAML", but this is handled without linguist
    ]
    CONTEXT_RULES[PackageManagers::GITHUB_ACTIONS][ContextRule::PRIMARY_LANGUAGES] = []
    CONTEXT_RULES[PackageManagers::GITHUB_ACTIONS][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::GO_MODULES][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/go_modules/lib/dependabot/go_modules/file_fetcher.rb#L13-L15
      "Go Checksums", # go.sum
      "Go Module" # go.mod
    ]
    CONTEXT_RULES[PackageManagers::GO_MODULES][ContextRule::PRIMARY_LANGUAGES] = ["Go"]
    CONTEXT_RULES[PackageManagers::GO_MODULES][ContextRule::RELEVANT_LANGUAGES] = []

    CONTEXT_RULES[PackageManagers::GRADLE][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/gradle/lib/dependabot/gradle/file_fetcher.rb#L23-L25
      "Gradle", # for any `.gradle` file
      "Kotlin" # for any `.kts` file"
    ]
    CONTEXT_RULES[PackageManagers::GRADLE][ContextRule::PRIMARY_LANGUAGES] = []
    CONTEXT_RULES[PackageManagers::GRADLE][ContextRule::RELEVANT_LANGUAGES] = [
      "Clojure", "Groovy", "Java", "Kotlin", "Scala"
    ]

    CONTEXT_RULES[PackageManagers::MAVEN][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/maven/lib/dependabot/maven/file_fetcher.rb#L17-L19
      "Maven POM" # for `pom.xml` files
    ]
    CONTEXT_RULES[PackageManagers::MAVEN][ContextRule::PRIMARY_LANGUAGES] = []
    CONTEXT_RULES[PackageManagers::MAVEN][ContextRule::RELEVANT_LANGUAGES] = [
      "Clojure", "Groovy", "Java", "Kotlin", "Scala"
    ]

    ##
    CONTEXT_RULES[PackageManagers::NPM][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/npm_and_yarn/lib/dependabot/npm_and_yarn/file_fetcher.rb#L36-L51
      "JSON", # "package.json" or "package-lock.json" or "npm-shrinkwrap.json" but only by extension
      "NPM Config" # ".npmrc"
    ]
    CONTEXT_RULES[PackageManagers::NPM][ContextRule::PRIMARY_LANGUAGES] = ["JavaScript", "TypeScript"]
    CONTEXT_RULES[PackageManagers::NPM][ContextRule::RELEVANT_LANGUAGES] = ["CoffeeScript"]

    ##
    CONTEXT_RULES[PackageManagers::NUGET][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/nuget/lib/dependabot/nuget/file_fetcher.rb#L20-L22
      "XML" # .csproj, .vbproj and .fsproj
      # Nothing looks for a packages.config
    ]
    CONTEXT_RULES[PackageManagers::NUGET][ContextRule::PRIMARY_LANGUAGES] = ["C#"]
    CONTEXT_RULES[PackageManagers::NUGET][ContextRule::RELEVANT_LANGUAGES] = ["ASP.NET", "C++", "F#", "Objective-C++", "Visual Basic .NET"]

    ##
    CONTEXT_RULES[PackageManagers::PIP][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/python/lib/dependabot/python/file_fetcher.rb#L35-L38
      # Besides the other pip related package managers, there is no language for `requirements` files. RIP.
      "Text" # for `.txt`
    ]
    CONTEXT_RULES[PackageManagers::PIP][ContextRule::PRIMARY_LANGUAGES] = ["Python"]
    CONTEXT_RULES[PackageManagers::PIP][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::PIPENV][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/python/lib/dependabot/python/file_fetcher.rb#L35-L38
      "JSON", # Pipfile.lock
      "TOML" # Pipfile
    ]
    CONTEXT_RULES[PackageManagers::PIPENV][ContextRule::PRIMARY_LANGUAGES] = ["Python"]
    CONTEXT_RULES[PackageManagers::PIPENV][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::PIP_COMPILE][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/python/lib/dependabot/python/file_fetcher.rb#L35-L38
      # Already captured by the other pip related package manager paths
    ]
    CONTEXT_RULES[PackageManagers::PIP_COMPILE][ContextRule::PRIMARY_LANGUAGES] = ["Python"]
    CONTEXT_RULES[PackageManagers::PIP_COMPILE][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::POETRY][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/python/lib/dependabot/python/file_fetcher.rb#L35-L38
      # pyproject.lock has none and setup.py is vague.
      "TOML" # poetry.lock and pyproject.toml by extension
    ]
    CONTEXT_RULES[PackageManagers::POETRY][ContextRule::PRIMARY_LANGUAGES] = ["Python"]
    CONTEXT_RULES[PackageManagers::POETRY][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::PUB][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/pub/lib/dependabot/pub/file_fetcher.rb#L15-L17
      "YAML" # pubspec.yaml, but only by extension.
    ]
    CONTEXT_RULES[PackageManagers::PUB][ContextRule::PRIMARY_LANGUAGES] = ["Dart"]
    CONTEXT_RULES[PackageManagers::PUB][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::TERRAFORM][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/terraform/lib/dependabot/terraform/file_fetcher.rb#L19-L21
      "HCL" # .tf and .hcl
    ]
    CONTEXT_RULES[PackageManagers::TERRAFORM][ContextRule::PRIMARY_LANGUAGES] = []
    CONTEXT_RULES[PackageManagers::TERRAFORM][ContextRule::RELEVANT_LANGUAGES] = []

    ##
    CONTEXT_RULES[PackageManagers::YARN][ContextRule::FETCH_FILES] = [
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/npm_and_yarn/lib/dependabot/npm_and_yarn/file_fetcher.rb#L36-L51
      "YAML" # yarn.lock
    ]
    CONTEXT_RULES[PackageManagers::YARN][ContextRule::PRIMARY_LANGUAGES] = ["JavaScript", "TypeScript"]
    CONTEXT_RULES[PackageManagers::YARN][ContextRule::RELEVANT_LANGUAGES] = ["CoffeeScript"]
  end
end

# rubocop:enable Metrics/ModuleLength
