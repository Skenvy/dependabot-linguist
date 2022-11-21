# frozen_string_literal: true

require_relative "linguist/version"
# ::Dependabot::Linguist::Repository, not ::Linguist::Repository,
# although it does wrap ::Linguist::Repository
require_relative "linguist/repository"
require_relative "linguist/dependabot_file_validator"

module Dependabot
  # Provides a patched linguist to use to target dependabot relevant ecosystem blobs.
  module Linguist
  end
end
