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

################################################################################

# frozen_string_literal: true

# Chunks of this replicate the existing code in Linguist, which is under this
# https://github.com/github/linguist/blob/v7.23.0/LICENSE -- MIT License; with
# Copyright (c) 2017 GitHub, Inc.

# require "linguist" # comes with yaml

# module Linguist
#   # Patches the class Linguist::Language by discarding all the rules created in
#   # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb
#   # and instead replaces them with only those relevant to dependabot ecosystems.
#   class Language
#     # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L25-L33
#     @languages          = []
#     @index              = {}
#     @name_index         = {}
#     @alias_index        = {}
#     @language_id_index  = {}
#     @extension_index    = Hash.new { |h,k| h[k] = [] }
#     @interpreter_index  = Hash.new { |h,k| h[k] = [] }
#     @filename_index     = Hash.new { |h,k| h[k] = [] }
#   end

#   # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L490-L493
#   samples = Samples.load_samples
#   extensions = samples['extnames']
#   interpreters = samples['interpreters']
#   popular = YAML.load_file(File.expand_path("./popular.yaml", __dir__))

#   # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L495-L503
#   # A list of dependabot relevant ecosystem linguist languages
#   dependabot_languages_yml  = File.expand_path("./dependabot_languages.yaml",  __dir__)
#   dependabot_languages = YAML.load_file(dependabot_languages_yml)

#   # https://github.com/github/linguist/blob/v7.23.0/lib/linguist/language.rb#L505-L547
#   dependabot_languages.each do |name, options|
#     options['extensions']   ||= []
#     options['interpreters'] ||= []
#     options['filenames']    ||= []
#     if extnames = extensions[name]
#       extnames.each do |extname|
#         if !options['extensions'].index { |x| x.downcase.end_with? extname.downcase }
#           warn "#{name} has a sample with extension (#{extname.downcase}) that isn't explicitly defined in languages.yml"
#           options['extensions'] << extname
#         end
#       end
#     end
#     interpreters ||= {}
#     if interpreter_names = interpreters[name]
#       interpreter_names.each do |interpreter|
#         if !options['interpreters'].include?(interpreter)
#           options['interpreters'] << interpreter
#         end
#       end
#     end
#     Language.create(
#       :name              => name,
#       :fs_name           => options['fs_name'],
#       :color             => options['color'],
#       :type              => options['type'],
#       :aliases           => options['aliases'],
#       :tm_scope          => options['tm_scope'],
#       :ace_mode          => options['ace_mode'],
#       :codemirror_mode   => options['codemirror_mode'],
#       :codemirror_mime_type => options['codemirror_mime_type'],
#       :wrap              => options['wrap'],
#       :group_name        => options['group'],
#       :language_id       => options['language_id'],
#       :extensions        => Array(options['extensions']),
#       :interpreters      => options['interpreters'].sort,
#       :filenames         => options['filenames'],
#       :popular           => popular.include?(name)
#     )
#   end
# end

################################################################################

module Linguist
  class Classifier
    def self.classify(db, tokens, languages = nil)
      puts "CLASSIFIER INTERNAL -- Starting with Tokens #{tokens}"
      puts "CLASSIFIER INTERNAL -- Languages before #{languages}"
      languages ||= db['languages'].keys
      puts "CLASSIFIER INTERNAL -- Languages after #{languages}"
      new(db).classify(tokens, languages)
    end

    def classify(tokens, languages)
      return [] if tokens.nil? || languages.empty?
      tokens = Tokenizer.tokenize(tokens) if tokens.is_a?(String)
      scores = {}

      debug_dump_all_tokens(tokens, languages) if verbosity >= 2

      counts = Hash.new(0)
      tokens.each { |tok| counts[tok] += 1 }
      languages.each do |language|
        puts "CLASSIFY INTERNAL -- Iterating language #{language}"
        puts @tokens[language]
        scores[language] = tokens_probability(counts, language) + language_probability(language)
        debug_dump_probabilities(counts, language, scores[language]) if verbosity >= 1
      end

      scores.sort { |a, b| b[1] <=> a[1] }.map { |score| [score[0], score[1]] }
    end

    def tokens_probability(counts, language)
      sum = 0
      counts.each do |token, count|
        puts "TOKENS_PROBABILITY INTERNAL -- Iterating token #{token}, #{count}"
        sum += count * token_probability(token, language)
      end
      sum
    end

    def token_probability(token, language)
      puts @tokens[language].nil?
      count = @tokens[language][token]
      if count.nil? || count == 0
        # This is usually the most common case, so we cache the result.
        @unknown_logprob
      else
        Math.log(count.to_f / @language_tokens[language].to_f)
      end
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
