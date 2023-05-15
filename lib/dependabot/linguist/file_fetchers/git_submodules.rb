# frozen_string_literal: true

#########################################################################################
# _____                            _       _           _     _____      _       _       #
# |  __ \                          | |     | |         | |   |  __ \    | |     | |     #
# | |  | | ___ _ __   ___ _ __   __| | __ _| |__   ___ | |_  | |__) |_ _| |_ ___| |__   #
# | |  | |/ _ \ '_ \ / _ \ '_ \ / _` |/ _` | '_ \ / _ \| __| |  ___/ _` | __/ __| '_ \  #
# | |__| |  __/ |_) |  __/ | | | (_| | (_| | |_) | (_) | |_  | |  | (_| | || (__| | | | #
# |_____/ \___| .__/ \___|_| |_|\__,_|\__,_|_.__/ \___/ \__| |_|   \__,_|\__\___|_| |_| #
#             | |                                                                       #
#             |_|                                                                       #
#########################################################################################

# Patches Dependabot::GitSubmodules::FileFetcher.(fetch_files, gitmodules_file)

# This patches out the network calls that might fail if you've used a private
# repo as a submodule. It still validates the `.gitmodules` exists. If you ARE
# using a private repo as a submodule, consider visiting
# "Allowing Dependabot to access private dependencies" at the below link
# https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/managing-security-and-analysis-settings-for-your-organization#allowing-dependabot-to-access-private-dependencies

# Dependabot::GitSubmodules::FileFetcher::required_files_in? only asserts the
# presence of a `.gitmodules` file if the submodule referenced is private, then
# the network calls in `submodule_refs` might break the runner.

# If Dependabot::FileFetchers::Base.load_cloned_file_if_present
# can't see the file, it'll `raise Dependabot::DependencyFileNotFound`, which
# will make Dependabot::FileFetchers::Base.fetch_file_if_present `return` which
# will add nil to the list of fetched_files -- i.e.
# ```
# def woah
#   return
# end
# [] << woah # is [nil]
# ```
# So we need to be more cautious with this and check it first.

# Dependabot::FileFetchers::Base.load_cloned_file_if_present
# https://github.com/dependabot/dependabot-core/blob/v0.217.0/common/lib/dependabot/file_fetchers/base.rb#L135-L155
# Dependabot::FileFetchers::Base.fetch_file_if_present
# https://github.com/dependabot/dependabot-core/blob/v0.217.0/common/lib/dependabot/file_fetchers/base.rb#L111-L133

require "dependabot/errors"
require "dependabot/git_submodules"

# rubocop:disable Style/Documentation

module Dependabot
  module GitSubmodules
    class FileFetcher
      # https://github.com/dependabot/dependabot-core/blob/v0.217.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L21-L26
      def fetch_files
        raise(Dependabot::DependencyFileNotFound, Pathname.new(File.join(directory, ".gitmodules")).cleanpath.to_path) if gitmodules_file.nil?
        [gitmodules_file]
      end

      # https://github.com/dependabot/dependabot-core/blob/v0.217.0/git_submodules/lib/dependabot/git_submodules/file_fetcher.rb#L28-L30
      def gitmodules_file
        @gitmodules_file ||= fetch_file_if_present(".gitmodules")
      end
    end
  end
end

# rubocop:enable Style/Documentation
