# frozen_string_literal: true

require "dependabot/linguist"
repo_path = "." # /smoke-test/actions
smoke_tests = Dependabot::Linguist::Repository.new(repo_path, "Skenvy/smoke-tests")
puts ""
puts smoke_tests.files_per_linguist_language
puts ""
puts smoke_tests.directories_per_linguist_language
puts ""
puts smoke_tests.directories_per_package_manager
puts ""
puts smoke_tests.directories_per_package_ecosystem
puts ""
puts smoke_tests.directories_per_ecosystem_validated_by_dependabot
puts ""
validator = Dependabot::Linguist::DependabotFileValidator.new(repo_path)
puts validator.existing_config
puts ""
puts validator.load_ecosystem_directories(incoming: smoke_tests.directories_per_ecosystem_validated_by_dependabot)
puts ""
puts validator.config_drift
