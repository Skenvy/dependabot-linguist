# frozen_string_literal: true

require "dependabot/git_submodules"

# Patches
# https://github.com/dependabot/dependabot-core/blob/v0.212.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L28-L30

module Dependabot
  # Patch to remove the online requirement for fetching git submodules
  module GitSubmodules
    class FileFetcher 
      def gitmodules_file
        # @gitmodules_file ||= fetch_file_from_host(".gitmodules")
        @gitmodules_file ||= fetch_file_if_present(".gitmodules")
      end
    end
  end
end

