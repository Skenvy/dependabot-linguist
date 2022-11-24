# frozen_string_literal: true

# All the entries in this file are for facilitating the journey of starting with
# a list of languages detected by linguist; to travel via the list of "package
# managers" -> "package ecosystems", to then use those "package ecosystems" to
# yield the set of keys given to the file_fetchers register function.
#
# That is to say; going from the linguist languages to the
# list of file_fetcher classes that should be checked against!

require_relative "contexts_applied"

module Dependabot
  module Linguist # rubocop:disable Style/Documentation
    # Returns the set of package managers
    # mapped to in LANGUAGE_TO_PACKAGE_MANAGER
    def self.linguist_languages_to_package_managers(languages)
      package_managers = []
      languages.each do |language|
        unless LANGUAGE_TO_PACKAGE_MANAGER[language].nil?
          if LANGUAGE_TO_PACKAGE_MANAGER[language].is_a?(Array)
            package_managers |= LANGUAGE_TO_PACKAGE_MANAGER[language]
          else
            package_managers |= [LANGUAGE_TO_PACKAGE_MANAGER[language]]
          end
        end
      end
      package_managers
    end

    # Returns the set of package ecosystems mapped
    # to in PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM
    def self.package_managers_to_package_ecosystems(package_managers)
      package_ecosystems = []
      package_managers.each do |package_manager|
        unless PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM[package_manager].nil?
          package_ecosystems |= [PACKAGE_MANAGER_TO_PACKAGE_ECOSYSTEM[package_manager]]
        end
      end
      package_ecosystems
    end

    # Returns the set of file fetcher registry keys mapped
    # to in PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY
    def self.package_ecosystems_to_file_fetcher_registry_keys(package_ecosystems)
      file_fetcher_registry_keys = []
      package_ecosystems.each do |package_ecosystem|
        unless PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[package_ecosystem].nil?
          file_fetcher_registry_keys |= [PACKAGE_ECOSYSTEM_TO_FILE_FETCHERS_REGISTRY_KEY[package_ecosystem]]
        end
      end
      file_fetcher_registry_keys
    end
  end
end
