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

# Patches the class Dependabot::FileFetchers::Base that all file fetching classes sub class.
# https://github.com/dependabot/dependabot-core/blob/v0.217.0/common/lib/dependabot/file_fetchers/base.rb

# We need to patch cloned_commit with an edit that removes the wrapping
# `SharedHelpers.with_git_configured(credentials: credentials) do`

require "dependabot/file_fetchers"

# rubocop:disable Style/Documentation

module Dependabot
  module FileFetchers
    class Base
      # Original at https://github.com/dependabot/dependabot-core/blob/v0.217.0/common/lib/dependabot/file_fetchers/base.rb#L189-L197
      def cloned_commit
        return if repo_contents_path.nil? || !File.directory?(File.join(repo_contents_path, ".git"))
        Dir.chdir(repo_contents_path) do
          return SharedHelpers.run_shell_command("git rev-parse HEAD")&.strip
        end
      end

      # No need to patch other uses; the _clone_repo_contents function returns the path if a git repo already exists:
      # https://github.com/dependabot/dependabot-core/blob/v0.217.0/common/lib/dependabot/file_fetchers/base.rb#L595
    end
  end
end

# rubocop:enable Style/Documentation
