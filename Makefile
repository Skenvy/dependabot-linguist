.PHONY: setup setup_github clean docs docs_view demo test build install push_rubygems push_github
SHELL:=/bin/bash

# Assumes `gem install bundler`
setup:
	bundle install

setup_github:
	gem install keycutter

clean:
	bundle exec rake clean
	bundle exec rake clobber
	rm -f dependabot-linguist-*.gem
	rm -f pkg/dependabot-linguist-*.gem

docs: clean
	bundle exec rake rdoc

# http://localhost:8080/
docs_view: docs
	ruby -run -e httpd doc

demo:
	bundle exec ruby demo_script.rb

# default (just `rake`) is spec + rubocop, but be pedantic in case this changes.
test: clean
	bundle exec rake spec
	bundle exec rake rubocop

# We can choose from `gem build dependabot-linguist.gemspec` or `bundle exec rake build`.
# The gem build command creates a ./dependabot-linguist-$VER.gem file, and the rake build
# (within bundle context) creates a ./pkg/dependabot-linguist-$VER.gem file.
build: test
	bundle exec rake build

# --user-install means no need for sudo or expectation of
# changing the folder permissions or access but will need
# "gem environment"'s "USER INSTALLATION DIRECTORY" (+ "/bin")
# in the PATH to then use any gem executables that it may contain.
install: build
	gem install ./pkg/dependabot-linguist-$$(grep lib/dependabot/linguist/version.rb -e "VERSION" | cut -d \" -f 2).gem --user-install

# Will be run with one "pkg/dependabot-linguist-*.gem" file
# rubygems_api_key and the rubygems host are the default
push_rubygems:
	gem push $$(find . | grep pkg/dependabot-linguist-*.gem)

# Will be run with one "pkg/dependabot-linguist-*.gem" file
push_github:
	gem push --key github --host https://rubygems.pkg.github.com/Skenvy $$(find . | grep pkg/dependabot-linguist-*.gem)
