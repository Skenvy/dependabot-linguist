# frozen_string_literal: true

# The language yaml file https://github.com/github/linguist/blob/v7.23.0/lib/linguist/languages.yml
# is read in at https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L495 and
# loaded as yaml at https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L502
# A "group" option https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L540 --
# will become the `:group_name` and then used in initialisation to set the `@group_name`,
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L293-L299 --
# which is then used to determine the `@group`. Do away with groups by patching group to return
# the `self.name` that would be assigned to the group_name if there was no group option input.

# module Linguist
#   class Language
#     def group
#       @group ||= Language.find_by_name(self.name)
#     end
#   end
# end

# Alternatively, because this would surface a lot of extra information,
# we can open up selectively the ecosystem specific languages.

require "linguist"

module Linguist
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
    patch_file = File.expand_path("../languages_to_patch.txt", __FILE__)
    languages_to_patch = File.readlines(patch_file, chomp: true)

    languages_to_patch.each do |lang_name|
      @name_index[lang_name.downcase].patch_for_dependabot_linguist
    end
  end
end
