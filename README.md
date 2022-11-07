# [dependabot-linguist](https://github.com/Skenvy/dependabot-linguist)
Use [linguist](https://github.com/github/linguist) to check the contents of a repository, and then scan for [dependabot-core](https://github.com/dependabot/dependabot-core) ecosystems relevant to those languages!
## Getting Started
[To install the latest from RubyGems](https://rubygems.org/gems/dependabot-linguist);
```sh
gem install dependabot-linguist
```
[Or to install from GitHub's hosted gems](https://github.com/Skenvy/dependabot-linguist/packages/TODO);
```sh
gem install dependabot-linguist --source "https://rubygems.pkg.github.com/skenvy"
```
### Add to the Gemfile
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
