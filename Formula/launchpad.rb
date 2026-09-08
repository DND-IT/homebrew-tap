class GhReleaseDownloadStrategy < AbstractDownloadStrategy
  def fetch(timeout: nil)
    gh_bin = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh"].find { |p| File.exist?(p) }
    raise "gh CLI not found. Run: brew install gh" unless gh_bin

    filename = File.basename(@url)
    cached_location.dirname.mkpath
    safe_system gh_bin, "release", "download", version.to_s,
                "--repo", "DND-IT/launchpad",
                "--pattern", filename,
                "--output", cached_location.to_s
  end

  def cached_location
    @cached_location ||= HOMEBREW_CACHE/File.basename(@url)
  end

  def clear_cache
    cached_location.unlink if cached_location.exist?
  end
end

class Launchpad < Formula
  desc "Launchpad CLI — deploy apps to the PaaS platform"
  homepage "https://github.com/DND-IT/launchpad"
  version "0.39.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.39.0/launchpad_0.39.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "33f7e59b2c288f76c88b856d14f894f5f1531386676aeef7cc1472b72d4c5018"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.39.0/launchpad_0.39.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "a4867d8da3878f2dece6476a9c501c2f31ab85ae48719a54919a74f180757b07"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
