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

# Patches Dependabot::Nuget::NativeHelpers.normalize_file_names

# Patched to remove the need for DEPENDABOT_HOME to exist and be set as an env
# var -- which is used internally to dependabot to flag that it's running in a
# container as the update service (e.g. the DEPENDABOT_HOME is set in their
# docker build). Alternative workarounds for DEPENDABOT_REPO_CONTENTS_PATH exist
# i.e. adding it in the exe/dependabot-linguist cli entry and setting it to the
# value of the `repo_path` -- but there's no easy method for circumventing the
# need for DEPENDABOT_HOME to be set, so add DEPENDABOT_REPO_CONTENTS_PATH to
# the exe/dependabot-linguist, and patch out DEPENDABOT_HOME in here.

# rubocop:disable Style/Documentation

require 'find'
require "dependabot/nuget"

module Dependabot
  module Nuget
    module NativeHelpers
      def self.DEPENDABOT_REPO_CONTENTS_PATH(repo_path)
        @DEPENDABOT_REPO_CONTENTS_PATH ||= repo_path
      end

      # https://github.com/dependabot/dependabot-core/blob/v0.303.0/nuget/lib/dependabot/nuget/native_helpers.rb#L289-L303
      # Runs https://github.com/dependabot/dependabot-core/blob/v0.303.0/nuget/updater/normalize-file-names.ps1
      # Runs https://github.com/dependabot/dependabot-core/blob/v0.303.0/nuget/updater/common.ps1#L159-L161
      # Which just adjusts the case of any-case match on "NuGet.Config" to that specific casing.
      # We can just put an error here if we see a file with the wrong casing.
      def self.normalize_file_names
        Find.find(self.DEPENDABOT_REPO_CONTENTS_PATH('')) do |path|
          # if it matches, but doesn't match the case..
          if path =~ /\/NuGet\.Config$/i && !(path =~ /\/NuGet\.Config$/)
            File.rename(path, File.dirname(path) + '/NuGet.Config')
          end
        end
      end
    end
  end
end

# rubocop:enable Style/Documentation
