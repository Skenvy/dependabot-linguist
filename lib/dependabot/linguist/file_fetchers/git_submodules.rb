# frozen_string_literal: true

require "dependabot/git_submodules"

# Patches
# https://github.com/dependabot/dependabot-core/blob/v0.212.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L21-L26
# https://github.com/dependabot/dependabot-core/blob/v0.212.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L28-L30

# This patches out the network calls that might fail if you've used a private
# repo as a submodule. It still validates the `.gitmodules` exists. If you ARE
# using a private repo as a submodule, consider visiting
# "Allowing Dependabot to access private dependencies" at the below link
# https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-security-and-analysis-settings-for-your-organization#allowing-dependabot-to-access-private-dependencies

module Dependabot
  module GitSubmodules
    # Patch to remove the online requirement for fetching git submodules
    class FileFetcher
      # required_files_in? only asserts the presence of a `.gitmodules` file
      # if the submodule referenced is private, then the network calls in
      # `submodule_refs` might break the runner.
      def fetch_files
        fetched_files = []
        fetched_files << gitmodules_file
        # fetched_files += submodule_refs
        fetched_files
      end

      def gitmodules_file
        # @gitmodules_file ||= fetch_file_from_host(".gitmodules")
        @gitmodules_file ||= fetch_file_if_present(".gitmodules")
      end
    end
  end
end
