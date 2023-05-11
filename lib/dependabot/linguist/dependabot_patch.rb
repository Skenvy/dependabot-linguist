# frozen_string_literal: true

# Direct the requiring of the files that patch dependabot via this.
# https://github.com/dependabot/dependabot-core/tree/v0.217.0

require_relative "file_fetchers/go_modules"
require_relative "file_fetchers/git_submodules"
