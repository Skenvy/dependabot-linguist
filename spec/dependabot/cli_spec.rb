# frozen_string_literal: true

require "aruba/rspec"

HELP_OUT = <<~HELP.strip
Dependabot Linguist v#{::Dependabot::Linguist::VERSION}
Detect dependabot ecosystems present for a given git repository, based off using
linguist to determine the files present, that could be relevant to an ecosystem,
and then verifying that the ecosystem's FileFetcher class is valid on the files.
Usage: dependabot-linguist
       dependabot-linguist <path> <name>
       dependabot-linguist <path> <name> <options>
    -i, --ignore-linguist LEVEL      A number, [0, 1, 2] for "how much to ignore linguist's suggestions".
    -r, --remove-undiscovered        Remove entries in an existing dependabot config that weren't found by this.
    -u, --no-update-existing         By default, existing entries are updated. Use this to toggle that off.
    -m, --minimum-interval INTERVAL  The minimum schedule interval; ["monthly", "weekly", "daily"].
    -l LIMIT,                        Limit dependabot's open PR #. Default 5. 0 to disallow non-security updates.
        --max-open-pull-requests-limit
    -v, --verbose                    Output more information.
    -e, --ecosystem-directories      Print out the list of directories found for each ecosystem.
    -y, --no-yaml                    Turn off the default output -- the updated dependabot yaml.
    -w, --write-file                 Write the new dependabot config to the file.
    -x, --pull-request               Use the external subshell's git/gh cli to commit, push, and PR changes.
    -h, --help                       Show help banner.
HELP

YAML_OUT = <<~YAML.strip
---
version: 2
updates:
- package-ecosystem: github-actions
  directory: "/"
  schedule:
    interval: daily
- package-ecosystem: bundler
  directory: "/"
  schedule:
    interval: weekly
- package-ecosystem: bundler
  directory: "/smoke-test/bundler"
  schedule:
    interval: weekly
- package-ecosystem: bundler
  directory: "/smoke-test/dependabot-file/no-config/bundler"
  schedule:
    interval: weekly
- package-ecosystem: bundler
  directory: "/smoke-test/dependabot-file/over-config/bundler"
  schedule:
    interval: weekly
- package-ecosystem: bundler
  directory: "/smoke-test/dependabot-file/overer-config/bundler"
  schedule:
    interval: weekly
- package-ecosystem: bundler
  directory: "/smoke-test/dependabot-file/partial-config/bundler"
  schedule:
    interval: weekly
- package-ecosystem: cargo
  directory: "/smoke-test/cargo"
  schedule:
    interval: weekly
- package-ecosystem: cargo
  directory: "/smoke-test/dependabot-file/no-config/cargo"
  schedule:
    interval: weekly
- package-ecosystem: cargo
  directory: "/smoke-test/dependabot-file/over-config/cargo"
  schedule:
    interval: weekly
- package-ecosystem: cargo
  directory: "/smoke-test/dependabot-file/overer-config/cargo"
  schedule:
    interval: weekly
- package-ecosystem: cargo
  directory: "/smoke-test/dependabot-file/partial-config/cargo"
  schedule:
    interval: weekly
- package-ecosystem: composer
  directory: "/smoke-test/composer"
  schedule:
    interval: weekly
- package-ecosystem: composer
  directory: "/smoke-test/dependabot-file/no-config/composer"
  schedule:
    interval: weekly
- package-ecosystem: composer
  directory: "/smoke-test/dependabot-file/over-config/composer"
  schedule:
    interval: weekly
- package-ecosystem: composer
  directory: "/smoke-test/dependabot-file/overer-config/composer"
  schedule:
    interval: weekly
- package-ecosystem: composer
  directory: "/smoke-test/dependabot-file/partial-config/composer"
  schedule:
    interval: weekly
- package-ecosystem: docker
  directory: "/smoke-test/docker"
  schedule:
    interval: weekly
- package-ecosystem: elm
  directory: "/smoke-test/elm"
  schedule:
    interval: weekly
- package-ecosystem: github-actions
  directory: "/smoke-test/github-actions/both/yaml"
  schedule:
    interval: weekly
- package-ecosystem: github-actions
  directory: "/smoke-test/github-actions/yaml"
  schedule:
    interval: weekly
- package-ecosystem: gitsubmodule
  directory: "/"
  schedule:
    interval: weekly
- package-ecosystem: gitsubmodule
  directory: "/smoke-test/gitsubmodule"
  schedule:
    interval: weekly
- package-ecosystem: gomod
  directory: "/smoke-test/gomod"
  schedule:
    interval: weekly
- package-ecosystem: gradle
  directory: "/smoke-test/gradle"
  schedule:
    interval: weekly
- package-ecosystem: maven
  directory: "/smoke-test/maven"
  schedule:
    interval: weekly
- package-ecosystem: mix
  directory: "/smoke-test/mix"
  schedule:
    interval: weekly
- package-ecosystem: npm
  directory: "/smoke-test/npm"
  schedule:
    interval: weekly
- package-ecosystem: npm
  directory: "/smoke-test/npm/removed"
  schedule:
    interval: weekly
- package-ecosystem: pip
  directory: "/smoke-test/pip/pip-compile"
  schedule:
    interval: weekly
- package-ecosystem: pip
  directory: "/smoke-test/pip/pip"
  schedule:
    interval: weekly
- package-ecosystem: pip
  directory: "/smoke-test/pip/pipenv"
  schedule:
    interval: weekly
- package-ecosystem: pip
  directory: "/smoke-test/pip/poetry"
  schedule:
    interval: weekly
- package-ecosystem: pub
  directory: "/smoke-test/pub"
  schedule:
    interval: weekly
- package-ecosystem: terraform
  directory: "/smoke-test/terraform"
  schedule:
    interval: weekly
YAML

ECODIRS_OUT = <<~ECODIRS.strip
---
bundler:
- "/"
- "/smoke-test/bundler"
- "/smoke-test/dependabot-file/no-config/bundler"
- "/smoke-test/dependabot-file/over-config/bundler"
- "/smoke-test/dependabot-file/overer-config/bundler"
- "/smoke-test/dependabot-file/partial-config/bundler"
cargo:
- "/smoke-test/cargo"
- "/smoke-test/dependabot-file/no-config/cargo"
- "/smoke-test/dependabot-file/over-config/cargo"
- "/smoke-test/dependabot-file/overer-config/cargo"
- "/smoke-test/dependabot-file/partial-config/cargo"
composer:
- "/smoke-test/composer"
- "/smoke-test/dependabot-file/no-config/composer"
- "/smoke-test/dependabot-file/over-config/composer"
- "/smoke-test/dependabot-file/overer-config/composer"
- "/smoke-test/dependabot-file/partial-config/composer"
docker:
- "/smoke-test/docker"
elm:
- "/smoke-test/elm"
github-actions:
- "/"
- "/smoke-test/github-actions/both/yaml"
- "/smoke-test/github-actions/yaml"
gitsubmodule:
- "/"
- "/smoke-test/gitsubmodule"
gomod:
- "/smoke-test/gomod"
gradle:
- "/smoke-test/gradle"
maven:
- "/smoke-test/maven"
mix:
- "/smoke-test/mix"
npm:
- "/smoke-test/npm"
- "/smoke-test/npm/removed"
pip:
- "/smoke-test/pip/pip-compile"
- "/smoke-test/pip/pip"
- "/smoke-test/pip/pipenv"
- "/smoke-test/pip/poetry"
pub:
- "/smoke-test/pub"
terraform:
- "/smoke-test/terraform"
ECODIRS

RUNNING_IN_WSL = (begin
  `cat /proc/version`
rescue Errno::ENOENT
  ""
end).include? "microsoft"

# The introduction of corepack to support npm file fetcher results in this
# failing on missing npm settings for "/" the root folder of the repo, if
# a package json / lock exists after installing corepack. Just delete them,
# the corepack install is managed by each make call.

Aruba.configure do |config|
  config.exit_timeout = RUNNING_IN_WSL ? 40 : 10
  config.io_wait_timeout = RUNNING_IN_WSL ? 3 : 0.4
end

RSpec.describe "exe/dependabot-linguist", :type => :aruba do # rubocop:disable Style/HashSyntax
  context "Include config in output" do
    it { p "Running in WSL?: #{RUNNING_IN_WSL}" }
    it { p "Aruba Exit Timeout: #{aruba.config.exit_timeout}" }
    it { p "Aruba IO Wait Timeout: #{aruba.config.io_wait_timeout}" }
  end

  context "help message" do
    let(:content) { HELP_OUT }
    before { run_command("dependabot-linguist -h") }
    it { expect(last_command_started).to have_output content }
  end

  context "default yaml" do
    let(:content) { YAML_OUT }
    before { run_command("dependabot-linguist") }
    it { expect(last_command_started).to have_output content }
  end

  context "ecosystem directories" do
    let(:content) { ECODIRS_OUT }
    before { run_command("dependabot-linguist -ey") }
    it { expect(last_command_started).to have_output content }
  end
end
