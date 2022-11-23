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
      expect(TEST_CONFIG[ecosystem_name]).to include(satisfy { |tc| !tc["directories_per_ecosystem_validated_by_dependabot"].nil? })
    end
  end

  TEST_CONFIG.each do |file_fetcher, test_configs|
    test_configs.each do |test_config|
      context "#{file_fetcher} @ ./smoke-test/#{file_fetcher}/#{test_config["ecosystem_subdirectory"]}/" do
        before(:context) do
          # Path is relative to rspec running from repo root.
          Rugged::Repository.init_at("./smoke-test/#{file_fetcher}/#{test_config["ecosystem_subdirectory"]}")
          @repo = Rugged::Repository.new("./smoke-test/#{file_fetcher}/#{test_config["ecosystem_subdirectory"]}")
          @repo.index.add_all
          commit_author = {:email=>'email@email.com', :time=>Time.now, :name=>'username'}
          Rugged::Commit.create(@repo, :author => commit_author,
              :message => "Rspec auto commit for test", :committer => commit_author,
              :parents => @repo.empty? ? [] : [@repo.head.target].compact,
              :tree => @repo.index.write_tree(@repo), :update_ref => 'HEAD')
          # The name doesn't matter, but we don't want it to be open to cloning an
          # existing public repo that happens to collide with a silly name, if it
          # falls back on trying to clone because the above initialisation broke.
          @UUT = Dependabot::Linguist::Repository.new("./smoke-test/#{file_fetcher}/#{test_config["ecosystem_subdirectory"]}", "Skenvy/dependabot-linguits")
        end

        # Don't bother testing linguist_languages, linguist_cache,
        # file_fetcher_class_per_package_ecosystem, all_sources,
        # linguist_sources, all_ecosystem_classes, all_directories

        it "Locates the expected files with linguist" do
          expect(@UUT.files_per_linguist_language).to eq(test_config["files_per_linguist_language"])
        end

        it "Minifies linguist's files into unique directories" do
          expect(@UUT.directories_per_linguist_language).to eq(test_config["directories_per_linguist_language"])
        end

        it "Guesses at which package manager linguist's files belong to" do
          expect(@UUT.directories_per_package_manager).to eq(test_config["directories_per_package_manager"])
        end

        it "Guesses at which dependabot ecosystem linguist's files belong to" do
          expect(@UUT.directories_per_package_ecosystem[file_fetcher]).to eq(test_config["directories_per_package_ecosystem"])
        end

        it "Combines the list of unique directories that ecosystems will be tested on" do
          expect(@UUT.linguist_directories).to eq(test_config["linguist_directories"])
        end

        it "Validates which directories satisfy THIS ecosystem's file fetcher" do
          if test_config["directories_per_ecosystem_validated_by_dependabot"]
            expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({"#{file_fetcher}" => test_config["directories_per_ecosystem_validated_by_dependabot"]})
          else
            expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({})
          end
        end

        after(:context) do
          FileUtils.rm_rf("./smoke-test/#{file_fetcher}/#{test_config["ecosystem_subdirectory"]}/.git")
        end
      end
    end
  end
end
