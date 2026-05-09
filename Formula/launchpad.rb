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
  version "0.20.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.20.0/launchpad_0.20.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "cba16774902b12360f1942f95d275ad0ed49e9e9cb8440520d673616306b9133"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.20.0/launchpad_0.20.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "47ea432a5e38ffd1b127dd4be7d780b5765e00d9f1b2c160d2b37c1e60e348a2"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
