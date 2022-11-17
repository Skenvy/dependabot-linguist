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

  module BlobHelper
    # Patch https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L220
    # Need to remove the "(^|/)\.gitmodules$" string (plus one of the adjacent "|") as we
    # can't rely on the gitmodules to be unvendored in a `.gitattributes` and patching
    # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L35-L38 or
    # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L56-L62
    # would be too cumbersome. It also seems easier than duplicating the vendor patterns
    # from https://github.com/github/linguist/blob/v7.23.0/lib/linguist/vendor.yml
    # See https://ruby-doc.org/core-2.7.0/Regexp.html
    VendoredRegexp = Regexp.new(VendoredRegexp.source.gsub("(^|/)\\.gitmodules$|", ""))
    # We also need to remove the "(^|/)\.github/" string (plus one of the adjacent "|"),
    # to capture yaml files under .github/workflows/*.yaml
    VendoredRegexp = Regexp.new(VendoredRegexp.source.gsub("|(^|/)\\.github/", ""))
  end
end
