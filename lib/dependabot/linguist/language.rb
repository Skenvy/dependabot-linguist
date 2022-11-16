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
    # would be too cumbersome.
    VendoredRegexp 
  end
end

# To debug the files being processed, the below two patches which add logging
# comments to the Linguist.detect and Linguist::Repository::compute_stats to
# surface the decisions it's making about why to process or not process.
# They are both under https://github.com/github/linguist/blob/v7.23.0/LICENSE
# Copyright (c) 2017 GitHub, Inc.

# # https://github.com/github/linguist/blob/v7.23.0/lib/linguist.rb#L20-L49
# class << Linguist
#   # Public: Detects the Language of the blob.
#   #
#   # blob - an object that includes the Linguist `BlobHelper` interface;
#   #       see Linguist::LazyBlob and Linguist::FileBlob for examples
#   #
#   # Returns Language or nil.
#   def detect(blob, allow_empty: false)
#     # Bail early if the blob is binary or empty.
#     puts "Linguist::detect -- Detecting language on file #{blob.name}"
#     return nil if blob.likely_binary? || blob.binary? || (!allow_empty && blob.empty?)
#     Linguist.instrument("linguist.detection", :blob => blob) do
#       # Call each strategy until one candidate is returned.
#       languages = []
#       returning_strategy = nil
#       STRATEGIES.each do |strategy|
#         returning_strategy = strategy
#         candidates = Linguist.instrument("linguist.strategy", :blob => blob, :strategy => strategy, :candidates => languages) do
#           strategy.call(blob, languages)
#         end
#         if candidates.size == 1
#           languages = candidates
#           break
#         elsif candidates.size > 1
#           # More than one candidate was found, pass them to the next strategy.
#           languages = candidates
#         else
#           # No candidates, try the next strategy
#         end
#       end
#       Linguist.instrument("linguist.detected", :blob => blob, :strategy => returning_strategy, :language => languages.first)
#       languages.first
#     end
#   end
# end

# # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/repository.rb#L134-L171
# module Linguist
#   class Repository
#     def compute_stats(old_commit_oid, cache = nil)
#       return {} if current_tree.count_recursive(MAX_TREE_SIZE) >= MAX_TREE_SIZE
#       old_tree = old_commit_oid && Rugged::Commit.lookup(repository, old_commit_oid).tree
#       read_index
#       diff = Rugged::Tree.diff(repository, old_tree, current_tree)
#       # Clear file map and fetch full diff if any .gitattributes files are changed
#       if cache && diff.each_delta.any? { |delta| File.basename(delta.new_file[:path]) == ".gitattributes" }
#         diff = Rugged::Tree.diff(repository, old_tree = nil, current_tree)
#         file_map = {}
#       else
#         file_map = cache ? cache.dup : {}
#       end
#       diff.each_delta do |delta|
#         old = delta.old_file[:path]
#         new = delta.new_file[:path]
#         file_map.delete(old)
#         # next if delta.binary
#         if delta.binary
#           puts "Linguist::Repository::compute_stats -- IGNORE binary file -- #{delta.new_file}"
#           next
#         end
#         if [:added, :modified].include? delta.status
#           # Skip submodules and symlinks
#           mode = delta.new_file[:mode]
#           mode_format = (mode & 0170000)
#           # next if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000
#           if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000
#             puts "Linguist::Repository::compute_stats -- IGNORE invalid mode file -- #{delta.new_file}"
#             next
#           else
#             puts "Linguist::Repository::compute_stats -- Process well behaved file -- #{delta.new_file}"
#           end
#           blob = Linguist::LazyBlob.new(repository, delta.new_file[:oid], new, mode.to_s(8))
#           update_file_map(blob, file_map, new)
#           blob.cleanup!
#         end
#       end
#       file_map
#     end

#     def update_file_map(blob, file_map, key)
#       if blob.include_in_language_stats?
#         puts "Linguist::Repository::update_file_map -- Including in language stats; #{blob.name}"
#         file_map[key] = [blob.language.group.name, blob.size]
#       else
#         puts "Linguist::Repository::update_file_map -- NOT including in language stats; #{blob.name}"
#       end
#     end
#   end
# end

# # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L378-L387
# module Linguist
#   module BlobHelper
#     def include_in_language_stats?
#       if vendored?
#         # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L219-L232
#         # VendoredRegexp from https://github.com/github/linguist/blob/v7.23.0/lib/linguist/vendor.yml
#         # Wrapped by https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L56-L62
#         puts "Linguist::BlobHelper::include_in_language_stats? -- Ignore #{self.name} for being vendored"
#         false
#       elsif documentation?
#         # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L234-L247
#         # DocumentationRegexp from https://github.com/github/linguist/blob/v7.23.0/lib/linguist/documentation.yml
#         # Wrapped by https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L40-L46
#         puts "Linguist::BlobHelper::include_in_language_stats? -- Ignore #{self.name} for being documentation"
#         false
#       elsif generated?
#         # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L350-L360
#         # Wrapped by https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L48-L54
#         puts "Linguist::BlobHelper::include_in_language_stats? -- Ignore #{self.name} for being generated"
#         false
#       else
#         language && ( defined?(detectable?) && !detectable?.nil? ?
#           detectable? :
#           DETECTABLE_TYPES.include?(language.type)
#         )
#       end
#     end
#   end
# end
