# frozen_string_literal: true

require "fileutils"
require "rugged"

RSpec.describe ::Dependabot::Linguist::Repository do
  ECOS = ::Dependabot::Linguist::PackageEcosystems
  # Wrap a repeated context block in an each on a set of configs per ecosystem.
  TEST_CONFIG = ECOS.constants.map { |c| ECOS.const_get c }.to_h { |eco| [eco, []] }.freeze

  # This should validate for all ::Dependabot::Linguist::PackageEcosystems
  TEST_CONFIG["bundler"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["cargo"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["composer"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["docker"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["elm"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["github-actions"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["gitsubmodule"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["gomod"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["gradle"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["maven"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["mix"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["npm"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/", "/removed"]})
  TEST_CONFIG["nuget"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["pip"].append({dir: "pip-compile", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["pip"].append({dir: "pip", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["pip"].append({dir: "pipenv", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["pip"].append({dir: "poetry", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["pub"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})
  TEST_CONFIG["terraform"].append({dir: ".", directories_per_ecosystem_validated_by_dependabot: ["/"]})

  TEST_CONFIG.each do |file_fetcher, test_configs|
    test_configs.each do |test_config|
      context "#{file_fetcher} @ ./smoke-test/#{file_fetcher}/#{test_config[:dir]}/" do
        before(:context) do
          # Path is relative to rspec running from repo root.
          Rugged::Repository.init_at("./smoke-test/#{file_fetcher}/#{test_config[:dir]}")
          @repo = Rugged::Repository.new("./smoke-test/#{file_fetcher}/#{test_config[:dir]}")
          @repo.index.add_all
          commit_author = {:email=>'email@email.com', :time=>Time.now, :name=>'username'}
          Rugged::Commit.create(@repo, :author => commit_author,
              :message => "Rspec auto commit for test", :committer => commit_author,
              :parents => @repo.empty? ? [] : [@repo.head.target].compact,
              :tree => @repo.index.write_tree(@repo), :update_ref => 'HEAD')
          # The name doesn't matter, but we don't want it to be open to cloning an
          # existing public repo that happens to collide with a silly name, if it
          # falls back on trying to clone because the above initialisation broke.
          @UUT = Dependabot::Linguist::Repository.new("./smoke-test/#{file_fetcher}/#{test_config[:dir]}", "Skenvy/dependabot-linguits")
        end

        it "does something useful" do
          expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({"#{file_fetcher}" => test_config[:directories_per_ecosystem_validated_by_dependabot]})
        end

        after(:context) do
          FileUtils.rm_rf("./smoke-test/#{file_fetcher}/#{test_config[:dir]}/.git")
        end
      end
    end
  end
end
