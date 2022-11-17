# frozen_string_literal: true

require "rugged"
require_relative "language"
require "dependabot/source"
require "dependabot/errors"
require "dependabot/omnibus"
require_relative "file_fetchers/base"
require_relative "file_fetchers/go_modules"
require_relative "file_fetchers/git_submodules"
require_relative "language_to_ecosystem"

module Dependabot
  module Linguist
    # LocalRepo allows utility of Linguist::Repository and Dependabot
    class LocalRepo
      def initialize(repo_path, repo_name)
        @repo_path = repo_path.delete_suffix("/").chomp
        @repo_name = repo_name
        @repo = Rugged::Repository.new(@repo_path)
        @linguist = ::Linguist::Repository.new(@repo, @repo.head.target_id)
      end

      def linguist_languages
        @linguist_languages ||= @linguist.languages
      end

      # linguist_cache, linguist.cache, is a map of
      # "<file_path>" => ["<Language>", <loc>] for
      # any files found for any language looked for.
      def linguist_cache
        @linguist_cache ||= @linguist.cache
      end

      # rubocop:disable Style/HashTransformValues, Style/BlockDelimiters, Style/MultilineBlockChain
      # Disable these checks to demonstrate this style -- and the first `.to_h {...}` shouldn't be
      # a `.transform_values {...}`` as the Style/HashTransformValues cop requests it to be.

      # directories_per_linguist_language inverts the linguist_cache map to
      # "<Language>" => ["<folder_path>", ...], a list of folders per language!
      def directories_per_linguist_language
        @directories_per_linguist_language ||= linguist_cache.keys.to_h { |source_file_path|
          # create the map "<file_path>" => "<folder_path>"
          p source_file_path
          [source_file_path, "/#{source_file_path.slice(0, source_file_path.rindex("/") || 0)}"]
        }.group_by { |source_file_path, _source_folder_path|
          # create the map "<Language>" => [["<file_path>", "<folder_path>"], ...]
          linguist_cache[source_file_path][0]
        }.to_h { |linguist_language, file_then_folder_arr|
          # create the map "<Language>" => ["<folder_path>", ...] by taking the
          # (&:last) out of each ["<file_path>", "<folder_path>"] pair, uniquely
          [linguist_language, file_then_folder_arr.map(&:last).uniq]
        }
      end

      # rubocop:enable Style/HashTransformValues, Style/BlockDelimiters, Style/MultilineBlockChain

      # directories_per_package_manager splits and merges the results of
      # directories_per_linguist_language; split across each package manager that
      # is relevant to the language, and then merges the list of file paths for
      # that language into the list of file paths for each package manager!
      def directories_per_package_manager
        @directories_per_package_manager ||= {}.tap do |this|
          directories_per_linguist_language.each do |linguist_language, source_directories|
            Dependabot::Linguist.linguist_languages_to_package_managers([linguist_language]).each do |dependabot_package_manager|
              this[dependabot_package_manager] = (this[dependabot_package_manager] || []) | source_directories
            end
          end
        end
      end

      # directories_per_package_ecosystem squashes the map of
      # directories_per_package_manager according to the map of managers
      # to ecosystems, as some managers share a common ecosystem name.
      def directories_per_package_ecosystem
        @directories_per_package_ecosystem ||= nil
        if @directories_per_package_ecosystem.nil?
          @directories_per_package_ecosystem = {}
          directories_per_package_manager.each do |dependabot_package_manager, source_directories|
            Dependabot::Linguist.package_managers_to_package_ecosystems([dependabot_package_manager]).each do |dependabot_package_ecosystem|
              if @directories_per_package_ecosystem[dependabot_package_ecosystem].nil?
                @directories_per_package_ecosystem[dependabot_package_ecosystem] = []
              end
              @directories_per_package_ecosystem[dependabot_package_ecosystem] |= source_directories
            end
          end
        end
        @directories_per_package_ecosystem
      end

      # file_fetcher_class_per_package_ecosystem maps ecosystem names to the
      # class objects for each dependabot file fetcher class that's relevant
      # based on the list of ecosystems found by linguist languages.
      def file_fetcher_class_per_package_ecosystem
        @file_fetcher_class_per_package_ecosystem ||= nil
        if @file_fetcher_class_per_package_ecosystem.nil?
          @file_fetcher_class_per_package_ecosystem = {}
          directories_per_package_ecosystem.each_key do |possible_ecosystem|
            @file_fetcher_class_per_package_ecosystem[possible_ecosystem] =
              Dependabot::FileFetchers.for_package_manager(
                Dependabot::Linguist::PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[possible_ecosystem]
              )
          end
        end
        @file_fetcher_class_per_package_ecosystem
      end

      # Print out the lists of languages, managers, and ecosystems found here.
      def put_discovery_info
        puts "List of languages: #{directories_per_linguist_language.keys}"
        puts "List of package managers: #{directories_per_package_manager.keys}"
        puts "List of package ecosystems: #{directories_per_package_ecosystem.keys}"
      end

      # Get ALL directories for the repo path.
      def all_directories
        # /**/*/ rather than /**/ would remove the base path, but delete_prefix
        # will also remove it, so it needs to be specially added.
        @all_directories ||= (["/"] | Dir.glob("#{@repo_path}/**/*/").map { |subpath| subpath.delete_prefix(@repo_path).delete_suffix("/") })
      end

      # Get ALL sources from ALL directories for the repo path.
      def all_sources
        @all_sources ||= all_directories.collect { |directory| Dependabot::Source.new(provider: "github", repo: @repo_name, directory: directory) }
      end

      # Get the list of all directories identified by linguist, that
      # had their language mapped to a relevant dependabot ecosystem.
      def linguist_directories
        @linguist_directories ||= directories_per_package_ecosystem.values.flatten.uniq
      end

      # Get the list of all sources from all directories identified by linguist,
      # that had their language mapped to a relevant dependabot ecosystem.
      def linguist_sources
        @linguist_sources ||= linguist_directories.to_h { |directory| [directory, Dependabot::Source.new(provider: "github", repo: @repo_name, directory: directory)] }
      end

      # directories_per_ecosystem_validated_by_dependabot maps each identified
      # present ecosystem to a list of the directories that linguist found files
      # for, that were then validated by running the file_fetcher files on them.
      def directories_per_ecosystem_validated_by_dependabot
        @directories_per_ecosystem_validated_by_dependabot ||= nil
        if @directories_per_ecosystem_validated_by_dependabot.nil?
          enable_options = { kubernetes_updates: true }
          @directories_per_ecosystem_validated_by_dependabot = {}
          file_fetcher_class_per_package_ecosystem.each do |package_ecosystem, file_fetcher_class|
            directories_per_ecosystem_validated_by_dependabot[package_ecosystem] = []
            puts "Spawning class instances for #{package_ecosystem}, in repo #{@repo_path}, class #{file_fetcher_class}"
            sources = directories_per_package_ecosystem[package_ecosystem].collect { |directories| linguist_sources[directories] } # all_sources
            sources.each do |source|
              fetcher = file_fetcher_class.new(source: source, credentials: [], repo_contents_path: @repo_path, options: enable_options)
              begin
                unless fetcher.files.map(&:name).empty?
                  directories_per_ecosystem_validated_by_dependabot[package_ecosystem] |= [source.directory]
                  puts "-- Dependency files FOUND for package-ecosystem #{package_ecosystem} at #{source.directory}; #{fetcher.files.map(&:name)}"
                end
              rescue Dependabot::DependabotError => e
                # Most of these will be Dependabot::DependencyFileNotFound
                # or Dependabot::PathDependenciesNotReachable
                puts "-- Caught a DependabotError, #{e.class}, for package-ecosystem #{package_ecosystem} at #{source.directory}: #{e.message}"
              end
            end
          end
        end
        @directories_per_ecosystem_validated_by_dependabot
      end
    end
  end
end
