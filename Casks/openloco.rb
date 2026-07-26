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

  # Platform::getUserDirectory() (Platform.Macos.mm) returns
  # ~/Library/Application Support/OpenLoco, and Environment.cpp roots every
  # user-writable PathId there (config, saves, landscapes, screenshots, custom
  # objects), as do the logs/ and crashes/ subdirectories.
  zap trash: [
    "~/Library/Application Support/OpenLoco",
    "~/Library/Preferences/io.openloco.OpenLoco.plist",
    "~/Library/Saved Application State/io.openloco.OpenLoco.savedState",
  ]

  caveats <<~EOS
    OpenLoco requires the asset files of the original Chris Sawyer's Locomotion,
    which are not distributed with it. Buy and install the original game first:

      Steam: https://store.steampowered.com/app/356430/
      GOG:   https://www.gog.com/game/chris_sawyers_locomotion

    On first launch OpenLoco tries to locate the game folder automatically, and
    prompts you to select it if that fails.

    Upstream's macOS builds are ad-hoc signed and not notarized, so Gatekeeper
    blocks the first launch. To allow it, open the app once, then approve it in
    System Settings -> Privacy & Security -> "Open Anyway".
  EOS
end
