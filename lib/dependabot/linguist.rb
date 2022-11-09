# frozen_string_literal: true

require "rugged"
require "linguist"

require_relative "linguist/version"
require_relative "linguist/local_repo"
require_relative "file_fetchers/base"

module Dependabot
  # Provides a patched linguist to use to target dependabot relevant ecosystem blobs.
  module Linguist
  end
end
