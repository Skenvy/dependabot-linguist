# frozen_string_literal: true

require "dependabot/errors"
require "dependabot/go_modules"

module Dependabot
  module GoModules
    # Patch to remove the online requirement for fetching go modules
    class FileFetcher
      def fetch_files
        # # Ensure we always check out the full repo contents for go_module
        # # updates.
        # SharedHelpers.in_a_temporary_repo_directory(
        #   directory,
        #   clone_repo_contents
        # ) do
        #   unless go_mod
        #     raise(
        #       Dependabot::DependencyFileNotFound,
        #       Pathname.new(File.join(directory, "go.mod")).
        #       cleanpath.to_path
        #     )
        #   end
        # fetched_files = [go_mod]
        # Fetch the (optional) go.sum
        # fetched_files << go_sum if go_sum
        # fetched_files
        fetched_files = []
        if go_mod.nil?
          raise(Dependabot::DependencyFileNotFound, Pathname.new(File.join(directory, "go.mod")).cleanpath.to_path)
        else
          fetched_files << go_mod
        end
        fetched_files << go_sum unless go_sum.nil?
        fetched_files
        # end
      end
    end
  end
end
