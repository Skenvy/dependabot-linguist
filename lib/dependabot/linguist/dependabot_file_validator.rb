# frozen_string_literal: true

require "yaml"
require "rugged"

module Dependabot
  module Linguist
    # Reads an existing dependabot file and determines how it should be updated
    # to meet the suggested entried to the updates list coming from repository's
    # directories_per_ecosystem_validated_by_dependabot
    class DependabotFileValidator
      def initialize(repo_path, remove_undiscovered: false, update_existing: true, minimum_interval: "weekly", verbose: false)
        @repo = Rugged::Repository.new(repo_path)
        @remove_undiscovered = remove_undiscovered
        @update_existing = update_existing
        @minimum_interval = minimum_interval
        @verbose = verbose
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
          @existing_config = { "version" => 2 }
          YML_FILE_PATH
        end # rubocop:disable Layout/EndAlignment
      end

      def existing_config
        dependabot_file_path # to = {} if the file doesn't exist or isn't committed.
        # @existing_config ||= YAML.load_file(File.join(@repo.path, dependabot_file_path))
        @existing_config ||= YAML.safe_load(@repo.blob_at(@repo.head.target_id, dependabot_file_path).content)
      end

      def confirm_config_version_is_valid
        raise StandardError("The existing config has a version other than 2") unless existing_config["version"] == 2
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

      module ConfigDriftStatus
        ALREADY_IN = "FOUND RECOMMENDATION ALREADY PRESENT"
        TO_BE_ADDED = "RECOMMENDATION TO BE ADDED"
        UNDISCOVERED = "UNDISCOVERED ENTRY PRE-EXISTS"
      end

      def config_drift
        confirm_config_version_is_valid
        @config_drift ||= {}.tap do |this| # rubocop:disable Metrics/BlockLength
          ecodir_list = self.class.flatten_ecodirs_to_ecodir(load_ecosystem_directories)
          this[ConfigDriftStatus::ALREADY_IN] = []
          this[ConfigDriftStatus::TO_BE_ADDED] = []
          this[ConfigDriftStatus::UNDISCOVERED] = []
          this.freeze
          ecodir_list.each do |checking_ecodir|
            if !existing_config.empty? && !existing_config["updates"].nil?
              existed_ecodir = nil
              existing_config["updates"].each do |existing_ecodir|
                if self.class.checking_exists(checking_ecodir, existing_ecodir)
                  puts "#{ConfigDriftStatus::ALREADY_IN}; {#{checking_ecodir[0]} @ #{checking_ecodir[1]}}" if @verbose
                  this[ConfigDriftStatus::ALREADY_IN].append(checking_ecodir)
                  existed_ecodir = existing_ecodir
                  break # existing_ecodir
                end
              end
              # break to here
              next unless existed_ecodir.nil? # checking_ecodir
            end
            # If we didn't break -> next, then we've got a checking_ecodir
            # that we didn't find already present in the existing ecodirs.
            puts "#{ConfigDriftStatus::TO_BE_ADDED}; {#{checking_ecodir[0]} @ #{checking_ecodir[1]}}" if @verbose
            this[ConfigDriftStatus::TO_BE_ADDED].append(checking_ecodir)
          end
          if !existing_config.empty? && !existing_config["updates"].nil?
            existing_config["updates"].each do |existing_ecodir|
              existed_ecodir = nil
              ecodir_list.each do |checking_ecodir|
                existed_ecodir = checking_ecodir if self.class.checking_exists(checking_ecodir, existing_ecodir)
                break unless existed_ecodir.nil?
              end
              if existed_ecodir.nil?
                puts "#{ConfigDriftStatus::UNDISCOVERED}; {#{existing_ecodir["package-ecosystem"]} @ #{existing_ecodir["directory"]}} that wasn't found by us!!" if @verbose
                this[ConfigDriftStatus::UNDISCOVERED].append([existing_ecodir["package-ecosystem"], existing_ecodir["directory"]])
              end
            end
          end
        end
      end

      def parsed_schedule_interval(interval)
        intervals = ["daily", "weekly", "monthly"].freeze
        if intervals.any? @minimum_interval
          intervals[[intervals.find_index(@minimum_interval) || (intervals.length-1), intervals.find_index(interval) || (intervals.length-1)].min]
        else
          interval
        end
      end

      def new_config
        confirm_config_version_is_valid
        @new_config ||= existing_config.clone.tap do |this|
          this["updates"] = [] if this["updates"].nil?
          # If "remove_undiscovered" is set, then set this to reject any
          # updates that are in the list of those undiscovered. Removing
          # is not safe from inside each, so reject instead.
          this["updates"] = this["updates"].reject { |u| config_drift[ConfigDriftStatus::UNDISCOVERED].any? [u["package-ecosystem"], u["directory"]] } if @remove_undiscovered
          # Next, go through and update any existing.
          if @update_existing
            this["updates"].each do |existing_update|
              if config_drift[ConfigDriftStatus::ALREADY_IN].any? [existing_update["package-ecosystem"], existing_update["directory"]]
                # Confirm that the already present entry is good enough
                if existing_update["schedule"].is_a? Hash
                  new_interval = parsed_schedule_interval(existing_update["schedule"]["interval"])
                  existing_update["schedule"]["interval"] = new_interval
                  # if it's not weekly anymore remove day if it's specified.
                  if existing_update["schedule"]["interval"] != "weekly"
                    existing_update["schedule"].delete("day")
                  end
                else
                  existing_update["schedule"] = { "interval" => parsed_schedule_interval("monthly") }
                end
              end
            end
          end
          config_drift[ConfigDriftStatus::TO_BE_ADDED].each do |tba|
            new_update = { "package-ecosystem" => tba[0], "directory" => tba[1] }
            new_update["schedule"] = { "interval" => parsed_schedule_interval("monthly") }
            this["updates"].append(new_update)
          end
        end
      end
    end
  end
end
