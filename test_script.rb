# frozen_string_literal: true

require "dependabot/linguist"
smoke_tests = Dependabot::Linguist::LocalRepo.new("../smoke-tests", "Skenvy/smoke-tests")
# puts smoke_tests.all_sources
puts ""
puts smoke_tests.directories_per_linguist_language
puts ""
puts smoke_tests.directories_per_package_manager
puts ""
puts smoke_tests.directories_per_package_ecosystem
puts ""
# puts smoke_tests.file_fetcher_class_per_package_ecosystem
puts smoke_tests.directories_per_ecosystem_validated_by_dependabot

# require "rugged"
# require "linguist"
# repo_path = "../smoke-tests"
# repo_name = "Skenvy/smoke-tests"
# repo = Rugged::Repository.new(repo_path)
# linguist = ::Linguist::Repository.new(repo, repo.head.target_id)
# puts linguist.cache
