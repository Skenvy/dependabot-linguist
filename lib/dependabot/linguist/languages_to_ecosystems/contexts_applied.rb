# frozen_string_literal: true

# Take the list of contextually relevant reasons to map a "linguist language"
# to a "package manager" and apply them to the list of all languages.

require "yaml"
require_relative "contexts"

module Dependabot
  module Linguist # rubocop:disable Style/Documentation
    languages_yaml = File.expand_path("./languages.yaml", __dir__)
    languages = YAML.load_file(languages_yaml)

    # LANGUAGE_TO_PACKAGE_MANAGER should map any language linguist can discover,
    # according to the "languages detected by linguist" link at the top, to a
    # corresponding GitHub dependabot package manager.
    #
    # Any language listed below could be surfaced by being added
    # to the file lib/dependabot/linguist/languages_to_patch.txt,
    # so they should exist in this map.
    LANGUAGE_TO_PACKAGE_MANAGER = languages.to_h { |name, _| [name, nil] }.tap do |this|
      # Now apply the context rules to "this"
      CONTEXT_RULES.each do |package_manager, context_map|
        context_map.each_value do |linguist_languages|
          linguist_languages.each do |linguist_language|
            if this[linguist_language].nil?
              this[linguist_language] = [package_manager]
            else
              this[linguist_language] |= [package_manager]
            end
          end
        end
      end
    end
  end
end
