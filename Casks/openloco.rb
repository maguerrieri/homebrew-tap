cask "openloco" do
  version "26.07"
  sha256 "df9dbe21c90abf681ee1fcd2116bd58e26aa3885b70b11370cfbb7e0a1cf0530"

  url "https://github.com/OpenLoco/OpenLoco/releases/download/v#{version}/OpenLoco-v#{version}-macos-arm64.zip"
  name "OpenLoco"
  desc "Open-source re-implementation of Chris Sawyer's Locomotion"
  homepage "https://github.com/OpenLoco/OpenLoco"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Info.plist leaves LSMinimumSystemVersion empty, but the shipped binary's
  # LC_BUILD_VERSION load command sets minos 15.0. Upstream builds for Apple
  # silicon only ("MacOS (arm64 only)" in the readme).
  depends_on macos: :sequoia
  depends_on arch: :arm64

  app "OpenLoco.app"

  # The first path is source-derived: Platform::getUserDirectory()
  # (Platform.Macos.mm) returns ~/Library/Application Support/OpenLoco, and
  # Environment.cpp roots every user-writable PathId there (config, saves,
  # landscapes, screenshots, custom objects), as does logs/ (Logging.cpp).
  # The remaining two are the usual bundle-id conventions, not observed.
  zap trash: [
    "~/Library/Application Support/OpenLoco",
    "~/Library/Preferences/io.openloco.OpenLoco.plist",
    "~/Library/Saved Application State/io.openloco.OpenLoco.savedState",
  ]

  caveats <<~EOS
    OpenLoco requires the asset files of the original Chris Sawyer's Locomotion,
    which are not distributed with it. The original is a Windows-only game, so
    on macOS you extract its data files rather than install it:

      GOG:   https://www.gog.com/game/chris_sawyers_locomotion
             unpack the installer with innoextract; the game lands in ./app
      Steam: https://store.steampowered.com/app/356430/
             fetch the Windows depot with steamcmd (app id 356430)

    OpenLoco only auto-detects Windows install paths, so on macOS it always
    prompts for the folder. Point it at the one containing Data/g1.DAT.

    Upstream ships the app without a bundle code signature: there is no
    Contents/_CodeSignature, only an ad-hoc linker signature on the executable,
    and codesign --verify rejects it. macOS therefore reports the quarantined
    app as "damaged and can't be opened" -- confirmed on both macOS 26 and 27 --
    which offers no "Open Anyway" button in System Settings.

    Homebrew 6 removed the --no-quarantine flag, so the app will not launch from
    a normal install until you clear the attribute yourself:

      xattr -dr com.apple.quarantine /Applications/OpenLoco.app

    That opts this app out of Gatekeeper's checks, so run it only if you trust
    the download. The real fix belongs upstream, in how the release is signed.
  EOS
end
