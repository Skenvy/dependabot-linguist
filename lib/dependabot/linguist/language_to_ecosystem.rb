# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

# "languages detected by linguist": https://github.com/github/linguist/blob/v7.23.0/lib/linguist/languages.yml
# "file_fetchers register function": https://github.com/dependabot/dependabot-core/blob/v0.212.0/common/lib/dependabot/file_fetchers.rb#L14-L16
# "#package-ecosystem": https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file#package-ecosystem

# All the entries in this file are for facilitating the journey of starting with
# a list of languages detected by linguist; to travel via the list of "package
# managers" -> "package ecosystems", to then use those "package ecosystems" to
# yield the set of keys given to the file_fetchers register function.
#
# That is to say; going from the linguist languages to the
# list of file_fetcher classes that should be checked against!

module Dependabot
  module Linguist # rubocop:disable Style/Documentation
    # Returns the set of package managers
    # mapped to in LANGUAGE_TO_PACKAGE_MANAGER
    def self.linguist_languages_to_package_managers(languages)
      package_managers = []
      languages.each do |language|
        unless LANGUAGE_TO_PACKAGE_MANAGER[language].nil?
          if LANGUAGE_TO_PACKAGE_MANAGER[language].is_a?(Array)
            package_managers |= LANGUAGE_TO_PACKAGE_MANAGER[language]
          else
            package_managers |= [LANGUAGE_TO_PACKAGE_MANAGER[language]]
          end
        end
      end
      package_managers
    end

    # Returns the set of package ecosystems mapped
    # to in PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM
    def self.package_managers_to_package_ecosystems(package_managers)
      package_ecosystems = []
      package_managers.each do |package_manager|
        unless PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM[package_manager].nil?
          package_ecosystems |= [PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM[package_manager]]
        end
      end
      package_ecosystems
    end

    # Returns the set of file fetcher registry keys mapped
    # to in PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY
    def self.package_ecosystems_to_file_fetcher_registry_keys(package_ecosystems)
      file_fetcher_registry_keys = []
      package_ecosystems.each do |package_ecosystem|
        unless PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[package_ecosystem].nil?
          file_fetcher_registry_keys |= [PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[package_ecosystem]]
        end
      end
      file_fetcher_registry_keys
    end

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
      NUGET = "nuget"
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
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/bundler/lib/dependabot/bundler/file_fetcher.rb#L216
      PackageEcosystems::BUNDLER => "bundler",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/cargo/lib/dependabot/cargo/file_fetcher.rb#L295
      PackageEcosystems::CARGO => "cargo",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/composer/lib/dependabot/composer/file_fetcher.rb#L183
      PackageEcosystems::COMPOSER => "composer",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/docker/lib/dependabot/docker/file_fetcher.rb#L103
      PackageEcosystems::DOCKER => "docker",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/elm/lib/dependabot/elm/file_fetcher.rb#L46
      PackageEcosystems::ELM => "elm",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/github_actions/lib/dependabot/github_actions/file_fetcher.rb#L72-L73
      PackageEcosystems::GITHUB_ACTIONS => "github_actions",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L84-L85
      PackageEcosystems::GIT_SUBMODULE => "submodules",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/go_modules/lib/dependabot/go_modules/file_fetcher.rb#L54-L55
      PackageEcosystems::GOMOD => "go_modules",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/gradle/lib/dependabot/gradle/file_fetcher.rb#L131
      PackageEcosystems::GRADLE => "gradle",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/maven/lib/dependabot/maven/file_fetcher.rb#L142
      PackageEcosystems::MAVEN => "maven",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/hex/lib/dependabot/hex/file_fetcher.rb#L98
      PackageEcosystems::MIX => "hex",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/npm_and_yarn/lib/dependabot/npm_and_yarn/file_fetcher.rb#L419-L420
      PackageEcosystems::NPM => "npm_and_yarn",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/nuget/lib/dependabot/nuget/file_fetcher.rb#L271
      PackageEcosystems::NUGET => "nuget",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/python/lib/dependabot/python/file_fetcher.rb#L409
      PackageEcosystems::PIP => "pip",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/pub/lib/dependabot/pub/file_fetcher.rb#L46
      PackageEcosystems::PUB => "pub",
      # https://github.com/dependabot/dependabot-core/blob/v0.212.0/terraform/lib/dependabot/terraform/file_fetcher.rb#L90-L91
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
      PackageManagers::NUGET => PackageEcosystems::NUGET,
      PackageManagers::PIP => PackageEcosystems::PIP,
      PackageManagers::PIPENV => PackageEcosystems::PIP,
      PackageManagers::PIP_COMPILE => PackageEcosystems::PIP,
      PackageManagers::POETRY => PackageEcosystems::PIP,
      PackageManagers::PUB => PackageEcosystems::PUB,
      PackageManagers::TERRAFORM => PackageEcosystems::TERRAFORM,
      PackageManagers::YARN => PackageEcosystems::NPM
    }.freeze

    # rubocop:disable Style/MutableConstant
    # LANGUAGE_TO_PACKAGE_MANAGER is modified by context

    # LANGUAGE_TO_PACKAGE_MANAGER should map any language linguist can discover,
    # according to the "languages detected by linguist" link at the top, to a
    # corresponding GitHub dependabot package manager.
    #
    # Any language listed below could be surfaced by being added
    # to the file lib/dependabot/linguist/languages_to_patch.txt,
    # so they should exist in this map.
    LANGUAGE_TO_PACKAGE_MANAGER = {
      "1C Enterprise" => nil,
      "2-Dimensional Array" => nil,
      "4D" => nil,
      "ABAP" => nil,
      "ABAP CDS" => nil,
      "ABNF" => nil,
      "AGS Script" => nil,
      "AIDL" => nil,
      "AL" => nil,
      "AMPL" => nil,
      "ANTLR" => nil,
      "API Blueprint" => nil,
      "APL" => nil,
      "ASL" => nil,
      "ASN.1" => nil,
      "ASP.NET" => nil,
      "ATS" => nil,
      "ActionScript" => nil,
      "Ada" => nil,
      "Adblock Filter List" => nil,
      "Adobe Font Metrics" => nil,
      "Agda" => nil,
      "Alloy" => nil,
      "Alpine Abuild" => nil,
      "Altium Designer" => nil,
      "AngelScript" => nil,
      "Ant Build System" => nil,
      "Antlers" => nil,
      "ApacheConf" => nil,
      "Apex" => nil,
      "Apollo Guidance Computer" => nil,
      "AppleScript" => nil,
      "Arc" => nil,
      "AsciiDoc" => nil,
      "AspectJ" => nil,
      "Assembly" => nil,
      "Astro" => nil,
      "Asymptote" => nil,
      "Augeas" => nil,
      "AutoHotkey" => nil,
      "AutoIt" => nil,
      "Avro IDL" => nil,
      "Awk" => nil,
      "BASIC" => nil,
      "Ballerina" => nil,
      "Batchfile" => nil,
      "Beef" => nil,
      "Befunge" => nil,
      "Berry" => nil,
      "BibTeX" => nil,
      "Bicep" => nil,
      "Bikeshed" => nil,
      "Bison" => nil,
      "BitBake" => nil,
      "Blade" => nil,
      "BlitzBasic" => nil,
      "BlitzMax" => nil,
      "Bluespec" => nil,
      "Boo" => nil,
      "Boogie" => nil,
      "Brainfuck" => nil,
      "BrighterScript" => nil,
      "Brightscript" => nil,
      "Browserslist" => nil,
      "C" => nil,
      "C#" => nil,
      "C++" => nil,
      "C-ObjDump" => nil,
      "C2hs Haskell" => nil,
      "CAP CDS" => nil,
      "CIL" => nil,
      "CLIPS" => nil,
      "CMake" => nil,
      "COBOL" => nil,
      "CODEOWNERS" => nil,
      "COLLADA" => nil,
      "CSON" => nil,
      "CSS" => nil,
      "CSV" => nil,
      "CUE" => nil,
      "CWeb" => nil,
      "Cabal Config" => nil,
      "Cadence" => nil,
      "Cairo" => nil,
      "CameLIGO" => nil,
      "Cap'n Proto" => nil,
      "CartoCSS" => nil,
      "Ceylon" => nil,
      "Chapel" => nil,
      "Charity" => nil,
      "Checksums" => nil,
      "ChucK" => nil,
      "Cirru" => nil,
      "Clarion" => nil,
      "Clarity" => nil,
      "Classic ASP" => nil,
      "Clean" => nil,
      "Click" => nil,
      "Clojure" => nil,
      "Closure Templates" => nil,
      "Cloud Firestore Security Rules" => nil,
      "CoNLL-U" => nil,
      "CodeQL" => nil,
      "CoffeeScript" => nil,
      "ColdFusion" => nil,
      "ColdFusion CFC" => nil,
      "Common Lisp" => nil,
      "Common Workflow Language" => nil,
      "Component Pascal" => nil,
      "Cool" => nil,
      "Coq" => nil,
      "Cpp-ObjDump" => nil,
      "Creole" => nil,
      "Crystal" => nil,
      "Csound" => nil,
      "Csound Document" => nil,
      "Csound Score" => nil,
      "Cuda" => nil,
      "Cue Sheet" => nil,
      "Curry" => nil,
      "Cycript" => nil,
      "Cypher" => nil,
      "Cython" => nil,
      "D" => nil,
      "D-ObjDump" => nil,
      "DIGITAL Command Language" => nil,
      "DM" => nil,
      "DNS Zone" => nil,
      "DTrace" => nil,
      "Dafny" => nil,
      "Darcs Patch" => nil,
      "Dart" => nil,
      "DataWeave" => nil,
      "Debian Package Control File" => nil,
      "DenizenScript" => nil,
      "Dhall" => nil,
      "Diff" => nil,
      "DirectX 3D File" => nil,
      "Dockerfile" => nil,
      "Dogescript" => nil,
      "Dylan" => nil,
      "E" => nil,
      "E-mail" => nil,
      "EBNF" => nil,
      "ECL" => nil,
      "ECLiPSe" => nil,
      "EJS" => nil,
      "EQ" => nil,
      "Eagle" => nil,
      "Earthly" => nil,
      "Easybuild" => nil,
      "Ecere Projects" => nil,
      "EditorConfig" => nil,
      "Edje Data Collection" => nil,
      "Eiffel" => nil,
      "Elixir" => nil,
      "Elm" => nil,
      "Elvish" => nil,
      "Emacs Lisp" => nil,
      "EmberScript" => nil,
      "Erlang" => nil,
      "Euphoria" => nil,
      "F#" => nil,
      "F*" => nil,
      "FIGlet Font" => nil,
      "FLUX" => nil,
      "Factor" => nil,
      "Fancy" => nil,
      "Fantom" => nil,
      "Faust" => nil,
      "Fennel" => nil,
      "Filebench WML" => nil,
      "Filterscript" => nil,
      "Fluent" => nil,
      "Formatted" => nil,
      "Forth" => nil,
      "Fortran" => nil,
      "Fortran Free Form" => nil,
      "FreeBasic" => nil,
      "FreeMarker" => nil,
      "Frege" => nil,
      "Futhark" => nil,
      "G-code" => nil,
      "GAML" => nil,
      "GAMS" => nil,
      "GAP" => nil,
      "GCC Machine Description" => nil,
      "GDB" => nil,
      "GDScript" => nil,
      "GEDCOM" => nil,
      "GLSL" => nil,
      "GN" => nil,
      "GSC" => nil,
      "Game Maker Language" => nil,
      "Gemfile.lock" => nil,
      "Gemini" => nil,
      "Genero" => nil,
      "Genero Forms" => nil,
      "Genie" => nil,
      "Genshi" => nil,
      "Gentoo Ebuild" => nil,
      "Gentoo Eclass" => nil,
      "Gerber Image" => nil,
      "Gettext Catalog" => nil,
      "Gherkin" => nil,
      "Git Attributes" => nil,
      "Git Config" => nil,
      "Git Revision List" => nil,
      "Gleam" => nil,
      "Glyph" => nil,
      "Glyph Bitmap Distribution Format" => nil,
      "Gnuplot" => nil,
      "Go" => nil,
      "Go Checksums" => nil,
      "Go Module" => nil,
      "Golo" => nil,
      "Gosu" => nil,
      "Grace" => nil,
      "Gradle" => nil,
      "Grammatical Framework" => nil,
      "Graph Modeling Language" => nil,
      "GraphQL" => nil,
      "Graphviz (DOT)" => nil,
      "Groovy" => nil,
      "Groovy Server Pages" => nil,
      "HAProxy" => nil,
      "HCL" => nil,
      "HLSL" => nil,
      "HOCON" => nil,
      "HTML" => nil,
      "HTML+ECR" => nil,
      "HTML+EEX" => nil,
      "HTML+ERB" => nil,
      "HTML+PHP" => nil,
      "HTML+Razor" => nil,
      "HTTP" => nil,
      "HXML" => nil,
      "Hack" => nil,
      "Haml" => nil,
      "Handlebars" => nil,
      "Harbour" => nil,
      "Haskell" => nil,
      "Haxe" => nil,
      "HiveQL" => nil,
      "HolyC" => nil,
      "Hy" => nil,
      "HyPhy" => nil,
      "IDL" => nil,
      "IGOR Pro" => nil,
      "INI" => nil,
      "IRC log" => nil,
      "Idris" => nil,
      "Ignore List" => nil,
      "ImageJ Macro" => nil,
      "Imba" => nil,
      "Inform 7" => nil,
      "Inno Setup" => nil,
      "Io" => nil,
      "Ioke" => nil,
      "Isabelle" => nil,
      "Isabelle ROOT" => nil,
      "J" => nil,
      "JAR Manifest" => nil,
      "JFlex" => nil,
      "JSON" => nil,
      "JSON with Comments" => nil,
      "JSON5" => nil,
      "JSONLD" => nil,
      "JSONiq" => nil,
      "Janet" => nil,
      "Jasmin" => nil,
      "Java" => nil,
      "Java Properties" => nil,
      "Java Server Pages" => nil,
      "JavaScript" => nil,
      "JavaScript+ERB" => nil,
      "Jest Snapshot" => nil,
      "JetBrains MPS" => nil,
      "Jinja" => nil,
      "Jison" => nil,
      "Jison Lex" => nil,
      "Jolie" => nil,
      "Jsonnet" => nil,
      "Julia" => nil,
      "Jupyter Notebook" => nil,
      "KRL" => nil,
      "Kaitai Struct" => nil,
      "KakouneScript" => nil,
      "KiCad Layout" => nil,
      "KiCad Legacy Layout" => nil,
      "KiCad Schematic" => nil,
      "Kit" => nil,
      "Kotlin" => nil,
      "Kusto" => nil,
      "LFE" => nil,
      "LLVM" => nil,
      "LOLCODE" => nil,
      "LSL" => nil,
      "LTspice Symbol" => nil,
      "LabVIEW" => nil,
      "Lark" => nil,
      "Lasso" => nil,
      "Latte" => nil,
      "Lean" => nil,
      "Less" => nil,
      "Lex" => nil,
      "LigoLANG" => nil,
      "LilyPond" => nil,
      "Limbo" => nil,
      "Linker Script" => nil,
      "Linux Kernel Module" => nil,
      "Liquid" => nil,
      "Literate Agda" => nil,
      "Literate CoffeeScript" => nil,
      "Literate Haskell" => nil,
      "LiveScript" => nil,
      "Logos" => nil,
      "Logtalk" => nil,
      "LookML" => nil,
      "LoomScript" => nil,
      "Lua" => nil,
      "M" => nil,
      "M4" => nil,
      "M4Sugar" => nil,
      "MATLAB" => nil,
      "MAXScript" => nil,
      "MLIR" => nil,
      "MQL4" => nil,
      "MQL5" => nil,
      "MTML" => nil,
      "MUF" => nil,
      "Macaulay2" => nil,
      "Makefile" => nil,
      "Mako" => nil,
      "Markdown" => nil,
      "Marko" => nil,
      "Mask" => nil,
      "Mathematica" => nil,
      "Maven POM" => nil,
      "Max" => nil,
      "Mercury" => nil,
      "Mermaid" => nil,
      "Meson" => nil,
      "Metal" => nil,
      "Microsoft Developer Studio Project" => nil,
      "Microsoft Visual Studio Solution" => nil,
      "MiniD" => nil,
      "MiniYAML" => nil,
      "Mint" => nil,
      "Mirah" => nil,
      "Modelica" => nil,
      "Modula-2" => nil,
      "Modula-3" => nil,
      "Module Management System" => nil,
      "Monkey" => nil,
      "Monkey C" => nil,
      "Moocode" => nil,
      "MoonScript" => nil,
      "Motoko" => nil,
      "Motorola 68K Assembly" => nil,
      "Move" => nil,
      "Muse" => nil,
      "Mustache" => nil,
      "Myghty" => nil,
      "NASL" => nil,
      "NCL" => nil,
      "NEON" => nil,
      "NL" => nil,
      "NPM Config" => nil,
      "NSIS" => nil,
      "NWScript" => nil,
      "Nasal" => nil,
      "Nearley" => nil,
      "Nemerle" => nil,
      "NetLinx" => nil,
      "NetLinx+ERB" => nil,
      "NetLogo" => nil,
      "NewLisp" => nil,
      "Nextflow" => nil,
      "Nginx" => nil,
      "Nim" => nil,
      "Ninja" => nil,
      "Nit" => nil,
      "Nix" => nil,
      "Nu" => nil,
      "NumPy" => nil,
      "Nunjucks" => nil,
      "OASv2-json" => nil,
      "OASv2-yaml" => nil,
      "OASv3-json" => nil,
      "OASv3-yaml" => nil,
      "OCaml" => nil,
      "ObjDump" => nil,
      "Object Data Instance Notation" => nil,
      "ObjectScript" => nil,
      "Objective-C" => nil,
      "Objective-C++" => nil,
      "Objective-J" => nil,
      "Odin" => nil,
      "Omgrofl" => nil,
      "Opa" => nil,
      "Opal" => nil,
      "Open Policy Agent" => nil,
      "OpenAPI Specification v2" => nil,
      "OpenAPI Specification v3" => nil,
      "OpenCL" => nil,
      "OpenEdge ABL" => nil,
      "OpenQASM" => nil,
      "OpenRC runscript" => nil,
      "OpenSCAD" => nil,
      "OpenStep Property List" => nil,
      "OpenType Feature File" => nil,
      "Option List" => nil,
      "Org" => nil,
      "Ox" => nil,
      "Oxygene" => nil,
      "Oz" => nil,
      "P4" => nil,
      "PDDL" => nil,
      "PEG.js" => nil,
      "PHP" => nil,
      "PLSQL" => nil,
      "PLpgSQL" => nil,
      "POV-Ray SDL" => nil,
      "Pan" => nil,
      "Papyrus" => nil,
      "Parrot" => nil,
      "Parrot Assembly" => nil,
      "Parrot Internal Representation" => nil,
      "Pascal" => nil,
      "Pawn" => nil,
      "Pep8" => nil,
      "Perl" => nil,
      "Pic" => nil,
      "Pickle" => nil,
      "PicoLisp" => nil,
      "PigLatin" => nil,
      "Pike" => nil,
      "PlantUML" => nil,
      "Pod" => nil,
      "Pod 6" => nil,
      "PogoScript" => nil,
      "Polar" => nil,
      "Pony" => nil,
      "Portugol" => nil,
      "PostCSS" => nil,
      "PostScript" => nil,
      "PowerBuilder" => nil,
      "PowerShell" => nil,
      "Prisma" => nil,
      "Processing" => nil,
      "Procfile" => nil,
      "Proguard" => nil,
      "Prolog" => nil,
      "Promela" => nil,
      "Propeller Spin" => nil,
      "Protocol Buffer" => nil,
      "Protocol Buffer Text Format" => nil,
      "Public Key" => nil,
      "Pug" => nil,
      "Puppet" => nil,
      "Pure Data" => nil,
      "PureBasic" => nil,
      "PureScript" => nil,
      "Python" => nil,
      "Python console" => nil,
      "Python traceback" => nil,
      "Q#" => nil,
      "QML" => nil,
      "QMake" => nil,
      "Qt Script" => nil,
      "Quake" => nil,
      "R" => nil,
      "RAML" => nil,
      "RDoc" => nil,
      "REALbasic" => nil,
      "REXX" => nil,
      "RMarkdown" => nil,
      "RPC" => nil,
      "RPGLE" => nil,
      "RPM Spec" => nil,
      "RUNOFF" => nil,
      "Racket" => nil,
      "Ragel" => nil,
      "Raku" => nil,
      "Rascal" => nil,
      "Raw token data" => nil,
      "ReScript" => nil,
      "Readline Config" => nil,
      "Reason" => nil,
      "ReasonLIGO" => nil,
      "Rebol" => nil,
      "Record Jar" => nil,
      "Red" => nil,
      "Redcode" => nil,
      "Redirect Rules" => nil,
      "Regular Expression" => nil,
      "Ren'Py" => nil,
      "RenderScript" => nil,
      "Rich Text Format" => nil,
      "Ring" => nil,
      "Riot" => nil,
      "RobotFramework" => nil,
      "Roff" => nil,
      "Roff Manpage" => nil,
      "Rouge" => nil,
      "RouterOS Script" => nil,
      "Ruby" => nil,
      "Rust" => nil,
      "SAS" => nil,
      "SCSS" => nil,
      "SELinux Policy" => nil,
      "SMT" => nil,
      "SPARQL" => nil,
      "SQF" => nil,
      "SQL" => nil,
      "SQLPL" => nil,
      "SRecode Template" => nil,
      "SSH Config" => nil,
      "STAR" => nil,
      "STL" => nil,
      "STON" => nil,
      "SVG" => nil,
      "SWIG" => nil,
      "Sage" => nil,
      "SaltStack" => nil,
      "Sass" => nil,
      "Scala" => nil,
      "Scaml" => nil,
      "Scenic" => nil,
      "Scheme" => nil,
      "Scilab" => nil,
      "Self" => nil,
      "ShaderLab" => nil,
      "Shell" => nil,
      "ShellCheck Config" => nil,
      "ShellSession" => nil,
      "Shen" => nil,
      "Sieve" => nil,
      "Simple File Verification" => nil,
      "Singularity" => nil,
      "Slash" => nil,
      "Slice" => nil,
      "Slim" => nil,
      "SmPL" => nil,
      "Smali" => nil,
      "Smalltalk" => nil,
      "Smarty" => nil,
      "Solidity" => nil,
      "Soong" => nil,
      "SourcePawn" => nil,
      "Spline Font Database" => nil,
      "Squirrel" => nil,
      "Stan" => nil,
      "Standard ML" => nil,
      "Starlark" => nil,
      "Stata" => nil,
      "StringTemplate" => nil,
      "Stylus" => nil,
      "SubRip Text" => nil,
      "SugarSS" => nil,
      "SuperCollider" => nil,
      "Svelte" => nil,
      "Swift" => nil,
      "SystemVerilog" => nil,
      "TI Program" => nil,
      "TLA" => nil,
      "TOML" => nil,
      "TSQL" => nil,
      "TSV" => nil,
      "TSX" => nil,
      "TXL" => nil,
      "Talon" => nil,
      "Tcl" => nil,
      "Tcsh" => nil,
      "TeX" => nil,
      "Tea" => nil,
      "Terra" => nil,
      "Texinfo" => nil,
      "Text" => nil,
      "TextMate Properties" => nil,
      "Textile" => nil,
      "Thrift" => nil,
      "Turing" => nil,
      "Turtle" => nil,
      "Twig" => nil,
      "Type Language" => nil,
      "TypeScript" => nil,
      "Unified Parallel C" => nil,
      "Unity3D Asset" => nil,
      "Unix Assembly" => nil,
      "Uno" => nil,
      "UnrealScript" => nil,
      "UrWeb" => nil,
      "V" => nil,
      "VBA" => nil,
      "VBScript" => nil,
      "VCL" => nil,
      "VHDL" => nil,
      "Vala" => nil,
      "Valve Data Format" => nil,
      "Velocity Template Language" => nil,
      "Verilog" => nil,
      "Vim Help File" => nil,
      "Vim Script" => nil,
      "Vim Snippet" => nil,
      "Visual Basic .NET" => nil,
      "Visual Basic 6.0" => nil,
      "Volt" => nil,
      "Vue" => nil,
      "Vyper" => nil,
      "Wavefront Material" => nil,
      "Wavefront Object" => nil,
      "Web Ontology Language" => nil,
      "WebAssembly" => nil,
      "WebIDL" => nil,
      "WebVTT" => nil,
      "Wget Config" => nil,
      "Whiley" => nil,
      "Wikitext" => nil,
      "Win32 Message File" => nil,
      "Windows Registry Entries" => nil,
      "Witcher Script" => nil,
      "Wollok" => nil,
      "World of Warcraft Addon Data" => nil,
      "Wren" => nil,
      "X BitMap" => nil,
      "X Font Directory Index" => nil,
      "X PixMap" => nil,
      "X10" => nil,
      "XC" => nil,
      "XCompose" => nil,
      "XML" => nil,
      "XML Property List" => nil,
      "XPages" => nil,
      "XProc" => nil,
      "XQuery" => nil,
      "XS" => nil,
      "XSLT" => nil,
      "Xojo" => nil,
      "Xonsh" => nil,
      "Xtend" => nil,
      "YAML" => nil,
      "YANG" => nil,
      "YARA" => nil,
      "YASnippet" => nil,
      "Yacc" => nil,
      "Yul" => nil,
      "ZAP" => nil,
      "ZIL" => nil,
      "Zeek" => nil,
      "ZenScript" => nil,
      "Zephir" => nil,
      "Zig" => nil,
      "Zimpl" => nil,
      "cURL Config" => nil,
      "desktop" => nil,
      "dircolors" => nil,
      "eC" => nil,
      "edn" => nil,
      "fish" => nil,
      "hoon" => nil,
      "jq" => nil,
      "just" => nil,
      "kvlang" => nil,
      "mIRC Script" => nil,
      "mcfunction" => nil,
      "mupad" => nil,
      "nanorc" => nil,
      "nesC" => nil,
      "ooc" => nil,
      "q" => nil,
      "reStructuredText" => nil,
      "robots.txt" => nil,
      "sed" => nil,
      "wdl" => nil,
      "wisp" => nil,
      "xBase" => nil
    }

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
    }

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

    # Now apply the context rules
    CONTEXT_RULES.each do |package_manager, context_map|
      context_map.each do |_context_rule, linguist_languages|
        linguist_languages.each do |linguist_language|
          if LANGUAGE_TO_PACKAGE_MANAGER[linguist_language].nil?
            LANGUAGE_TO_PACKAGE_MANAGER[linguist_language] = [package_manager]
          else
            LANGUAGE_TO_PACKAGE_MANAGER[linguist_language] |= [package_manager]
          end
        end
      end
    end

    # rubocop:enable Style/MutableConstant
  end
end

# rubocop:enable Metrics/ModuleLength
