# [dependabot-linguist](https://github.com/Skenvy/dependabot-linguist)
Use [linguist](https://github.com/github/linguist) to check the contents of a **local** repository, and then scan for [dependabot-core](https://github.com/dependabot/dependabot-core) ecosystems relevant to those languages! With the list of [ecosystems](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file#package-ecosystem) present in a repository, add a [dependabot.y[a]ml](https://docs.github.com/en/code-security/dependabot/dependabot-security-updates/configuring-dependabot-security-updates) ([configuration file](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)).
## Getting Started
### [Linguist dependencies](https://github.com/github/linguist#dependencies);
Before installing this gem, which will install the [github-linguist gem](https://rubygems.org/gems/github-linguist), linguists dependencies should be installed. A number of these are enabling [rugged](https://rubygems.org/gems/rugged), so they can't be "ignored" like [dependabot's setup](https://github.com/dependabot/dependabot-core#setup), which _can_ be ignored for the purpose of **this** gem, which only intends to use the [file fetchers](https://github.com/dependabot/dependabot-core/blob/v0.212.0/common/lib/dependabot/file_fetchers/README.md).
```bash
sudo apt-get install build-essential cmake pkg-config libicu-dev zlib1g-dev libcurl4-openssl-dev libssl-dev ruby-dev
```
### Install _this_
[To install the latest from RubyGems](https://rubygems.org/gems/dependabot-linguist);
```sh
gem install dependabot-linguist
```
[Or to install from GitHub's hosted gems](https://github.com/Skenvy/dependabot-linguist/packages/TODO);
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
gem "dependabot-linguist", ">= 0.212.0
```
[Add the GitHub hosted gem](https://github.com/Skenvy/dependabot-linguist/packages/TODO);
```ruby
source "https://rubygems.pkg.github.com/skenvy" do
  gem "dependabot-linguist", ">= 0.212.0"
end
```
## Usage
TODO
## [RDoc generated docs](https://skenvy.github.io/dependabot-linguist/)
## Developing
### The first time setup
```sh
git clone https://github.com/Skenvy/dependabot-linguist.git && cd dependabot-linguist && make setup
```
### Iterative development
The majority of `make` recipes for this are just wrapping a `bundle` invocation of `rake`.
* `make docs` will recreate the RDoc docs
* `make test` will run both the RSpec tests and the RuboCop linter.
