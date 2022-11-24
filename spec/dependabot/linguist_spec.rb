# frozen_string_literal: true

RSpec.describe Dependabot::Linguist do
  it "has a version number" do
    expect(Dependabot::Linguist::VERSION).not_to be nil
  end
end
