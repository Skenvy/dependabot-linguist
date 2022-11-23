# frozen_string_literal: true

# This demonstrates the typical utility of ::Dependabot::Linguist::Repository
# and ::Dependabot::Linguist::DependabotFileValidator, by running them both on
# this repository's root dir. The <repo>/smoke-test/ dir should contain samples
# that will provide at least one valid entry for each ecosystem. Because this
# demo is being run on the root of this repository, it will also validate the
# presence of the .github/workflows/*.y[a]ml files for github-actions.

# Notably, it must run on a repo root, as the repo path is used to initialise an
# instance of ::Rugged::Repository, both for creating a ::Linguist::Repository
# instance, and to load files with ::Rugged::Repository#blob_at. The smoke-test
# RSpec tests get around this by frobbing temp repos in each test directory.

require "dependabot/linguist"
require "yaml"

repo_path = "." # input for both ::Dependabot::Linguist::(Repository, DependabotFileValidator)
# The repository name only matters for cloning a public repo, besides ::Dependabot::Source

this_repo = ::Dependabot::Linguist::Repository.new(repo_path, "Skenvy/dependabot-linguist")

puts "*"*80
puts "\nThe set of files, per linguist language\n"
puts this_repo.files_per_linguist_language.to_yaml
puts "\nThe set of directories per linguist language\n"
puts this_repo.directories_per_linguist_language.to_yaml
puts "\nThe package managers\n"
puts this_repo.directories_per_package_manager.to_yaml
puts "\nThe package ecosystems\n"
puts this_repo.directories_per_package_ecosystem.to_yaml
puts "\nPaydirt; which ecosystem's directory guesses were validated by dependabot!\n"
puts this_repo.directories_per_ecosystem_validated_by_dependabot.to_yaml
puts "\n"

validator = ::Dependabot::Linguist::DependabotFileValidator.new(repo_path)

puts "*"*80
puts "\nThe dependabot config file path in this repo\n"
puts validator.dependabot_file_path
puts "\nThe existing dependabot configuration state\n"
puts validator.existing_config.to_yaml
puts "\nLoad in the results of the ::Dependabot::Linguist::Repository.directories_per_ecosystem_validated_by_dependabot\n"
puts validator.load_ecosystem_directories(incoming: this_repo.directories_per_ecosystem_validated_by_dependabot).to_yaml
puts "\nDetermine the drift in configuration -- what already exists, and what should be added (or removed?)\n"
puts validator.config_drift.to_yaml
puts "\nOutput the recommended 'new' config for the dependabot file.\n"
puts validator.new_config.to_yaml
puts "\nWrite the new config to the dependabot file\n"
puts validator.write_new_config
