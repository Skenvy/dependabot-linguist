# frozen_string_literal: true

require "fileutils"
require "rugged"

RSpec.describe ::Dependabot::Linguist::Repository do
  # Wrap a repeated context block in an each on a set of configs per ecosystem.
  test_config = {}

  # This should validate for all ::Dependabot::Linguist::PackageEcosystems
  # it "validates all ecosystems" do
  test_config["bundler"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["cargo"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["composer"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["docker"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["elm"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["github-actions"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["gitsubmodule"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["gomod"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["gradle"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["maven"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["mix"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["npm"] = {directories_per_ecosystem_validated_by_dependabot: ["/", "/removed"] }
  test_config["nuget"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["pip"] = {directories_per_ecosystem_validated_by_dependabot: ["/pip-compile", "/pip", "/pipenv", "/poetry"] }
  test_config["pub"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  test_config["terraform"] = {directories_per_ecosystem_validated_by_dependabot: ["/"]}
  # end

  test_config.each_key do |file_fetcher|
    context "#{file_fetcher}" do
      before(:context) do
        # Path is relative to rspec running from repo root.
        Rugged::Repository.init_at("./smoke-test/#{file_fetcher}")
        @repo = Rugged::Repository.new("./smoke-test/#{file_fetcher}")
        @repo.index.add_all
        commit_author = {:email=>'email@email.com', :time=>Time.now, :name=>'username'}
        Rugged::Commit.create(@repo, :author => commit_author,
            :message => "Rspec auto commit for test", :committer => commit_author,
            :parents => @repo.empty? ? [] : [@repo.head.target].compact,
            :tree => @repo.index.write_tree(@repo), :update_ref => 'HEAD')
        # The name doesn't matter, but we don't want it to be open to cloning an
        # existing public repo that happens to collide with a silly name, if it
        # falls back on trying to clone because the above initialisation broke.
        @UUT = Dependabot::Linguist::Repository.new("./smoke-test/#{file_fetcher}", "Skenvy/dependabot-linguits")
      end

      it "does something useful" do
        expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({"#{file_fetcher}" => test_config[file_fetcher][:directories_per_ecosystem_validated_by_dependabot]})
      end

      after(:context) do
        FileUtils.rm_rf("./smoke-test/#{file_fetcher}/.git")
      end
    end
  end
end
