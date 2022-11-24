# Devlog
## Patching Linguist
### Surfacing _all **relevant** languages_
A decision on how to patch linguist to surface "all _relevant_ languages" could either be greedy, by making it such that **every** language was surfaced, or minimal so that only a supplied list of languages that would not otherwise, are surfaced. For the greedy approach to patching version `7.23.0`, we would two patches. A good example for why this is necessary is that both gradle and maven are `type: data`, and maven is also `group: XML`. Normally, this would prevent either of these from being reported by linguist unless globs to them were referenced with `linguist-detectable` in a `.gitattributes` file; as explained in [Overrides](https://github.com/github/linguist/blob/v7.23.0/docs/overrides.md). Rather that interact with these, as a repo might include its own `.gitattributes` file, and there is some (?) discussion around adding a "build configuration"-esque type, at a **minimum** a patch is needed to "ungroup" something like maven, that even if set to be detectable, would report itself as "XML" in the output.

Firstly, we'd need to patch the [`Linguist::BlobHelper::include_in_language_stats`](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb) to no longer rely on [`DETECTABLE_TYPES`](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L376) to avoid surfacing `:type`'s that aren't `:programming` or `:markup`. Something along the lines of;
```ruby
require 'linguist'

module Linguist
  module BlobHelper
    # Patch out the possibly falsey "detectable"; 'detect' everything!
    def include_in_language_stats?
      !vendored? &&
      !documentation? &&
      !generated? &&
      language # && ( defined?(detectable?) && !detectable?.nil? ?
      #   detectable? :
      #   DETECTABLE_TYPES.include?(language.type)
      # )
    end
  end
end
```

The other change we'd need to make would be in how the `group` of a language is determined. The [language yaml file](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/languages.yml) is [read in](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L495) and [loaded as yaml](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L502). A ["group" option](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L540) will become the `:group_name` and then [used in initialisation to set the `@group_name`](https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L293-L299), which is then used to determine the `@group`. We could do away with groups by patching `Linguist::Language::group` to return the `self.name` that would be assigned to the `group_name` if there was no `group` option input. Something like;
```ruby
module Linguist
  class Language
    def group
      @group ||= Language.find_by_name(self.name)
    end
  end
end
```
The alternatively to both of these that is more minimal, is to selectively set the `@type` to `:programming` and `@group_name` to `self.name`.
## Debugging Linguist
To debug (**printf debugging** tbf tho) certain parts of Linguist's behaviour, these patches, which add `puts` lines to module or class functions, are significant duplications of Linguist's code, so their addition would be under [Linguist's MIT License @v7.23.0](https://github.com/github/linguist/blob/v7.23.0/LICENSE).

They are all includded under `Copyright (c) 2017 GitHub, Inc.`.
### Linguist.detect
```ruby
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist.rb#L20-L49
class << Linguist
  # Public: Detects the Language of the blob.
  #
  # blob - an object that includes the Linguist `BlobHelper` interface;
  #       see Linguist::LazyBlob and Linguist::FileBlob for examples
  #
  # Returns Language or nil.
  def detect(blob, allow_empty: false)
    # Bail early if the blob is binary or empty.
    puts "Linguist::detect -- Detecting language on file #{blob.name}"
    return nil if blob.likely_binary? || blob.binary? || (!allow_empty && blob.empty?)
    Linguist.instrument("linguist.detection", :blob => blob) do
      # Call each strategy until one candidate is returned.
      languages = []
      returning_strategy = nil
      STRATEGIES.each do |strategy|
        returning_strategy = strategy
        candidates = Linguist.instrument("linguist.strategy", :blob => blob, :strategy => strategy, :candidates => languages) do
          strategy.call(blob, languages)
        end
        if candidates.size == 1
          languages = candidates
          break
        elsif candidates.size > 1
          # More than one candidate was found, pass them to the next strategy.
          languages = candidates
        else
          # No candidates, try the next strategy
        end
      end
      Linguist.instrument("linguist.detected", :blob => blob, :strategy => returning_strategy, :language => languages.first)
      languages.first
    end
  end
end
```
### Linguist::Repository.compute_stats
```ruby
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist/repository.rb#L134-L171
module Linguist
  class Repository
    def compute_stats(old_commit_oid, cache = nil)
      return {} if current_tree.count_recursive(MAX_TREE_SIZE) >= MAX_TREE_SIZE
      old_tree = old_commit_oid && Rugged::Commit.lookup(repository, old_commit_oid).tree
      read_index
      diff = Rugged::Tree.diff(repository, old_tree, current_tree)
      # Clear file map and fetch full diff if any .gitattributes files are changed
      if cache && diff.each_delta.any? { |delta| File.basename(delta.new_file[:path]) == ".gitattributes" }
        diff = Rugged::Tree.diff(repository, old_tree = nil, current_tree)
        file_map = {}
      else
        file_map = cache ? cache.dup : {}
      end
      diff.each_delta do |delta|
        old = delta.old_file[:path]
        new = delta.new_file[:path]
        file_map.delete(old)
        # next if delta.binary
        if delta.binary
          puts "Linguist::Repository::compute_stats -- IGNORE binary file -- #{delta.new_file}"
          next
        end
        if [:added, :modified].include? delta.status
          # Skip submodules and symlinks
          mode = delta.new_file[:mode]
          mode_format = (mode & 0170000)
          # next if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000
          if mode_format == 0120000 || mode_format == 040000 || mode_format == 0160000
            puts "Linguist::Repository::compute_stats -- IGNORE invalid mode file -- #{delta.new_file}"
            next
          else
            puts "Linguist::Repository::compute_stats -- Process well behaved file -- #{delta.new_file}"
          end
          blob = Linguist::LazyBlob.new(repository, delta.new_file[:oid], new, mode.to_s(8))
          update_file_map(blob, file_map, new)
          blob.cleanup!
        end
      end
      file_map
    end
  end
end
```
### Linguist::Repository.update_file_map
```ruby
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist/repository.rb#L173-L177
module Linguist
  class Repository
    def update_file_map(blob, file_map, key)
      if blob.include_in_language_stats?
        puts "Linguist::Repository::update_file_map -- Including in language stats; #{blob.name}"
        file_map[key] = [blob.language.group.name, blob.size]
      else
        puts "Linguist::Repository::update_file_map -- NOT including in language stats; #{blob.name}"
      end
    end
  end
end
```
### Linguist::BlobHelper.include_in_language_stats?
```ruby
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L378-L387
module Linguist
  module BlobHelper
    def include_in_language_stats?
      if vendored?
        # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L219-L232
        # VendoredRegexp from https://github.com/github/linguist/blob/v7.23.0/lib/linguist/vendor.yml
        # Wrapped by https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L56-L62
        puts "Linguist::BlobHelper::include_in_language_stats? -- Ignore #{self.name} for being vendored"
        false
      elsif documentation?
        # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L234-L247
        # DocumentationRegexp from https://github.com/github/linguist/blob/v7.23.0/lib/linguist/documentation.yml
        # Wrapped by https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L40-L46
        puts "Linguist::BlobHelper::include_in_language_stats? -- Ignore #{self.name} for being documentation"
        false
      elsif generated?
        # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L350-L360
        # Wrapped by https://github.com/github/linguist/blob/v7.23.0/lib/linguist/lazy_blob.rb#L48-L54
        puts "Linguist::BlobHelper::include_in_language_stats? -- Ignore #{self.name} for being generated"
        false
      else
        language && ( defined?(detectable?) && !detectable?.nil? ?
          detectable? :
          DETECTABLE_TYPES.include?(language.type)
        )
      end
    end
  end
end
```
## Patching Dependabot

# Other comments to edit into here
`bin/console`
```rb
# https://github.com/github/linguist/issues/1205
# https://github.com/github/linguist/issues/3229
# Linguists dev's wont implement an option to include submodules in a scan, so
# the best option without adding that functionality in a patch is to keep the
# smoke-test repo parallel to this one, and run the following to test that.
```
