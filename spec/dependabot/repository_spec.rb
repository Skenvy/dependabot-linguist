# frozen_string_literal: true

require "rugged"

RSpec.describe ::Dependabot::Linguist::Repository do
  it "has a version number" do
    expect(Dependabot::Linguist::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(false)
  end

  test_config = {}

  # This should validate for all ::Dependabot::Linguist::PackageEcosystems
  # it "validates all ecosystems" do
  test_config["bundler"] = ["/"]
  test_config["cargo"] = ["/"]
  test_config["composer"] = ["/"]
  test_config["docker"] = ["/"]
  test_config["elm"] = ["/"]
  test_config["github-actions"] = ["/"]
  test_config["gitsubmodule"] = ["/"]
  test_config["gomod"] = ["/"]
  test_config["gradle"] = ["/"]
  test_config["maven"] = ["/"]
  test_config["mix"] = ["/"]
  test_config["npm"] = ["/", "/removed"]
  test_config["nuget"] = ["/"]
  test_config["pip"] = ["/pip-compile", "/pip", "/pipenv", "/poetry"]
  test_config["pub"] = ["/"]
  test_config["terraform"] = ["/"]
  # end

  ::Dependabot::Linguist::PackageEcosystems.constants.each do |file_fetcher_c|
    file_fetcher = ::Dependabot::Linguist::PackageEcosystems.const_get file_fetcher_c
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
        expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({"#{file_fetcher}" => test_config[file_fetcher]})
      end
    end
  end
end
