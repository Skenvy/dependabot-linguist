# frozen_string_literal: true

require "rugged"
require "dependabot/source"
require "dependabot/file_fetchers"
require "dependabot/errors"
# Require all ecosystem gems
require "dependabot/bundler"
require "dependabot/cargo"
require "dependabot/composer"
require "dependabot/docker"
require "dependabot/elm"
require "dependabot/github_actions"
require "dependabot/git_submodules"
require "dependabot/go_modules"
require "dependabot/gradle"
require "dependabot/hex"
require "dependabot/maven"
require "dependabot/npm_and_yarn"
require "dependabot/nuget"
require "dependabot/pub"
require "dependabot/python"
require "dependabot/terraform"
# Require changes
require_relative "language"
require_relative "language_to_ecosystem"
require_relative "file_fetchers/base"

module Dependabot
  module Linguist
    # LocalRepo substitutes for Linguist::Repository and Dependabot::Source
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

      def linguist_cache
        @linguist_cache ||= @linguist.cache
      end

      # Cache is a map of "path" => ["Lang", loc]
      # We need to invert it to "Lang" => ["paths",...]
      def map_linguist_languages_to_source_subfolders
        @map_linguist_languages_to_source_subfolders ||= nil
        if @map_linguist_languages_to_source_subfolders.nil?
          @map_linguist_languages_to_source_subfolders = {}
          linguist_cache.each do |source_file_path, lang_and_loc|
            if @map_linguist_languages_to_source_subfolders[lang_and_loc[0]].nil?
              @map_linguist_languages_to_source_subfolders[lang_and_loc[0]] = []
            end
            @map_linguist_languages_to_source_subfolders[lang_and_loc[0]] |= ["/#{source_file_path.slice(0, source_file_path.rindex("/"))}"]
          end
        end
        @map_linguist_languages_to_source_subfolders
      end

      # Splits each language into the package managers it might implicate
      # And add all sources for that language to the package manager.
      def map_dependabot_package_managers_to_source_subfolders
        @map_dependabot_package_managers_to_source_subfolders ||= nil
        if @map_dependabot_package_managers_to_source_subfolders.nil?
          @map_dependabot_package_managers_to_source_subfolders = {}
          map_linguist_languages_to_source_subfolders.each do |linguist_language, source_subfolders|
            Dependabot::Linguist.list_of_languages_to_list_of_package_managers([linguist_language]).each do |dependabot_package_manager|
              if @map_dependabot_package_managers_to_source_subfolders[dependabot_package_manager].nil?
                @map_dependabot_package_managers_to_source_subfolders[dependabot_package_manager] = []
              end
              @map_dependabot_package_managers_to_source_subfolders[dependabot_package_manager] |= source_subfolders
            end
          end
        end
        @map_dependabot_package_managers_to_source_subfolders
      end

      # Some package managers share the same ecosystem, so squash to the ecosystems.
      def map_dependabot_package_ecosystem_to_source_subfolders
        @map_dependabot_package_ecosystem_to_source_subfolders ||= nil
        if @map_dependabot_package_ecosystem_to_source_subfolders.nil?
          @map_dependabot_package_ecosystem_to_source_subfolders = {}
          map_dependabot_package_managers_to_source_subfolders.each do |dependabot_package_manager, source_subfolders|
            Dependabot::Linguist.list_of_package_managers_to_list_of_package_ecosystems([dependabot_package_manager]).each do |dependabot_package_ecosystem|
              if @map_dependabot_package_ecosystem_to_source_subfolders[dependabot_package_ecosystem].nil?
                @map_dependabot_package_ecosystem_to_source_subfolders[dependabot_package_ecosystem] = []
              end
              @map_dependabot_package_ecosystem_to_source_subfolders[dependabot_package_ecosystem] |= source_subfolders
            end
          end
        end
        @map_dependabot_package_ecosystem_to_source_subfolders
      end

      def possible_dependabot_ecosystems
        puts "List of languages: #{linguist_languages.keys}"
        @possible_package_managers ||= Dependabot::Linguist.list_of_languages_to_list_of_package_managers(linguist_languages.keys)
        puts "List of possible package managers: #{@possible_package_managers}"
        @possible_package_ecosystems ||= Dependabot::Linguist.list_of_package_managers_to_list_of_package_ecosystems(@possible_package_managers)
        puts "List of possible package ecosystems: #{@possible_package_ecosystems}"
        # @possible_file_fetcher_registry_keys ||= Dependabot::Linguist.list_of_package_ecosystems_to_list_of_file_fetcher_registry_keys(@possible_package_ecosystems)
        # puts "List of possible file fetcher registry keys: #{@possible_file_fetcher_registry_keys}"
        @possible_package_ecosystems
      end

      def package_ecosystem_to_dependabot_file_fetcher_classes
        @package_ecosystem_to_dependabot_file_fetcher_classes ||= nil
        if @package_ecosystem_to_dependabot_file_fetcher_classes.nil?
          @package_ecosystem_to_dependabot_file_fetcher_classes = {}
          possible_dependabot_ecosystems.each do |possible_ecosystem|
            @package_ecosystem_to_dependabot_file_fetcher_classes[possible_ecosystem] =
              Dependabot::FileFetchers.for_package_manager(
                Dependabot::Linguist::PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[possible_ecosystem]
              )
          end
        end
        @package_ecosystem_to_dependabot_file_fetcher_classes
      end

      def all_subfolders
        # /**/*/ rather than /**/ would remove the base path, but delete_prefix will also remove it, so it needs to be specially added.
        @all_subfolders ||= (["/"] | Dir.glob("#{@repo_path}/**/*/").map { |subpath| subpath.delete_prefix(@repo_path).delete_suffix("/") })
      end

      def all_sources
        @all_sources ||= all_subfolders.collect { |subfolder| Dependabot::Source.new(provider: "github", repo: @repo_name, directory: subfolder) }
      end

      def linguist_subfolders
        @linguist_subfolders ||= map_dependabot_package_ecosystem_to_source_subfolders.values.flatten.uniq
      end

      def linguist_sources
        @linguist_sources ||= linguist_subfolders.to_h { |subfolder| [subfolder, Dependabot::Source.new(provider: "github", repo: @repo_name, directory: subfolder)] }
      end

      def ecosystems_that_file_fetcher_fetches_files_for
        @ecosystems_that_file_fetcher_fetches_files_for ||= nil
        if @ecosystems_that_file_fetcher_fetches_files_for.nil?
          @ecosystems_that_file_fetcher_fetches_files_for = {}
          package_ecosystem_to_dependabot_file_fetcher_classes.each do |package_ecosystem, file_fetcher_class|
            ecosystems_that_file_fetcher_fetches_files_for[package_ecosystem] = []
            puts "Spawning class instances for #{package_ecosystem}, in repo #{@repo_path}, class #{file_fetcher_class}"
            sources = map_dependabot_package_ecosystem_to_source_subfolders[package_ecosystem].collect { |subfolders| linguist_sources[subfolders] } # all_sources
            sources.each do |source|
              fetcher = file_fetcher_class.new(source: source, credentials: [], repo_contents_path: @repo_path)
              begin
                unless fetcher.files.map(&:name).empty?
                  ecosystems_that_file_fetcher_fetches_files_for[package_ecosystem] |= [source.directory]
                  puts "-- Dependency files FOUND for package-ecosystem #{package_ecosystem} at #{source.directory}; #{fetcher.files.map(&:name)}"
                end
              rescue Dependabot::DependabotError => e
                # Most of these will be Dependabot::DependencyFileNotFound or Dependabot::PathDependenciesNotReachable
                puts "-- Caught a DependabotError, #{e.class}, for package-ecosystem #{package_ecosystem} at #{source.directory}: #{e.message}"
              end
            end
          end
        end
        @ecosystems_that_file_fetcher_fetches_files_for
      end
    end
  end
end
