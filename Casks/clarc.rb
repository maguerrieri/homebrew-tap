cask "clarc" do
  version "1.1.9"
  sha256 "4736121f3537000b168e94a6f92de1f80a8e2b341ece27c22085c8bce4bd79a9"

  url "https://github.com/ttnear/Clarc/releases/download/v#{version}/Clarc-#{version}.zip"
  name "Clarc"
  desc "Native GUI client for Claude Code"
  homepage "https://github.com/ttnear/Clarc"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sequoia"

  app "Clarc.app"

  zap trash: [
    "~/Library/Application Support/Clarc",
    "~/Library/Caches/com.idealapp.Clarc",
    "~/Library/Preferences/com.idealapp.Clarc.plist",
  ]
end
