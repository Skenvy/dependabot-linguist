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

# Patches Dependabot::GitSubmodules::FileFetcher.path_gemspec_paths

# To fix https://github.com/Skenvy/dependabot-linguist/issues/6 we need to patch
# ::Dependabot::Bundler::FileFetcher::fetch_path_gemspec_paths to stop it throwing
# a Bundler::GemfileNotFound error, thrown from assuming that ::Bundler::root will
# be run at the location the Gemfile.lock, and thus the Gemfile, exist. Currently
# ::Bundler::LockfileParser::initialize during fetch_path_gemspec_paths will go;
# ::Bundler::LockfileParser::parse_source, ::Bundler::Source::Rubygems::from_lock,
# ::Bundler::Source::Rubygems::initialize, ::Bundler::Source::Rubygems::cache_path,
# ::Bundler::app_cache, ::Bundler::root, ::Bundler::SharedHelpers::root, before
# landing at ::Bundler::SharedHelpers::find_gemfile where it can read from ENV
# `ENV["BUNDLE_GEMFILE"]`, or fail to locate an adjacent "Gemfile".

# See https://github.com/CloutKhan/dependabot-bundler error demo for more details.

# Instead of having the entire fetch_path_gemspec_paths in here, we can just wrap
# the only place it's used, inside path_gemspec_paths -- with setting the ENV.

require "dependabot/errors"
require "dependabot/bundler"

# rubocop:disable Style/Documentation

module Dependabot
  module Bundler
    class FileFetcher
      # https://github.com/dependabot/dependabot-core/blob/v0.299.0/bundler/lib/dependabot/bundler/file_fetcher.rb#L162-L165
      def path_gemspec_paths
        swap_bundle_gemfile = ENV.fetch("BUNDLE_GEMFILE", nil)
        repo_dir_gemfile = "#{@repo_contents_path}#{source.directory}/Gemfile"
        ENV["BUNDLE_GEMFILE"] = repo_dir_gemfile
        raise(Dependabot::DependencyFileNotFound, Pathname.new(File.join(directory, "Gemfile")).cleanpath.to_path) unless File.exist?(repo_dir_gemfile)
        result = fetch_path_gemspec_paths.map { |path| Pathname.new(path) }
        ENV["BUNDLE_GEMFILE"] = swap_bundle_gemfile
        result
      end
    end
  end
end

# rubocop:enable Style/Documentation
