# frozen_string_literal: true

require "rugged"
require "linguist/repository"
require_relative "language"
# require_relative "language_to_ecosystem"
# require "dependabot/source"

module Dependabot
  module Linguist
    # LocalRepo substitutes for Linguist::Repository and Dependabot::Source
    class LocalRepo
      def initialize(repo_path, repo_name)
        @repo_path = repo_path
        @repo_name = repo_name
        @repo = Rugged::Repository.new(@repo_path)
        @linguist = ::Linguist::Repository.new(@repo, @repo.head.target_id)
      end

      def linguist_languages
        @linguist.languages
      end

      # def possible_dependabot_ecosystems
      # end
    end
  end
end
