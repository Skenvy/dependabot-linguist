# frozen_string_literal: true

require "dependabot/linguist"
smoke_tests = Dependabot::Linguist::LocalRepo.new("../smoke-tests", "Skenvy/smoke-tests")
puts smoke_tests.sources
puts smoke_tests.package_ecosystem_to_dependabot_file_fetcher_classes
puts smoke_tests.ecosystems_that_file_fetcher_fetches_files_for
