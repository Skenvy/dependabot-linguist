# frozen_string_literal: true

require "rugged"

RSpec.describe ::Dependabot::Linguist::Repository do
  it "has a version number" do
    expect(Dependabot::Linguist::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(false)
  end

  context "bundler" do
    before(:context) do
      # Path is relative to rspec running from repo root.
      Rugged::Repository.init_at("./smoke-test/bundler")
      @repo = Rugged::Repository.new("./smoke-test/bundler")
      @repo.index.add_all
      commit_author = {:email=>'email@email.com', :time=>Time.now, :name=>'username'}
      Rugged::Commit.create(@repo, :author => commit_author,
          :message => "Rspec auto commit for repository context", :committer => commit_author,
          :parents => @repo.empty? ? [] : [@repo.head.target].compact,
          :tree => @repo.index.write_tree(@repo), :update_ref => 'HEAD')
      # The name doesn't matter, but we don't want it to be open to cloning an
      # existing public repo that happens to collide with a silly name, if it
      # falls back on trying to clone because the above initialisation broke.
      @UUT = Dependabot::Linguist::Repository.new("./smoke-test/bundler", "Skenvy/dependabot-linguits")
    end

    it "does something useful" do
      expect(@UUT.directories_per_ecosystem_validated_by_dependabot).to eq({"bundler" => ["/"]})
    end
  end
end
