# homebrew-tap

Personal Homebrew tap. Casks only — no formulae today.

Adding a cask: copy the shape of an existing file in `Casks/`, then verify it
with the checks below. Keep the `## Casks` table in `README.md` in sync; it
lists every cask in the tap.

## Verifying a cask

```sh
brew style Casks/<name>.rb
brew audit --cask --strict --online <user>/tap/<name>
brew livecheck --cask <user>/tap/<name>
```

`brew audit` **only accepts a tapped name, not a path** — `brew audit Casks/x.rb`
errors with "Calling `brew audit [path ...]` is disabled". To audit an unmerged
cask, tap the working copy and point the clone at your branch:

```sh
brew tap <user>/tap /path/to/worktree     # clones the local repo
git -C "$(brew --repository)/Library/Taps/<user>/homebrew-tap" \
    fetch -q origin <branch> && git -C ... reset -q --hard FETCH_HEAD
```

The clone only sees **committed** state, so commit before re-auditing. Untap
when done if the tap wasn't installed before.

## Gotchas

- **`brew uninstall --cask --zap` can autoremove formulae you still need.**
  Homebrew's autoremove does not account for formula dependencies declared by
  *casks*, so it happily uninstalls them. Zapping a test cask here removed
  `gradle` and `openjdk`, which the installed `skip` cask explicitly declares.
  Check `brew list --formula` before and after, and restore with `brew install`
  (note the versions will move forward). `HOMEBREW_NO_AUTOREMOVE=1` avoids it.

- **The macOS floor comes from the binary, not just `Info.plist`.**
  `brew audit --strict` reads the Mach-O `LC_BUILD_VERSION` load command
  (`vtool -show-build <binary>`) and fails with "Artifact defined :x as the
  minimum macOS version but the cask declared no minimum" when the cask omits
  it. An empty `LSMinimumSystemVersion` does **not** mean there is no floor.

- **`depends_on macos: ">= :sequoia"` is deprecated.** Use the bare symbol form
  `depends_on macos: :sequoia`, which now means ">=". Use `maximum_macos:` for
  an upper bound. A bare `depends_on :macos` (no version) satisfies the
  `OSDependsOn` cop when there genuinely is no floor, and becomes redundant once
  a `macos:` version is present.

- **`brew install --cask` does not strip the quarantine xattr — it adds one.**
  So an ad-hoc signed / unnotarized app *will* be blocked by Gatekeeper on first
  launch (it stalls at `_dyld_start`; `spctl -a -t exec` exits non-zero).
  Document the System Settings → Privacy & Security → "Open Anyway" step in
  `caveats`. Do **not** ship an `xattr -d` bypass — Homebrew disallows it.

- **Verify `zap` paths; don't derive them from the bundle id alone.** Read the
  upstream source for wherever it resolves its config/data directory. Bundle-id
  paths (`~/Library/Preferences/<id>.plist`,
  `~/Library/Saved Application State/<id>.savedState`) are conventional and safe
  to include, but the real data directory often is not one of them.
