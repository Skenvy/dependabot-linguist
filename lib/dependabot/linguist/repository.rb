# frozen_string_literal: true

require "rugged"
require_relative "linguist_patch"
require_relative "languages_to_ecosystems/main"
require "dependabot/source"
require "dependabot/errors"
require "dependabot/shared_helpers"
require "dependabot/omnibus"
require_relative "dependabot_patch"

module Dependabot
  module Linguist
    # Repository wraps a Linguist::Repository, to discover "linguist languages"
    # present in a repository, then maps them to Dependabot Ecosystems, finally
    # verifying that those ecosystems are valid for the places linguist found
    # the languages it thought was relevant to each dependabot ecosystem.
    class Repository
      def initialize(repo_path, repo_name, ignore_linguist: 0, verbose: false)
        @repo_path = repo_path.chomp.delete_suffix("/") unless repo_path.nil?
        # If repo_path is nil, say that the current workdir is the path.
        @repo_path ||= "."
        @repo_name = repo_name
        begin
          @repo = Rugged::Repository.new(@repo_path)
        rescue Rugged::RepositoryError, Rugged::OSError
          # Either the folder doesn't exist, or it does and doesn't have a `.git/`
          # Try to clone into it, if it's public
          puts "Repository #{@repo_name} not found at #{@repo_path}; falling back to cloning public url"
          # If the current path isn't empty, make a temporary repository path.
          @repo_path = "./tmp/#{@repo_name}" unless Dir.empty? @repo_path
          puts "Cloning https://github.com/#{@repo_name}.git into #{@repo_path}"
          @repo = Rugged::Repository.clone_at("https://github.com/#{@repo_name}.git", @repo_path)
        end
        @ignore_linguist = ignore_linguist.clamp(0, 2)
        @verbose = verbose
        @linguist = ::Linguist::Repository.new(@repo, @repo.head.target_id)
      end

      # Wraps Linguist::Repository.new(~).languages
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

      # files_per_linguist_language inverts the linguist_cache map to
      # "<Language>" => ["<file_path>", ...], a list of files per language!
      # Note that they are not cleaned in the same way the folder paths in
      # each of the "directories per *" are prepended with a '/'.
      def files_per_linguist_language
        @files_per_linguist_language ||= linguist_cache.keys.group_by { |source_file_path|
          # create the map "<Language>" => ["<file_path>", ...]
          linguist_cache[source_file_path][0]
        }
      end

      # directories_per_linguist_language inverts the linguist_cache map to
      # "<Language>" => ["<folder_path>", ...], a list of folders per language!
      def directories_per_linguist_language
        @directories_per_linguist_language ||= linguist_cache.keys.to_h { |source_file_path|
          # create the map "<file_path>" => "<folder_path>"
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
          # GitHub Actions must be added seperately..
          # if any yaml exist in the workflows folder, it needs to be added at "/"
          if (directories_per_linguist_language["YAML"] || []).any? "/.github/workflows"
            this[PackageManagers::GITHUB_ACTIONS] = ["/"]
          end
          # Because actions are handled like this we also need to regexp for /\/action\.ya?ml$/
          (files_per_linguist_language["YAML"] || []).each do |source_file_path|
            # File paths aren't cleaned from linguist, so prepend the '/' here.
            # This lets it match the \/ before action.ya?ml if it's in the root dir.
            # /(?<dir>\S*)\/(?<file>action\.ya?ml)$/
            action_match = "/#{source_file_path}".match %r{(?<dir>\S*)/(?<file>action\.ya?ml)$}
            if action_match
              # But that also means we then need to check if dir is empty, if it's the root dir
              if action_match[:dir].empty?
                this[PackageManagers::GITHUB_ACTIONS] = (this[PackageManagers::GITHUB_ACTIONS] || []) | ["/"]
              else
                this[PackageManagers::GITHUB_ACTIONS] = (this[PackageManagers::GITHUB_ACTIONS] || []) | [action_match[:dir]]
              end
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

      def all_ecosystem_classes
        @all_ecosystem_classes ||= PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY.transform_values { |k, v| [k, Dependabot::FileFetchers.for_package_manager(v)] }
      end

      # directories_per_ecosystem_validated_by_dependabot maps each identified
      # present ecosystem to a list of the directories that linguist found files
      # for, that were then validated by running the file_fetcher files on them.
      def directories_per_ecosystem_validated_by_dependabot
        @directories_per_ecosystem_validated_by_dependabot ||= nil
        if @directories_per_ecosystem_validated_by_dependabot.nil?
          enable_options = { kubernetes_updates: true }
          @directories_per_ecosystem_validated_by_dependabot = {}
          case @ignore_linguist
          when 1
            # If ignore linguist is 1, we rely on it to block "vendored"
            # files from the sources, but we run all dependabot classes
            sources = linguist_sources.values
            ecosystem_classes = all_ecosystem_classes
          when 2
            # If ignore linguist is 2, we just don't use it at all.
            sources = all_sources
            ecosystem_classes = all_ecosystem_classes
          else # when 0 is part of this.
            # If ignore linguist is 0, we don't ignore it and rely
            # on it to find sources and pick dependabot classes
            sources = nil
            ecosystem_classes = file_fetcher_class_per_package_ecosystem
          end
          ecosystem_classes.each do |package_ecosystem, file_fetcher_class|
            @directories_per_ecosystem_validated_by_dependabot[package_ecosystem] = []
            puts "Spawning class instances for #{package_ecosystem}, in repo #{@repo_path}, class #{file_fetcher_class}" if @verbose
            sources = directories_per_package_ecosystem[package_ecosystem].collect { |directories| linguist_sources[directories] } unless [1, 2].any? @ignore_linguist
            sources.each do |source|
              fetcher = file_fetcher_class.new(source: source, credentials: [], repo_contents_path: @repo_path, options: enable_options)
              begin
                # https://github.com/dependabot/dependabot-core/blob/v0.303.0/common/lib/dependabot/file_fetchers/base.rb#L136-L148
                unless fetcher.files.map(&:name).empty?
                  @directories_per_ecosystem_validated_by_dependabot[package_ecosystem] |= [source.directory]
                  puts "-- Dependency files FOUND for package-ecosystem #{package_ecosystem} at #{source.directory}; #{fetcher.files.map(&:name)}" if @verbose
                end
              rescue Dependabot::SharedHelpers::HelperSubprocessFailed => e
                puts "-- Caught a DependabotError, #{e.class}, for package-ecosystem #{package_ecosystem} at #{source.directory}: Context #{e.error_context} + Message :: #{e.message}" if @verbose # rubocop:disable Layout/LineLength
              rescue Dependabot::DependabotError => e
                # Most of these will be Dependabot::DependencyFileNotFound
                # or Dependabot::PathDependenciesNotReachable
                puts "-- Caught a DependabotError, #{e.class}, for package-ecosystem #{package_ecosystem} at #{source.directory}: Message :: #{e.message}" if @verbose
              end
            end
          end
          @directories_per_ecosystem_validated_by_dependabot = @directories_per_ecosystem_validated_by_dependabot.delete_if { |_, v| v.empty? }.sort.to_h
        end
        @directories_per_ecosystem_validated_by_dependabot
      end
    end
  end
end
