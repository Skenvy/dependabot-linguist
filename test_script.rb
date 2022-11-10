# frozen_string_literal: true

# require "dependabot/linguist"
# smoke_tests = Dependabot::Linguist::LocalRepo.new('../smoke-tests', 'Skenvy/smoke-tests')
# puts smoke_tests.sources
# puts smoke_tests.package_ecosystem_to_dependabot_file_fetcher_classes
# puts smoke_tests.ecosystems_that_file_fetcher_fetches_files_for

# require 'dependabot/source'
# require 'dependabot/file_fetchers'
# require 'dependabot/python'
# source = Dependabot::Source.new(provider: "github", repo: 'Skenvy/smoke-tests', directory: '/pip')
# fetcher_class = Dependabot::FileFetchers::for_package_manager('pip')
# fetcher = fetcher_class.new(source: source, credentials: [], repo_contents_path: '../smoke-tests')

require "dependabot/source"
require "dependabot/file_fetchers"
require "dependabot/bundler"
require "dependabot/cargo"
require "dependabot/composer"
require "dependabot/docker"
require "dependabot/elm"
require "dependabot/github_actions"
require "dependabot/git_submodules"
require "dependabot/go_modules"
require "dependabot/gradle"
require "dependabot/hex"
require "dependabot/maven"
require "dependabot/npm_and_yarn"
require "dependabot/nuget"
require "dependabot/pub"
require "dependabot/python"
require "dependabot/terraform"
target_provider = "github"
target_repo = "Skenvy/Collatz"
target_pre_cloned_path = "../Collatz"
target_directory = "/python"
target_package_manager = "pip"
source = Dependabot::Source.new(provider: target_provider, repo: target_repo, directory: target_directory)
fetcher_class = Dependabot::FileFetchers.for_package_manager(target_package_manager)
fetcher = fetcher_class.new(source: source, credentials: [], repo_contents_path: target_pre_cloned_path)
puts "Fetched #{fetcher.files.map(&:name)}, at commit SHA-1 '#{fetcher.commit}'"
