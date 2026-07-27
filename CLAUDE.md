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

- **Installing from this tap needs `brew trust` first.** Homebrew 6.0 enforces
  tap trust by default (`require_tap_trust?` is true), so a fresh
  `brew install --cask maguerrieri/tap/<name>` fails with "Refusing to load cask
  … from untrusted tap". Users need `brew trust maguerrieri/tap` once per
  machine. Note that tapping a *local path* for testing records a trust entry
  keyed to that path, so local testing silently skips this gate — it is not
  evidence that a real install works.

- **`brew install --cask` does not strip the quarantine xattr — it adds one.**
  So an ad-hoc signed / unnotarized app is challenged by Gatekeeper on first
  launch. Do **not** ship an `xattr -d` bypass — Homebrew disallows it; point at
  `--no-quarantine` in `caveats` instead, with the risk stated.

- **Distinguish "unnotarized" from "damaged" — they have different remedies.**
  "Open Anyway" in System Settings only exists for apps with a *valid* signature
  that merely lack notarization. If the bundle has no `Contents/_CodeSignature`
  (i.e. upstream never codesigned the `.app`, only the linker ad-hoc-signed the
  executable), `codesign --verify` reports "code has no resources but signature
  indicates they must be present" and macOS calls it **"damaged and can't be
  opened"** — no Open button, no System Settings entry. `--no-quarantine` is
  then the only user-side option. Check `ls <app>/Contents/` for
  `_CodeSignature` before writing any Gatekeeper caveat.

- **A GUI app stalled at `_dyld_start` with 0% CPU is usually waiting on an
  unanswered Gatekeeper dialog, not hard-blocked.** Launching headlessly (or
  with `open -g`) leaves the prompt unseen and the process suspended
  indefinitely. Confirm with the log before drawing conclusions:
  `/usr/bin/log show --last 1h --predicate 'process == "syspolicyd" OR process
  == "CoreServicesUIAgent"'` and look for `Prompt shown … waiting for response`
  / `present code-evaluation prompt`. (`log` is shadowed by a shell function
  here — use the absolute path.)

- **Verify `zap` paths; don't derive them from the bundle id alone.** Read the
  upstream source for wherever it resolves its config/data directory. Bundle-id
  paths (`~/Library/Preferences/<id>.plist`,
  `~/Library/Saved Application State/<id>.savedState`) are conventional and safe
  to include, but the real data directory often is not one of them.
