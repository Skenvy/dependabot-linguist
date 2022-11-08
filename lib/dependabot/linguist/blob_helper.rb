# "DETECTABLE_TYPES" locks certain types from being included in stats. Undo that.
# https://github.com/github/linguist/blob/v7.23.0/lib/linguist/blob_helper.rb#L376

# Can't patch the detect function in the entry linguist file, so have to require ALL
# rather than just require 'linguist/blob_helper'
# require 'linguist'

# This is what we could do to remove the dependency on being a DETECTABLE_TYPES.

# module Linguist
#   module BlobHelper
#     # Patch out the possibly falsey "detectable"; 'detect' everything!
#     def include_in_language_stats?
#       !vendored? &&
#       !documentation? &&
#       !generated? &&
#       language # && ( defined?(detectable?) && !detectable?.nil? ?
#       #   detectable? :
#       #   DETECTABLE_TYPES.include?(language.type)
#       # )
#     end
#   end
# end
