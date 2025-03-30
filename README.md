# [dependabot-linguist](https://github.com/Skenvy/dependabot-linguist)
Use [linguist](https://github.com/github/linguist) to check the contents of a **local** repository, and then scan for [dependabot-core](https://github.com/dependabot/dependabot-core) ecosystems relevant to those languages! With the list of [ecosystems](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file#package-ecosystem) present in a repository, add a [dependabot.y[a]ml](https://docs.github.com/en/code-security/dependabot/dependabot-security-updates/configuring-dependabot-security-updates) ([configuration file](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)).
## Getting Started
### [Linguist dependencies](https://github.com/github/linguist#dependencies);
Before installing this gem, which will install the [github-linguist gem](https://rubygems.org/gems/github-linguist), linguists dependencies should be installed. A number of these are enabling [rugged](https://rubygems.org/gems/rugged), so they can't be "ignored" like [dependabot's setup](https://github.com/dependabot/dependabot-core#setup), which _can_ be ignored for the purpose of **this** gem, which only intends to use the [file fetchers](https://github.com/dependabot/dependabot-core/blob/v0.303.0/common/lib/dependabot/file_fetchers/README.md).
```bash
sudo apt-get install build-essential cmake pkg-config libicu-dev zlib1g-dev libcurl4-openssl-dev libssl-dev ruby-dev
```
### Dependabot dependencies;
The `npm`/`yarn` module requires [`corepack`](https://www.npmjs.com/package/corepack), so it will be necessary to install, either with npm or yarn. Ensuring you have the _right version_ of `corepack` is important. Your best bet is to ensure you have the latest version.
```bash
nvm install 22 && nvm use 22 && npm i -g corepack@latest
# you'll need to `nvm use 22` to load that node before running this gem
```
### Install _this_
[To install the latest from RubyGems](https://rubygems.org/gems/dependabot-linguist);
```sh
gem install dependabot-linguist
```
[Or to install from GitHub's hosted gems](https://github.com/Skenvy/dependabot-linguist/packages/1704407);
```sh
gem install dependabot-linguist --source "https://rubygems.pkg.github.com/skenvy"
```
### Or add to the Gemfile
[Add the RubyGems hosted gem](https://rubygems.org/gems/dependabot-linguist) with bundler;
```sh
bundle add dependabot-linguist
```
Or add the following line to your `Gemfile` manually
```ruby
gem "dependabot-linguist", ">= 0.303.0
```
[Add the GitHub hosted gem](https://github.com/Skenvy/dependabot-linguist/packages/1704407);
```ruby
source "https://rubygems.pkg.github.com/skenvy" do
  gem "dependabot-linguist", ">= 0.303.0"
end
```
### Setup external CLIs
If you intend to use `::Dependabot::Linguist::DependabotFileValidator.commit_new_config`, you'll need to also setup the [`gh`](https://cli.github.com/manual/) CLI. You can follow instructions on [cli/cli](https://github.com/cli/cli) to install it, which for the intended use case should be [this guide](https://github.com/cli/cli/blob/trunk/docs/install_linux.md). Once you've installed it, [you'll need to log in](https://cli.github.com/manual/gh_auth_login) prior to running this script, as the credentials are expected to already be in place.

It also expects `git` to be installed and credentialed, for pushing the branch.
## Usage
The two main classes this provides, `::Dependabot::Linguist::Repository` and `::Dependabot::Linguist::DependabotFileValidator`, can be utilised independently, although the intention is that they be utilised together; to discover the contents of a repository that should be watched with a dependabot file by `Repository`, and subsequently using `DependabotFileValidator` to edit an existing, or add a new, dependabot file to watch the directories that were validated earlier. There is also a CLI tool, `dependabot-linguist`, that wraps these classes and surfaces all the available options to them, although adding automated tests for the executable is still a `#TODO`.

The intended end goal is to use this to automatically raise a PR on GitHub with the recommended changes to the `~/.github/dependabot.y[a]ml` file. This is performed by `::Dependabot::Linguist::DependabotFileValidator.commit_new_config`, which utilises Ruby's `Kernel` to run commands in an external shell that perform actions using the `gh` cli, and `git`. If you intend to use these you'll want to follow [Setup external CLIs](https://github.com/Skenvy/dependabot-linguist#setup-external-clis).
### Use the classes in a ruby script, with defaults
```ruby
require "dependabot/linguist"
# Get the list of directories validated for each ecosystem.
@repo_path = "." # "here"
@repo_name = "Skenvy/dependabot-linguist" # If it were evaluating this repo!
@this_repo = ::Dependabot::Linguist::Repository.new(@repo_path, @repo_name)
@this_repo.directories_per_ecosystem_validated_by_dependabot
# Use this list to see what the recommended update to the existing (or add new) config is.
@validator = ::Dependabot::Linguist::DependabotFileValidator.new(repo_path)
@validator.load_ecosystem_directories(incoming: @this_repo.directories_per_ecosystem_validated_by_dependabot)
@validator.new_config
# If you trust it to write the new config;
@validator.write_new_config
# If you have git, and the gh cli tool installed and configured, and trust this
# tool to handle branching, commiting, pushing, and raising a pull request;
@validator.commit_new_config
```
### Use the CLI
If you installed this with **bundler**, you'll need to preface these with `bundle exec`.
```bash
# With no flags, it'll run "here", and print out the recommended new config.
dependabot-linguist
# With -w, it'll write the file. You can also specify a path.
dependabot-linguist ../../some/other/repo -w
# With -x, you'll be trusting it to raise a pull request of the recommended config.
# You can also specify a name, which will be required if there isn't a "origin" remote.
dependabot-linguist ../../some/other/repo Username/Reponame -x
```
### Configure
A yaml config file can be placed at `~/.github/.dependabot-linguist`. See this [example](https://github.com/Skenvy/dependabot-linguist/blob/main/.github/.dependabot-linguist). Although it's a dotfile, it'll be read by rugged, so for it to be utilised it should be checked in. The options available to this configuration file currently are;
#### `ignore`
The below options, `directory` and `ecosystem` are not mutually exclusive, and can be mixed, according to what top level catagorisation requires less verbose configuration, if you want to ignore many directories for one or two ecosystems, or many ecosystems for one or two directories!
##### `directory`
To ignore some ecosystems per directory, you can add
```yaml
ignore:
  directory:
    /path/to/somewhere:
    - some_ecosystem
```
##### `ecosystem`
To ignore some directories per ecosystem, you can add
```yaml
ignore:
  ecosystem:
    some_other_ecosystem:
    - /path/to/somewhere_else
```
## [RDoc generated docs](https://skenvy.github.io/dependabot-linguist/)
## Developing
### Install Ruby
You will need to install [rvm](https://rvm.io/) and one of its [ruby binaries](https://rvm.io/binaries/).

You'll also need to set the `RVM_DIR` in your shell profile e.g. [like this](https://github.com/Skenvy/dotfiles/blob/1de61272c588a30b634a03a7d304ef51e40c72f1/.bash_login#L17). RVM will set some basic initialisation in your shell profile, but changing what it sets to instead use `RVM_DIR` like this allows you to install it somewhere other than the default.

The `make setup` in [first time setup](#the-first-time-setup) will install the intended development version for you, but it might not be a precompiled binary, depending on your OS and architecture ~ if it isn't precompiled, contributing your time in compiling to [publish the binary for rvm](https://github.com/rvm/rvm/issues/4921) is probably more worth your time than this lol.

RVM is locally how we manage proctoring the ruby environment. It is not on the [github runners](https://github.com/actions/runner-images), so the make invocations in the workflows set the RVM proctors empty. If you want to manage your own ruby installs you can set `_=''` on each `make ...`.

You should also read the requirements for the gems this uses, see [Linguist dependencies](#linguist-dependencies) and [Dependabot dependencies](#dependabot-dependencies). `Linguist`'s can be acquired with `make preinit` done once. 
### Install Corepack
[Dependabot dependencies](#dependabot-dependencies) are managed in this project via [`nvm`](https://github.com/nvm-sh/nvm), so `corepack` can be loaded into every subshell the `Makefile` spawns. If you don't want to install `nvm` but would rather manage your own `corepack` install, set `__=''` on each `make ...`.

For the currently targetted version of `dependabot` that this is using, the existing reference versions of `corepack` are;
* [bun/Dockerfile](https://github.com/dependabot/dependabot-core/blob/v0.303.0/bun/Dockerfile#L4)
* [npm_and_yarn/Dockerfile](https://github.com/dependabot/dependabot-core/blob/v0.303.0/npm_and_yarn/Dockerfile#L4)

Both currently (as of writing) set their `corepack` version to `0.31.0`. However, it's possible for the changes in versions in `corepack` to outstrip the rate of changes of this gem, so don't rely on _this_ to determine what the most suitable version of `corepack` is.

> [!CAUTION]
> `make setup` / `initialise` / `initialise_corepack` will install to your _global_ `node`. If you're using the recommended `nvm` then each `node` install can be treated eseentially ephemeral. If you aren't using `nvm`, this might hijack your global `corepack` install.
### The first time setup
If you have `rvm` and `nvm` installed and you have `apt`, you should be able to;
```sh
git clone https://github.com/Skenvy/dependabot-linguist.git && cd dependabot-linguist && make preinit && make setup
```
### Iterative development
The majority of `make` recipes for this are just wrapping a `bundle` invocation of `rake`.
* `make docs` will recreate the RDoc docs
* `make test` will run the RSpec tests.
* `make lint` will run the RuboCop linter.
