# frozen_string_literal: true

require "linguist"

module Linguist
  # Patches the class Linguist::Language to selectively "ungroup"
  # and change the type of "languages" to a detectable type.
  # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb
  class Language
    def ungroup_language
      @group_name = self.name
      self
    end

    def convert_to_detectable_type
      @type = :programming
    end

    def patch_for_dependabot_linguist
      self.ungroup_language.convert_to_detectable_type
    end

    # A list of dependabot relevant ecosystem linguist languages
    patch_file = File.expand_path("./languages_to_patch.txt", __dir__)
    languages_to_patch = File.readlines(patch_file, chomp: true)

    languages_to_patch.each do |lang_name|
      @name_index[lang_name.downcase].patch_for_dependabot_linguist
    end
  end
end
