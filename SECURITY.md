# Security Policy
## Supported Versions
The `<major>.<minor>.*` versions of this are pinned to the **supported** `<major>.<minor>.*` versions of the gems that are published by the [dependabot-core](https://github.com/dependabot/dependabot-core) repository, centric to the [dependabot-common](https://rubygems.org/gems/dependabot-common) gem, with any required patches applied to each supported minor version.
* Support version `0.212.0`, centric to [dependabot-common@0.212.0](https://rubygems.org/gems/dependabot-common/versions/0.212.0)
    * This is because this is the last version to support a Ruby version of `2.7.0`.
* Support version `0.217.0`, centric to [dependabot-common@0.217.0](https://rubygems.org/gems/dependabot-common/versions/0.217.0)

Bugs present in only the most recent pinned minor version may be patched and contribute to successive patch versions. If a bug exists in an older version and no longer exists in a newer version, it is suggested to update to the newer version. As the underlying package this wraps, dependabot[-omnibus], is a live service, it makes sense for this to only roll forward.
## Reporting a Vulnerability
Raise a [Security Vulnerability](https://github.com/Skenvy/dependabot-linguist/issues/new?assignees=&labels=security&template=security-vulnerability.yaml) issue.
