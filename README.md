# homebrew-tap

Personal Homebrew tap for [maguerrieri](https://github.com/maguerrieri).

## Usage

```sh
brew tap maguerrieri/tap
brew trust maguerrieri/tap
brew install --cask <name>
```

Homebrew 6 requires non-official taps to be trusted before it will load them,
so the `brew trust` step is needed once per machine. Without it the install
fails with `Refusing to load cask ... from untrusted tap`.

## Casks

| Cask | Description |
|------|-------------|
| `clarc` | Native macOS GUI for Claude Code |
| `openloco` | Open-source re-implementation of Chris Sawyer's Locomotion (Apple silicon only) |
