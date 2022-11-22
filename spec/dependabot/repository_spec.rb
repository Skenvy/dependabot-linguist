# frozen_string_literal: true

require "fileutils"
require "rugged"
require "yaml"

RSpec.describe ::Dependabot::Linguist::Repository do
  ECOS = ::Dependabot::Linguist::PackageEcosystems
  # Wrap a repeated context block in an each on a set of configs per ecosystem.
  TEST_CONFIG_NAMES = ECOS.constants.map { |c| ECOS.const_get c }

  # This should validate for all ::Dependabot::Linguist::PackageEcosystems
  TEST_CONFIG = YAML.load_file(File.expand_path("./repository_spec_config.yaml", __dir__))

  it "has at least one test per ecosystem (that returns a non empty result)" do
    TEST_CONFIG_NAMES.each do |ecosystem_name|
      expect(TEST_CONFIG[ecosystem_name]).to be_instance_of(Array)
      expect(TEST_CONFIG[ecosystem_name]).not_to be_empty
      expect(TEST_CONFIG[ecosystem_name]).to include(satisfy { |tc| !tc["validated_directories"].nil? })
    end
  end

  TEST_CONFIG.each do |file_fetcher, test_configs|
    test_configs.each do |test_config|
      context "#{file_fetcher} @ ./smoke-test/#{file_fetcher}/#{test_config["dir"]}/" do
        before(:context) do
          # Path is relative to rspec running from repo root.
          Rugged::Repository.init_at("./smoke-test/#{file_fetcher}/#{test_config["dir"]}")
          @repo = Rugged::Repository.new("./smoke-test/#{file_fetcher}/#{test_config["dir"]}")
          @repo.index.add_all
          commit_author = {:email=>'email@email.com', :time=>Time.now, :name=>'username'}
          Rugged::Commit.create(@repo, :author => commit_author,
              :message => "Rspec auto commit for test", :committer => commit_author,
              :parents => @repo.empty? ? [] : [@repo.head.target].compact,
              :tree => @repo.index.write_tree(@repo), :update_ref => 'HEAD')
          # The name doesn't matter, but we don't want it to be open to cloning an
          # existing public repo that happens to collide with a silly name, if it
          # falls back on trying to clone because the above initialisation broke.
          @UUT = Dependabot::Linguist::Repository.new("./smoke-test/#{file_fetcher}/#{test_config["dir"]}", "Skenvy/dependabot-linguits")
        end

        it "validates which directories satisfy the ecosystem's file fetcher" do
          if test_config["validated_directories"]
            expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({"#{file_fetcher}" => test_config["validated_directories"]})
          else
            expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({})
          end
        end

        after(:context) do
          FileUtils.rm_rf("./smoke-test/#{file_fetcher}/#{test_config["dir"]}/.git")
        end
      end
    end
  end
end
