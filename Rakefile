# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

# The below recommended way to add rdoc to rake from rdoc's site has a lot of
# things it will compain about, and wont work OotB, so use 'rdoc/task' below.
# require 'rdoc/rdoc'
# options = RDoc::Options.new
# # see RDoc::Options
# options.rdoc_include << ["lib/*.rb"]
# rdoc = RDoc::RDoc.new
# rdoc.document options
# # see RDoc::RDoc

# https://ruby.github.io/rdoc/RDocTask.html
# doc is the default output location of the rdoc binary, and is the location
# added in the standard ruby gitignore, but the rake task defaults to ./html
# and we need to use the rdoc_dir option to change it to doc.

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.main = "README.md" # !? README.rdoc ?!
  rdoc.rdoc_files.include("README.md", "lib/dependabot/*.rb", "lib/dependabot/linguist/*.rb")
end
