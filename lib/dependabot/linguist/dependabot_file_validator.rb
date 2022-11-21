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
      def load_ecosystem_directories(incoming: @load_ecosystem_directories)
        @load_ecosystem_directories ||= nil
        if @load_ecosystem_directories == incoming
          @load_ecosystem_directories
        else
          @config_drift = nil
          @new_config = nil
          @load_ecosystem_directories = incoming
        end
      end

      def self.flatten_ecodirs_to_ecodir(ecosystem_directories_map)
        ecosystem_directories_map.collect { |eco, dirs| dirs.collect { |dir| [eco, dir] } }.flatten(1)
      end

      def self.checking_exists(checking, exists)
        exists["package-ecosystem"] == checking[0] && exists["directory"] == checking[1]
      end

      def config_drift
        @config_drift ||= {}.tap do |this|
          ecodir_list = self.class.flatten_ecodirs_to_ecodir(load_ecosystem_directories)
          ecodir_list.each do |checking_ecodir|
            if !existing_config.empty? && !existing_config["updates"].nil?
              existed_ecodir = nil
              existing_config["updates"].each do |existing_ecodir|
                if self.class.checking_exists(checking_ecodir, existing_ecodir)
                  puts "FOUND RECOMMENDATION ALREADY PRESENT; {#{checking_ecodir[0]} @ #{checking_ecodir[1]}}"
                  existed_ecodir = existing_ecodir
                  break # existing_ecodir
                end
              end
              # break to here
              next unless existed_ecodir.nil? # checking_ecodir
            end
            # If we didn't break -> next, then we've got a checking_ecodir
            # that we didn't find already present in the existing ecodirs.
            puts "RECOMMENDATION TO BE ADDED; {#{checking_ecodir[0]} @ #{checking_ecodir[1]}}"
          end
          if !existing_config.empty? && !existing_config["updates"].nil?
            existing_config["updates"].each do |existing_ecodir|
              existed_ecodir = nil
              ecodir_list.each do |checking_ecodir|
                existed_ecodir = checking_ecodir if self.class.checking_exists(checking_ecodir, existing_ecodir)
                break unless existed_ecodir.nil?
              end
              if existed_ecodir.nil?
                puts "UNDISCOVERED ENTRY PRE-EXISTS {#{existing_ecodir["package-ecosystem"]} @ #{existing_ecodir["directory"]}} that wasn't found by dependabot-linguist!!"
              end
            end
          end
        end
      end

      def new_config
        @new_config ||= nil
      end
    end
  end
end
