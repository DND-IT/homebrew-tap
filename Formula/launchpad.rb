class Launchpad < Formula
  desc "Launchpad CLI — deploy apps to the PaaS platform"
  homepage "https://github.com/DND-IT/launchpad"
  version "0.4.6"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.6/launchpad_0.4.6_darwin_arm64.tar.gz"
      sha256 "6eb85b2e4a80d8b04f0cb758e37417770d2c4d26dbf18c52196a50ce9421ef0a"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.6/launchpad_0.4.6_darwin_amd64.tar.gz"
      sha256 "ac740782f4bb27069b46897080a9cfc1854cfcd848005bb51f7b148f4bfa03e7"
    end
  end

  def install
    token = Utils.safe_popen_read("gh", "auth", "token").chomp
    raise "Not authenticated with gh CLI. Run: gh auth login" if token.empty?

    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    filename = "launchpad_#{version}_darwin_#{arch}.tar.gz"

    system "gh", "release", "download", version,
           "--repo", "DND-IT/launchpad",
           "--pattern", filename,
           "--clobber"

    system "tar", "xzf", filename
    bin.install "launchpad"
  end

  test do
    system "#{bin}/launchpad", "--version"
  end
end
