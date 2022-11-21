# frozen_string_literal: true

require "yaml"
require "rugged"

module Dependabot
  module Linguist
    # Reads an existing dependabot file and determines how it should be updated
    # to meet the suggested entried to the updates list coming from repository's
    # directories_per_ecosystem_validated_by_dependabot
    class DependabotFileValidator
      def initialize(repo_path)
        @repo = Rugged::Repository.new(repo_path)
        @load_ecosystem_directories ||= nil
      end

      YAML_FILE_PATH = ".github/dependabot.yaml"

      YML_FILE_PATH = ".github/dependabot.yml"

      def dependabot_file_path
        @dependabot_file_path ||= if @repo.blob_at(@repo.head.target_id, YML_FILE_PATH)
          # the yml extension is preferred by GitHub, so even though this
          # returns the same as the `else`, check it before YAML.
          YML_FILE_PATH # rubocop:disable Layout/IndentationWidth
        elsif @repo.blob_at(@repo.head.target_id, YAML_FILE_PATH) # rubocop:disable Layout/ElseAlignment
          YAML_FILE_PATH
        else # rubocop:disable Layout/ElseAlignment
          @existing_config = {}
          YML_FILE_PATH
        end
      end

      def existing_config
        dependabot_file_path # to = {} if the file doesn't exist or isn't committed.
        # @existing_config ||= YAML.load_file(File.join(@repo.path, dependabot_file_path))
        @existing_config ||= YAML.safe_load(@repo.blob_at(@repo.head.target_id, dependabot_file_path).content)
      end

      # Expects an input that is the output of ::Dependabot::Linguist::Repository.new(~)'s
      # directories_per_ecosystem_validated_by_dependabot, which should be a map
      # {"<package_ecosystem>" => ["<folder_path>", ...], ...}
      def load_ecosystem_directories(load_ecosystem_directories: @load_ecosystem_directories)
        @load_ecosystem_directories ||= nil
        if @load_ecosystem_directories == load_ecosystem_directories
          @load_ecosystem_directories
        else
          @config_drift = nil
          @new_config = nil
          @load_ecosystem_directories = load_ecosystem_directories
        end
      end

      def self.ecosystem_directory_list(ecosystem_directories)
        ecosystem_directories.collect { |eco, dirs| dirs.collect { |dir| [eco, dir] } }.flatten(1)
      end

      # .collect { |k,v| v.collect { |d| [k,d] } }.flatten(1)
      def config_drift
        @config_drift ||= {}.tap do |this|
          ecosystem_directory_list(load_ecosystem_directories: @load_ecosystem_directories).each do |ecosystem_directory|
            pp ecosystem_directory
          end
        end
      end

      def new_config
        @new_config ||= nil
      end
    end
  end
end
