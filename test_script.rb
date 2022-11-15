# frozen_string_literal: true

require "dependabot/linguist"
smoke_tests = Dependabot::Linguist::LocalRepo.new("../smoke-tests", "Skenvy/smoke-tests")
# puts smoke_tests.all_sources
puts smoke_tests.map_linguist_languages_to_source_subfolders
puts smoke_tests.map_dependabot_package_managers_to_source_subfolders
puts smoke_tests.map_dependabot_package_ecosystem_to_source_subfolders
# puts smoke_tests.package_ecosystem_to_dependabot_file_fetcher_classes
puts smoke_tests.ecosystems_that_file_fetcher_fetches_files_for

# require "rugged"
# require "linguist"
# repo_path = "../smoke-tests"
# repo_name = "Skenvy/smoke-tests"
# repo = Rugged::Repository.new(repo_path)
# linguist = ::Linguist::Repository.new(repo, repo.head.target_id)
# puts linguist.cache
