# Development

**Requirements**

```
brew install swiftformat
brew install swiftlint
brew install go-task
```

## Tasks

- `task build` Build project
- `task run` Run app
- `task test` Run tests
- `task format` Format using rules in `.swiftformat`
- `task lint` Lint using rules in `.swiftlint.yml`
- `task install` Install app in `$HOME/.local/bin/`
- `task uninstall` Removes app from `$HOME/.local/bin/`
- `task artifacts` Produces artifact in `.build/release/`
- `task tag` Pushes git tag from `VERSION`
- `task release` Creates GitHub release
- `task sha` Prints SHA256 of GitHub source tarball
- `task clean` Removes build directory `.build`

## Release

0. `task install` to test release
1. Increase version number in `VERSION` and commit
2. `task release` to tag and push
3. `task sha | cut -d ' ' -f 1 | pbcopy` to copy the source tarball hash to the clipboard
4. Make changes in [homebrew-made](https://github.com/oschrenk/homebrew-made) and commit and push
5. `task uninstall` to remove local installation
6. `brew update` to update taps
7. `brew upgrade` to upgrade formula
