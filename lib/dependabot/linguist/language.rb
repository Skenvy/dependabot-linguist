# frozen_string_literal: true

# require "linguist"

# module Linguist
#   # Patches the class Linguist::Language to selectively "ungroup"
#   # and change the type of "languages" to a detectable type.
#   # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb
#   class Language
#     def ungroup_language
#       @group_name = self.name
#       self
#     end

#     def convert_to_detectable_type
#       @type = :programming
#     end

#     def patch_for_dependabot_linguist
#       self.ungroup_language.convert_to_detectable_type
#     end

#     # A list of dependabot relevant ecosystem linguist languages
#     patch_file = File.expand_path("./languages_to_patch.txt", __dir__)
#     languages_to_patch = File.readlines(patch_file, chomp: true)

#     languages_to_patch.each do |lang_name|
#       @name_index[lang_name.downcase].patch_for_dependabot_linguist
#     end
#   end
# end

################################################################################

# frozen_string_literal: true

# Chunks of this replicate the existing code in Linguist, which is under this
# https://github.com/github/linguist/blob/v7.23.0/LICENSE -- MIT License; with
# Copyright (c) 2017 GitHub, Inc.

require "linguist" # comes with yaml

module Linguist
  # Patches the class Linguist::Language by discarding all the rules created in
  # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb
  # and instead replaces them with only those relevant to dependabot ecosystems.
  class Language
    # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L25-L33
    @languages          = []
    @index              = {}
    @name_index         = {}
    @alias_index        = {}
    @language_id_index  = {}
    @extension_index    = Hash.new { |h,k| h[k] = [] }
    @interpreter_index  = Hash.new { |h,k| h[k] = [] }
    @filename_index     = Hash.new { |h,k| h[k] = [] }
  end

  # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L490-L493
  samples = Samples.load_samples
  extensions = samples['extnames']
  interpreters = samples['interpreters']
  popular = YAML.load_file(File.expand_path("./popular.yaml", __dir__))

  # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L495-L503
  # A list of dependabot relevant ecosystem linguist languages
  dependabot_languages_yml  = File.expand_path("./dependabot_languages.yaml",  __dir__)
  dependabot_languages = YAML.load_file(dependabot_languages_yml)

  # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L505-L547
  dependabot_languages.each do |name, options|
    options['extensions']   ||= []
    options['interpreters'] ||= []
    options['filenames']    ||= []
    if extnames = extensions[name]
      extnames.each do |extname|
        if !options['extensions'].index { |x| x.downcase.end_with? extname.downcase }
          warn "#{name} has a sample with extension (#{extname.downcase}) that isn't explicitly defined in languages.yml"
          options['extensions'] << extname
        end
      end
    end
    interpreters ||= {}
    if interpreter_names = interpreters[name]
      interpreter_names.each do |interpreter|
        if !options['interpreters'].include?(interpreter)
          options['interpreters'] << interpreter
        end
      end
    end
    Language.create(
      :name              => name,
      :fs_name           => options['fs_name'],
      :color             => options['color'],
      :type              => options['type'],
      :aliases           => options['aliases'],
      :tm_scope          => options['tm_scope'],
      :ace_mode          => options['ace_mode'],
      :codemirror_mode   => options['codemirror_mode'],
      :codemirror_mime_type => options['codemirror_mime_type'],
      :wrap              => options['wrap'],
      :group_name        => options['group'],
      :language_id       => options['language_id'],
      :extensions        => Array(options['extensions']),
      :interpreters      => options['interpreters'].sort,
      :filenames         => options['filenames'],
      :popular           => popular.include?(name)
    )
  end
end

################################################################################

class << Linguist
  def detect(blob, allow_empty: false)
    # Bail early if the blob is binary or empty.
    return nil if blob.likely_binary? || blob.binary? || (!allow_empty && blob.empty?)

    Linguist.instrument("linguist.detection", :blob => blob) do
      # Call each strategy until one candidate is returned.
      languages = []
      returning_strategy = nil
      # puts ""
      STRATEGIES.each do |strategy|
        # if blob.name == "actions/action.yaml"
          puts "DETECT INTENRAL - Blob #{blob.name} with strat #{strategy}, starting with languages #{languages}"
        # end
        returning_strategy = strategy
        candidates = Linguist.instrument("linguist.strategy", :blob => blob, :strategy => strategy, :candidates => languages) do
          strategy.call(blob, languages)
        end
        if candidates.size == 1
          languages = candidates
          # if blob.name == "actions/action.yaml"
            puts "DETECT INTENRAL - Blob #{blob.name} with strat #{strategy}, finished with languages #{languages}"
          # end
          break
        elsif candidates.size > 1
          # More than one candidate was found, pass them to the next strategy.
          languages = candidates
        else
          # No candidates, try the next strategy
        end
      end
      puts "BROKE OUT"
      Linguist.instrument("linguist.detected", :blob => blob, :strategy => returning_strategy, :language => languages.first)

      languages.first
    end
  end
end

# require 'linguist/repository'
# require 'linguist/samples'
# require 'linguist/shebang'
# require 'linguist/version'
# require 'linguist/strategy/manpage'
# require 'linguist/strategy/xml'

# module Linguist
#   STRATEGIES = [
#     Linguist::Strategy::Modeline,
#     Linguist::Strategy::Filename,
#     Linguist::Shebang,
#     Linguist::Strategy::Extension,
#     Linguist::Strategy::XML,
#     Linguist::Strategy::Manpage,
#     Linguist::Heuristics,
#     Linguist::Classifier
#   ]
# end
