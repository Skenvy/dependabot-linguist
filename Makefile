# It's assumed you have https://rvm.io/ -- see "Developing" in the README
# https://github.com/Skenvy/dependabot-linguist/blob/main/ruby/README.md#developing

# ruby binaries -- https://rvm.io/binaries/ ~= ubuntu 24 x86
DEVELOPMENT_RUBY_VERSION=ruby-$$(cat ./.ruby-version)
# https://rubygems.org/gems/bundler
DEVELOPMENT_BUNDLER_VERSION=2.6.5
# https://rubygems.org/gems/rubygems-update
DEVELOPMENT_GEMSYS_VERSION=3.6.5

# Instructions to load corepack in all subshells, required by the npm dependabot
# Not part of my standard ruby project makefile, but required for this one lol.
# The gh runners already have a default node installed which is good enough.
DEVELOPMENT_COREPACK_VERSION=0.31.0
NVM=source $$NVM_DIR/nvm.sh && nvm
__=$(NVM) use &&
NPM=$(__) npm
INSTALL_NODE=$(NVM) install $$(cat ./.nvmrc)
INSTALL_COREPACK=$(NPM) i -g corepack@$(DEVELOPMENT_COREPACK_VERSION)

# Back to the standard ruby project makefile config, besides $(__) injected on _
RVM=source "$$RVM_DIR/scripts/rvm" && rvm
INSTALL_RUBY=$(RVM) install "$(DEVELOPMENT_RUBY_VERSION)"
_=$(RVM) use $(DEVELOPMENT_RUBY_VERSION) &&
GEM=$(__) $(_) gem
RUBY=$(__) $(_) ruby
INSTALL_BUNDLER=$(GEM) install bundler -v $(DEVELOPMENT_BUNDLER_VERSION)
UPDATE_RUBYGEMS=$(GEM) update --system $(DEVELOPMENT_GEMSYS_VERSION)
# With multiple bundler versions installed, specify which to use with _ver_
BUNDLE=$(__) $(_) bundle _$(DEVELOPMENT_BUNDLER_VERSION)_
RAKE=$(BUNDLE) exec rake

SHELL:=/bin/bash

.PHONY: preinit initialise_ruby initialise_corepack initialise

# See https://github.com/Skenvy/dependabot-linguist?tab=readme-ov-file#linguist-dependencies
# Packages that need to be installed for native compilation of deps of linguist
# You'll probably need to `sudo make preinit` if setup fails to build some pkgs.
# These should all already be installed on the gh runner.
preinit:
	apt-get install build-essential cmake pkg-config libicu-dev zlib1g-dev libcurl4-openssl-dev libssl-dev ruby-dev

# How to setup for ruby development ~ might require compiling ruby locally.
initialise_ruby:
	$(INSTALL_RUBY)
	$(INSTALL_BUNDLER)
	$(UPDATE_RUBYGEMS)

initialise_corepack:
	$(INSTALL_NODE)
	$(INSTALL_COREPACK)

initialise: initialise_ruby initialise_corepack

.PHONY: freeze unfreeze setup update setup_github clean

freeze:
	$(BUNDLE) config set frozen true

unfreeze:
	$(BUNDLE) config set frozen false

# `--full-index` can be a useful flag on the `bundle install` but the action
# currently doesn't support this https://github.com/ruby/setup-ruby/issues/714
# so if we get an error ~ "revealed dependencies not in the API" we rollback.

setup: initialise freeze
	$(BUNDLE) install

update: initialise unfreeze
	$(BUNDLE) install

setup_github: unfreeze
	$(GEM) install keycutter

clean:
	$(RAKE) clean
	$(RAKE) clobber
	rm -f dependabot-linguist-*.gem
	rm -f pkg/dependabot-linguist-*.gem

.PHONY: docs docs_view demo

docs: clean
	$(RAKE) rdoc

# http://localhost:8080/
docs_view: docs
	$(RUBY) -run -e httpd doc

demo:
	$(BUNDLE) exec ruby demo_script.rb

.PHONY: test lint build install

# default (just `rake`) is spec + rubocop, but be pedantic in case this changes.
test: clean
	$(RAKE) spec

lint: clean
	$(RAKE) rubocop

# We can choose from `gem build dependabot-linguist.gemspec` or `bundle exec rake build`.
# The gem build command creates a ./dependabot-linguist-$VER.gem file, and the rake build
# (within bundle context) creates a ./pkg/dependabot-linguist-$VER.gem file.
build: test lint
	$(RAKE) build

# --user-install means no need for sudo or expectation of
# changing the folder permissions or access but will need
# "gem environment"'s "USER INSTALLATION DIRECTORY" (+ "/bin")
# in the PATH to then use any gem executables that it may contain.
install: build unfreeze
	$(GEM) install ./pkg/dependabot-linguist-$$(grep lib/dependabot/linguist/version.rb -e "VERSION" | cut -d \" -f 2).gem --user-install

.PHONY: push_rubygems push_github

# Will be run with one "pkg/dependabot-linguist-*.gem" file
# rubygems_api_key and the rubygems host are the default
push_rubygems:
	$(GEM) push $$(find . | grep pkg/dependabot-linguist-*.gem)

# Will be run with one "pkg/dependabot-linguist-*.gem" file
push_github:
	$(GEM) push --key github --host https://rubygems.pkg.github.com/Skenvy $$(find . | grep pkg/dependabot-linguist-*.gem)
