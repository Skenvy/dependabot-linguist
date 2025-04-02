# frozen_string_literal: true

# Provide the maps from names for "Package Managers" to "Package Ecosystems" and
# subsequently to the "file fetcher registry keys"

# For the list of package managers and which ecosystems they map to, see
# https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference#package-ecosystem-
# TODO: This project is still only using the package managers that existed in
# version 0.217.0 -- it still needs to be updated to include those added since

# For the file_fetchers' register function, whose keys we map to, see
# https://github.com/dependabot/dependabot-core/blob/v0.303.0/common/lib/dependabot/file_fetchers.rb#L21-L24

module Dependabot
  module Linguist
    # PackageManagers is the "Package Manager" list on "#package-ecosystem"
    module PackageManagers
      # Bundler; the ruby package manager.
      BUNDLER = "Bundler"
      # Cargo; the rust package manager.
      CARGO = "Cargo"
      # Composer; the PHP package manager.
      COMPOSER = "Composer"
      # Docker; the Docker package manager.
      DOCKER = "Docker"
      # Hex; the Erlang (and Elixir) package manager
      HEX = "Hex"
      # elm-package; the elm package manager.
      ELM_PACKAGE = "elm-package"
      # git submodule versioning is GitHub internal
      GIT_SUBMODULE = "git submodule"
      # GitHub Action versioning is GitHub internal.
      # GitHub Actions expects a directory input of "/",
      # and can't be found by linguist outside of "yaml".
      GITHUB_ACTIONS = "GitHub Actions"
      # Go Modules; versioning is handled via go.mod
      GO_MODULES = "Go modules"
      # Gradle; typically a replacement for maven and any java ecosystem, and
      # supports Java (as well as Kotlin, Groovy, Scala), C/C++, and JavaScript,
      # although it provides plugin capacity to extend it to other languages.
      # Notably the other common Java derivative, clojure, isn't 1st party.
      GRADLE = "Gradle"
      # Maven; typically for the java ecosystem, although has arbitrary
      # extensability via the plugin exec-maven-plugin
      MAVEN = "Maven"
      # npm; the Node package manager. Relevant to any language that could
      # be part of a Node package. Primarily JavaScript and TypeScript.
      NPM = "npm"
      # NuGet; the ".NET" (core, and framework) package manager. Also hosts
      # Xamarain packages and some C++ packages. .NET languages include F#,
      # C# (or, "MicroSoft Java") and Visual Basic. Also supports "ASP.NET".
      NUGET = "NuGet"
      # pip; the python package manager.
      PIP = "pip"
      # pipenv; a python package toolset.
      PIPENV = "pipenv"
      # pip-compile; a python package toolset.
      PIP_COMPILE = "pip-compile"
      # poetry; another python package manager.
      POETRY = "poetry"
      # pub; the package manager for dart and flutter
      PUB = "pub"
      # terraform version management is terraform internal
      TERRAFORM = "Terraform"
      # Yarn; Facebook's alternative to npm, and
      # is similarly relevant to what Node supports.
      YARN = "yarn"
    end

    # PackageEcosystems is all "YAML Value" listed on "#package-ecosystem",
    # that are the keys to `package-ecosystem` in dependabot yaml.
    module PackageEcosystems
      BUNDLER = "bundler"
      CARGO = "cargo"
      COMPOSER = "composer"
      DOCKER = "docker"
      ELM = "elm"
      GITHUB_ACTIONS = "github-actions"
      GIT_SUBMODULE = "gitsubmodule"
      GOMOD = "gomod"
      GRADLE = "gradle"
      MAVEN = "maven"
      MIX = "mix"
      NPM = "npm"
      # NUGET = "nuget"
      PIP = "pip"
      PUB = "pub"
      TERRAFORM = "terraform"
    end

    # PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY maps PackageEcosystems
    # to our end goal of the keys used to collect the respective file fetcher
    # classes that are registered via the "file_fetchers register function"
    # so each mapping |K,V| element should have a comment linking to the place
    # that its value was registered!
    PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY = {
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/bundler/lib/dependabot/bundler/file_fetcher.rb#L253
      PackageEcosystems::BUNDLER => "bundler",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/cargo/lib/dependabot/cargo/file_fetcher.rb#L410
      PackageEcosystems::CARGO => "cargo",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/composer/lib/dependabot/composer/file_fetcher.rb#L241
      PackageEcosystems::COMPOSER => "composer",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/docker/lib/dependabot/docker/file_fetcher.rb#L77
      PackageEcosystems::DOCKER => "docker",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/elm/lib/dependabot/elm/file_fetcher.rb#L50
      PackageEcosystems::ELM => "elm",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/github_actions/lib/dependabot/github_actions/file_fetcher.rb#L106-L107
      PackageEcosystems::GITHUB_ACTIONS => "github_actions",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L111-L112
      PackageEcosystems::GIT_SUBMODULE => "submodules",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/go_modules/lib/dependabot/go_modules/file_fetcher.rb#L63-L64
      PackageEcosystems::GOMOD => "go_modules",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/gradle/lib/dependabot/gradle/file_fetcher.rb#L203
      PackageEcosystems::GRADLE => "gradle",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/maven/lib/dependabot/maven/file_fetcher.rb#L179
      PackageEcosystems::MAVEN => "maven",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/hex/lib/dependabot/hex/file_fetcher.rb#L114
      PackageEcosystems::MIX => "hex",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/npm_and_yarn/lib/dependabot/npm_and_yarn/file_fetcher.rb#L737-L738
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/npm_and_yarn/lib/dependabot/npm_and_yarn/package_manager.rb#L18
      PackageEcosystems::NPM => "npm_and_yarn",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/nuget/lib/dependabot/nuget/file_fetcher.rb#L46
      # PackageEcosystems::NUGET => "nuget",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/python/lib/dependabot/python/file_fetcher.rb#L463
      PackageEcosystems::PIP => "pip",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/pub/lib/dependabot/pub/file_fetcher.rb#L58
      PackageEcosystems::PUB => "pub",
      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/terraform/lib/dependabot/terraform/file_fetcher.rb#L111-L112
      PackageEcosystems::TERRAFORM => "terraform"
    }.freeze

    # PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM maps PackageManagers
    # to the PackageEcosystems, according to "#package-ecosystem"
    PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM = {
      PackageManagers::BUNDLER => PackageEcosystems::BUNDLER,
      PackageManagers::CARGO => PackageEcosystems::CARGO,
      PackageManagers::COMPOSER => PackageEcosystems::COMPOSER,
      PackageManagers::DOCKER => PackageEcosystems::DOCKER,
      PackageManagers::HEX => PackageEcosystems::MIX,
      PackageManagers::ELM_PACKAGE => PackageEcosystems::ELM,
      PackageManagers::GIT_SUBMODULE => PackageEcosystems::GIT_SUBMODULE,
      PackageManagers::GITHUB_ACTIONS => PackageEcosystems::GITHUB_ACTIONS,
      PackageManagers::GO_MODULES => PackageEcosystems::GOMOD,
      PackageManagers::GRADLE => PackageEcosystems::GRADLE,
      PackageManagers::MAVEN => PackageEcosystems::MAVEN,
      PackageManagers::NPM => PackageEcosystems::NPM,
      # TODO: NuGets file fetcher utility within dependabot since this was last
      # updated has been heavily geared, far more than any other file fetcher,
      # to a state where it expects to be running within the service container
      # e.g. the NuGet file fetcher requires several env vars with little to no
      # explanation, it attempts to install .Net SDKs, and run pwsh scripts via
      # calling out of the ruby program to a subshell. I've tried a few methods
      # for circumventing it similar to the way I've patched the other fetchers
      # in the past, but none of them worked, and I'm just updating the version
      # here before archiving this repo because it's already served its purpose
      # PackageManagers::NUGET => PackageEcosystems::NUGET,
      PackageManagers::PIP => PackageEcosystems::PIP,
      PackageManagers::PIPENV => PackageEcosystems::PIP,
      PackageManagers::PIP_COMPILE => PackageEcosystems::PIP,
      PackageManagers::POETRY => PackageEcosystems::PIP,
      PackageManagers::PUB => PackageEcosystems::PUB,
      PackageManagers::TERRAFORM => PackageEcosystems::TERRAFORM,
      PackageManagers::YARN => PackageEcosystems::NPM
    }.freeze
  end
end
