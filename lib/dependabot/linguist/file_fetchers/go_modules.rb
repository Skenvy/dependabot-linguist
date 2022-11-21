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

# Patches Dependabot::GoModules::FileFetcher.fetch_files
# https://github.com/dependabot/dependabot-core/blob/v0.212.0/go_modules/lib/dependabot/go_modules/file_fetcher.rb#L19-L41

# Patch to remove the online requirement for fetching go modules

# See the git_submodule patch for a comment explaining the reorder pattern,
# due to `go_mod` being acquired via `fetch_file_if_present` and hitting
# `load_cloned_file_if_present`.

require "dependabot/errors"
require "dependabot/go_modules"

# rubocop:disable Style/Documentation

module Dependabot
  module GoModules
    class FileFetcher
      def fetch_files
        raise(Dependabot::DependencyFileNotFound, Pathname.new(File.join(directory, "go.mod")).cleanpath.to_path) if go_mod.nil?
        fetched_files = [go_mod]
        fetched_files << go_sum unless go_sum.nil?
        fetched_files
      end
    end
  end
end

# rubocop:enable Style/Documentation
