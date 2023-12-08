# README

A macOS tool to read and control the [Night Shift](https://support.apple.com/en-us/102191) feature.

## Usage

Print out current settings

```
nightshift
Schedule: sunrise
Enabled: true
Temperature: 0.49
```

Control modes

```
nightshift schedule
nightshift schedule off
nightshift schedule custom --from 11:00 --to 23:00 -t 0.3
nightshift schedule sunrise --temperature 0.3
```

Control details

```
nightshift enable
nightshift disable
nightshift temperature
nightshift temperature 0.33
```

## Installation

**Via Github**

```
git clone git@github.com:oschrenk/nightshift.swift.git
cd nightshift.swift

# installs to $HOME/.local/bin/nightshift
task install
```

**Via homebrew**

```
brew tap oschrenk/made git@github.com:oschrenk/homebrew-made
brew install oschrenk/made/nightshift
```

## Development

- `task build` **Build**
- `task run` **Run**
- `task lint` **Lint**

## Release

1. produce artifact in `./.build/release/nightshift`
2. Export version number, prefix with `v`
3. Create Tag
4. Push Tag
5. Create release on github

```
task release
export VERSION=v0.1
git tag "$VERSION"
git push origin "$VERSION"
gh release create "$VERSION" '.build/release/nightshift'
```
