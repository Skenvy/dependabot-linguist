# Dependabot smoke testing files
This `<repo>/smoke-test` directory is essentially equivalent to a clone of the [`dependabot/smoke-tests`](https://github.com/dependabot/smoke-tests) repository. Disclaimer that the `dependabot/smoke-tests` does **not** appear to have any license permitting this to be copied here, yet even if there were, many of the [tests](https://github.com/dependabot/smoke-tests/tree/0e13b71e2d17c7e570448f0696390c6239c1c089/tests) whose files need to be duplicated to replicate the same test, are using old commits, that wouldn't retroactively receive any license if one was added subsequently. I'm relying on the good faith that it absorbs the licensing of the repositories it tests, notably [`dependabot/cli`'s MIT license](https://github.com/dependabot/cli/blob/main/LICENSE) (which comes with `Copyright 2022 GitHub, Inc.`) and [`dependabot/dependabot-core`'s Properity license](https://github.com/dependabot/dependabot-core/blob/main/LICENSE) (which comes with `Contributor: GitHub Inc.`, and has other components duplicated in the gem of this repository, under [this repository's GPLv3 license](https://github.com/Skenvy/dependabot-linguist/blob/main/LICENSE) with a copy of [`dependabot/dependabot-core`'s Properity license](https://github.com/Skenvy/dependabot-linguist/blob/main/LICENSE.dependabot-core)). The most direct assertion of the right to utilise the [`dependabot/smoke-tests`](https://github.com/dependabot/smoke-tests) is exclusively the sentence "You're welcome to use this repo to test Dependabot functionality." from [the README](https://github.com/dependabot/smoke-tests/blob/006edd50f2d8789fea79e7413d15a9ed0348b17d/README.md). I'm hoping this exhaustive attribution is enough while I wait for a result to [asking them to add a license](https://github.com/dependabot/smoke-tests/issues/17).

The previous commits that [the current set of smoke tests](https://github.com/dependabot/smoke-tests/tree/0e13b71e2d17c7e570448f0696390c6239c1c089/tests) use, are:
* [8b2c0d821028c531826db20ca22cffdd2cc05abf](https://github.com/dependabot/smoke-tests/tree/8b2c0d821028c531826db20ca22cffdd2cc05abf)
    * [github_actions](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-actions.yaml#L14)
        * [/actions]()
    * [pub](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-pub.yaml#L26)
        * [/pub]()
    * [terraform](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-terraform.yaml#L23)
        * [/terraform]()
* [832e37c1a7a4ef89feb9dc7cfa06f62205191994](https://github.com/dependabot/smoke-tests/tree/832e37c1a7a4ef89feb9dc7cfa06f62205191994)
    * [bundler](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-bundler.yaml#L18)
        * [/]()
    * [cargo](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-cargo.yaml#L23)
        * [/]()
    * [docker](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-docker.yaml#L14)
        * [/]()
    * [elm](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-elm.yaml#L26)
        * [/]()
    * [hex](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-hex.yaml#L17)
        * [/]()
    * [maven](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-maven.yaml#L14)
        * [/]()
    * [npm_and_yarn](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-npm.yaml#L14)
        * [/]()
    * [nuget](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-nuget.yaml#L14)
        * [/nuget]()
    * [pip](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-pip-compile.yaml#L13)
        * [/pip-compile]()
    * [pip](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-pip.yaml#L15)
        * [/pip]()
    * [pip](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-pipenv.yaml#L13)
        * [/pipenv]()
    * [pip](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-poetry.yaml#L14)
        * [/poetry]()
* [bb98f0c3489713c240ccc1f1800008d4f0844dfd](https://github.com/dependabot/smoke-tests/tree/bb98f0c3489713c240ccc1f1800008d4f0844dfd)
    * [composer](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-composer.yaml#L14)
        * [/composer]()
* [941c9223edd97d233737435a404d038a4bc846c4](https://github.com/dependabot/smoke-tests/tree/941c9223edd97d233737435a404d038a4bc846c4)
    * [go_modules](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-go.yaml#L17)
        * [/go]()
* [9d77bc7063ed8328a7dbc4fc3b30605530322877](https://github.com/dependabot/smoke-tests/tree/9d77bc7063ed8328a7dbc4fc3b30605530322877)
    * [gradle](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-gradle.yaml#L23)
        * [/gradle]()
* [4e5e081d77a06dd5092a65e161c1142fbec372bd](https://github.com/dependabot/smoke-tests/tree/4e5e081d77a06dd5092a65e161c1142fbec372bd)
    * [npm_and_yarn](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-npm-remove-transitive.yaml#L25)
        * [/npm/removed]()
* [d55092e0297999bf4d29725606cfa082b378959a](https://github.com/dependabot/smoke-tests/tree/d55092e0297999bf4d29725606cfa082b378959a)
    * [submodules](https://github.com/dependabot/smoke-tests/blob/0e13b71e2d17c7e570448f0696390c6239c1c089/tests/smoke-submodules.yaml#L10)
        * [/]()

The contents are used to test the functionality of **_both_** `linguist` _and_ `dependabot`. The contents don't necessarily need to use the same structure as the earlier commits that the smoke-test repository actually runs it's tests on as our tests are;
1. For linguist, that it is able to discover the contents of the folders.
1. That the code here is able to map what linguists discovers to the appropriate dependabot class to attempt to fetch the files with
1. That the result of running the dependabot classes we've chosen for the folders that linguist found to contain relevant code does result in a list of those ecosystems and the relevant folders in these smoke-test data files.

The only adjustment that was notable was having to change the contents of the bundler folder to contain a gemspec.
