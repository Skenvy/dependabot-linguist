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
## Patching Dependabot
