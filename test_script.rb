# frozen_string_literal: true

require "dependabot/linguist"
# smoke_tests = Dependabot::Linguist::LocalRepo.new("../smoke-tests", "Skenvy/smoke-tests")
smoke_tests = Dependabot::Linguist::LocalRepo.new("./smoke-test/actions", "Skenvy/smoke-tests")
# puts smoke_tests.all_sources
puts ""
puts smoke_tests.linguist_cache
puts ""
puts smoke_tests.files_per_linguist_language
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

# ✅ "bundler"
# ✅ "cargo"
# ✅ "composer"
# ✅ "docker"
# ✅ "elm"
# ❌ "github-actions" 🔵 (need to fix it to ALSO check for ANY `action.y[a]ml` file)
# ✅ "gitsubmodule"
# ✅ "gomod"
# ✅ "gradle"
# ✅ "maven"
# ✅ "mix"
# ✅ "npm"
# ✅ "nuget"
# ✅ "pip"
# ✅ "pub"
# ✅ "terraform"

# {
#   "bundler"=>["/", "/smoke-test/bundler"],
#   "cargo"=>["/smoke-test/cargo"],
#   "composer"=>["/smoke-test/composer"],
#   "docker"=>["/smoke-test/docker"],
#   "elm"=>["/smoke-test/elm"],
#   "github-actions"=>["/"],
#   "gitsubmodule"=>["/"],
#   "gomod"=>["/smoke-test/go"],
#   "gradle"=>["/smoke-test/gradle"],
#   "maven"=>["/smoke-test/maven"],
#   "mix"=>["/smoke-test/mix"],
#   "npm"=>["/smoke-test/npm", "/smoke-test/npm/removed"],
#   "nuget"=>["/smoke-test/nuget"],
#   "pip"=>["/smoke-test/pip-compile", "/smoke-test/pip", "/smoke-test/pipenv", "/smoke-test/poetry"],
#   "pub"=>["/smoke-test/pub"],
#   "terraform"=>["/smoke-test/terraform"]
# }
