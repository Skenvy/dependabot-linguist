# frozen_string_literal: true

require "yaml"
require "rugged"

module Dependabot
  module Linguist
    # Reads an existing dependabot file and determines how it should be updated
    # to meet the suggested entried to the updates list coming from repository's
    # directories_per_ecosystem_validated_by_dependabot
    class DependabotFileValidator
      def initialize(repo_path, remove_undiscovered: false, update_existing: true, minimum_interval: "weekly", max_open_pull_requests_limit: 5, verbose: false)
        @repo = Rugged::Repository.new(repo_path)
        @remove_undiscovered = remove_undiscovered
        @update_existing = update_existing
        @minimum_interval = minimum_interval
        @max_open_pull_requests_limit = [max_open_pull_requests_limit, 0].max
        @verbose = verbose
        @load_ecosystem_directories ||= nil
      end

      YAML_FILE_PATH = ".github/dependabot.yaml"

      YML_FILE_PATH = ".github/dependabot.yml"

      CONFIG_FILE_PATH = ".github/.dependabot-linguist"

      def dependabot_file_path
        @dependabot_file_path ||= if @repo.blob_at(@repo.head.target_id, YML_FILE_PATH)
          # the yml extension is preferred by GitHub, so even though this
          # returns the same as the `else`, check it before YAML.
          YML_FILE_PATH # rubocop:disable Layout/IndentationWidth
        elsif @repo.blob_at(@repo.head.target_id, YAML_FILE_PATH) # rubocop:disable Layout/ElseAlignment
          YAML_FILE_PATH
        else # rubocop:disable Layout/ElseAlignment
          @existing_config = { "version" => 2, "updates" => [] }
          YML_FILE_PATH
        end # rubocop:disable Layout/EndAlignment
      end

      def existing_config
        dependabot_file_path # to = {} if the file doesn't exist or isn't committed.
        # @existing_config ||= YAML.load_file(File.join(@repo.path, dependabot_file_path))
        @existing_config ||= YAML.safe_load(@repo.blob_at(@repo.head.target_id, dependabot_file_path).content)
      end

      def meta_config
        @meta_config ||= if @repo.blob_at(@repo.head.target_id, CONFIG_FILE_PATH)
          YAML.safe_load(@repo.blob_at(@repo.head.target_id, CONFIG_FILE_PATH).content)
        else
          {}
        end
      end

      # Is a yaml config file exists that looks like
      #
      # ignore:
      #   directory:
      #     /path/to/somewhere:
      #     - some_ecosystem
      #   ecosystem:
      #     some_other_ecosystem:
      #     - /path/to/somewhere_else
      #
      # then both (some_ecosystem, "/path/to/somewhere") and
      # (some_other_ecosystem, "/path/to/somewhere_else")
      # should be "ignored" by this system.
      def ecodir_is_ignored(eco, dir)
        (((meta_config["ignore"] || {})["directory"] || {})[dir] || []).any? eco || (((meta_config["ignore"] || {})["ecosystem"] || {})[eco] || []).any? dir
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
        @config_drift ||= {}.tap do |this|
          ecodir_list = self.class.flatten_ecodirs_to_ecodir(load_ecosystem_directories)
          this[ConfigDriftStatus::ALREADY_IN] = []
          this[ConfigDriftStatus::TO_BE_ADDED] = []
          this[ConfigDriftStatus::UNDISCOVERED] = []
          this.freeze
          ecodir_list.each do |checking_ecodir|
            next if ecodir_is_ignored(checking_ecodir[0], checking_ecodir[1])
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
                break if ecodir_is_ignored(checking_ecodir[0], checking_ecodir[1])
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
        @new_config ||= YAML.safe_load(existing_config.to_yaml).tap do |this|
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
                # Confirm the open-pull-requests-limit
                if existing_update["open-pull-requests-limit"]
                  existing_update["open-pull-requests-limit"] = [existing_update["open-pull-requests-limit"], @max_open_pull_requests_limit].min
                else
                  existing_update["open-pull-requests-limit"] = @max_open_pull_requests_limit
                end
                existing_update.delete("open-pull-requests-limit") if existing_update["open-pull-requests-limit"] == 5
              end
            end
          end
          config_drift[ConfigDriftStatus::TO_BE_ADDED].each do |tba|
            new_update = { "package-ecosystem" => tba[0], "directory" => tba[1] }
            new_update["schedule"] = { "interval" => parsed_schedule_interval("monthly") }
            new_update["open-pull-requests-limit"] = @max_open_pull_requests_limit if @max_open_pull_requests_limit != 5
            this["updates"].append(new_update)
          end
        end
      end

      def write_new_config
        File.open("#{@repo.path.delete_suffix("/.git/")}/#{dependabot_file_path}", "w") { |file| file.write(new_config.to_yaml) } if new_config != existing_config
      end

      # The expected environment to run this final step in should have 'git' AND
      # 'gh' available as commands to run, and calls out to a subshell to run
      # them as set up by the environment that runs this, rather than requiring
      # credentials being provided to this class.
      def commit_new_config
        new_branch = @repo.create_branch("dependabot-linguist_auto-config-update")
        in_repo = "cd #{@repo.path.delete_suffix("/.git/")} &&"
        `#{"#{in_repo} git checkout #{new_branch.name}"}`
        write_new_config
        `#{"#{in_repo} git add #{dependabot_file_path}"}`
        `#{"#{in_repo} git commit -m \"Auto update #{dependabot_file_path} -- dependabot-linguist\""}`
        `#{"#{in_repo} git push --set-upstream #{@repo.remotes["origin"].name} #{new_branch.name}"}`
        `#{"#{in_repo} gh pr create --fill"}`
      end
    end
  end
end
