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

# Direct the requiring of the files that patch dependabot via this.
# The current target version for dependabot is 0.303.0
# https://github.com/dependabot/dependabot-core/tree/v0.303.0

require_relative "file_fetchers/bundler"
require_relative "file_fetchers/go_modules"
require_relative "file_fetchers/git_submodules"
require_relative "native_helpers/nuget"

module Dependabot
  module Linguist
    module DependabotPatch
      # Plug holes opened by applying these patches in one place.
      def self.apply_patch(repo_path)
        Dependabot::Nuget::NativeHelpers.DEPENDABOT_REPO_CONTENTS_PATH(repo_path)
      end
    end
  end
end
