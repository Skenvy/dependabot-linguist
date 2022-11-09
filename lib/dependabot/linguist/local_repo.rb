# frozen_string_literal: true

require "rugged"
require "linguist/repository"
require "dependabot"
# require "dependabot/file_fetchers"
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
require_relative "language"
require_relative "language_to_ecosystem"
# require "dependabot/source"

module Dependabot
  module Linguist
    # LocalRepo substitutes for Linguist::Repository and Dependabot::Source
    class LocalRepo
      def initialize(repo_path, repo_name)
        @repo_path = repo_path
        @repo_name = repo_name
        @repo = Rugged::Repository.new(@repo_path)
        @linguist = ::Linguist::Repository.new(@repo, @repo.head.target_id)
      end

      def linguist_languages
        @linguist_languages ||= @linguist.languages
      end

      def possible_dependabot_ecosystems
        puts "List of languages: #{linguist_languages.keys}"
        @possible_package_managers ||= Dependabot::Linguist::list_of_languages_to_list_of_package_managers(linguist_languages.keys)
        puts "List of possible package managers: #{@possible_package_managers}"
        @possible_package_ecosystems ||= Dependabot::Linguist::list_of_package_managers_to_list_of_package_ecosystems(@possible_package_managers)
        puts "List of possible package ecosystems: #{@possible_package_ecosystems}"
        @possible_file_fetcher_registry_keys ||= Dependabot::Linguist::list_of_package_ecosystems_to_list_of_file_fetcher_registry_keys(@possible_package_ecosystems)
        puts "List of possible file fetcher registry keys: #{@possible_file_fetcher_registry_keys}"
        @possible_package_ecosystems
      end

      def package_ecosystem_to_dependabot_file_fetcher_classes
        @package_ecosystem_to_dependabot_file_fetcher_classes ||= nil
        if @package_ecosystem_to_dependabot_file_fetcher_classes.nil?
          @package_ecosystem_to_dependabot_file_fetcher_classes = {}
          possible_dependabot_ecosystems.each do |possible_ecosystem|
            @package_ecosystem_to_dependabot_file_fetcher_classes[possible_ecosystem] =
              Dependabot::FileFetchers::for_package_manager(
                Dependabot::Linguist::PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[possible_ecosystem]
              )
          end
        end
        @package_ecosystem_to_dependabot_file_fetcher_classes
      end
    end
  end
end
