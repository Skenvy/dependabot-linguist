# Contributing
Welcome; If you'd like to contribute, firstly, thanks!
## Get the source
The _quickest_ way to get the source _without_ contributing is;
```
git clone https://github.com/Skenvy/dependabot-linguist.git
```
If you want to _contribute_ to the source, you'll need to [fork this repository](https://github.com/Skenvy/dependabot-linguist/fork), clone it, and create a development branch. Contributions should be received as pull requests from your development branch on your fork.
## Raise an issue
* [Bug Report](https://github.com/Skenvy/dependabot-linguist/issues/new?assignees=&labels=bug&template=bug-report.yaml)
* [Feature Request](https://github.com/Skenvy/dependabot-linguist/issues/new?assignees=&labels=enhancement&template=feature-request.yaml)
* [Security Vulnerability](https://github.com/Skenvy/dependabot-linguist/issues/new?assignees=&labels=security&template=security-vulnerability.yaml)
## Work on an existing issue
You may work on any existing issue, by forking this repository, creating a development branch, then adding a pull request.

Work on bugs is more likely to be accepted readily.

Before a feature request will be accepted and have any of its PRs reviewed, the ease with which its introduction into the set of the _next_ patch of a `<major>.<minor>` version's functionality affects the difficulty in obtaining the successive patch version for _all_ higher pinned versions will need to be considered.

If your feature request is meta to the gem's code, it won't need to be evaluated in this way, although will likely fall under higher scrutiny as it would impact the overall health of the repository, depending on how obvious an improvement it makes.

## Scrutiny
Any fix or new feature should include an appropriate set of testing, and should pass [the expected set of rubocop policies](https://github.com/Skenvy/dependabot-linguist/blob/main/.rubocop.yml).

The existing CICD attempts to verify the tests as well as the documentation, but the documentation test should be verified by running the local server provided for in the make recipes, to confirm nothing has altered how it will visually present this, as it is possible to pass the documentation producibility test with changes that would break the visual styling and readability, e.g. misplacing the CSS can happen between versions. Any reviewer for a significant change should also confirm that they also run the documentation server similarly.
## Version bumping
PRs should **not** bump the patch version for their `<major>.<minor>` target. These will be handled after the PR's merging.
