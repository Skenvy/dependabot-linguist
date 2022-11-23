# frozen_string_literal: true

require "fileutils"
require "rugged"
require "yaml"

RSpec.describe ::Dependabot::Linguist::DependabotFileValidator do

  # At the moment they all share this "load_ecosystem_directories"
  # but put it out here in case we want to make them different later
  common_load_ecosystem_directories = { "bundler" => ["/bundler"], "cargo" => ["/cargo"], "composer" => ["/composer"] }


  test_sets = {
    "no-config" => {remove_undiscovered: false, update_existing: true,
      minimum_interval: "weekly", max_open_pull_requests_limit: 5,
      load_ecosystem_directories: common_load_ecosystem_directories},
    "partial-config" => {remove_undiscovered: false, update_existing: false,
      minimum_interval: "monthly", max_open_pull_requests_limit: 7,
      load_ecosystem_directories: common_load_ecosystem_directories},
    "over-config" => {remove_undiscovered: true, update_existing: true,
      minimum_interval: "daily", max_open_pull_requests_limit: 3,
      load_ecosystem_directories: common_load_ecosystem_directories},
    "overer-config" => {remove_undiscovered: false, update_existing: true,
      minimum_interval: "daily", max_open_pull_requests_limit: 5,
      load_ecosystem_directories: common_load_ecosystem_directories}
  }

  test_sets.each do |dependabot_subdirectory, conf|
    context "dependabot-file @ ./smoke-test/dependabot-file/#{dependabot_subdirectory}/" do
      before(:context) do
        # Path is relative to rspec running from repo root.
        Rugged::Repository.init_at("./smoke-test/dependabot-file/#{dependabot_subdirectory}")
        @repo = Rugged::Repository.new("./smoke-test/dependabot-file/#{dependabot_subdirectory}")
        @repo.index.add_all
        commit_author = {:email=>'email@email.com', :time=>Time.now, :name=>'username'}
        Rugged::Commit.create(@repo, :author => commit_author,
            :message => "Rspec auto commit for test", :committer => commit_author,
            :parents => @repo.empty? ? [] : [@repo.head.target].compact,
            :tree => @repo.index.write_tree(@repo), :update_ref => 'HEAD')
        # The name doesn't matter, but we don't want it to be open to cloning an
        # existing public repo that happens to collide with a silly name, if it
        # falls back on trying to clone because the above initialisation broke.
        @UUT = Dependabot::Linguist::DependabotFileValidator.new("./smoke-test/dependabot-file/#{dependabot_subdirectory}",
          remove_undiscovered: conf[:remove_undiscovered], update_existing: conf[:update_existing],
          minimum_interval: conf[:minimum_interval], max_open_pull_requests_limit: conf[:max_open_pull_requests_limit])
        @UUT.load_ecosystem_directories(incoming: conf[:load_ecosystem_directories])
        @TARGET_YAML_CONFIG = YAML.safe_load(@repo.blob_at(@repo.head.target_id, ".github/TARGET.yaml").content)
      end

      it "Produces the expected \"new\" config" do
        expect(@UUT.new_config).to eq(@TARGET_YAML_CONFIG)
      end

      after(:context) do
        FileUtils.rm_rf("./smoke-test/dependabot-file/#{dependabot_subdirectory}/.git")
      end
    end
  end
end
