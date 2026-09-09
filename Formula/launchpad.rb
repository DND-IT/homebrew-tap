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
  version "0.43.3"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.43.3/launchpad_0.43.3_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "5ab79945ec06e459794bd067d1c40b6bcd2ecd55e2ca77468a9891c8e768ae5a"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.43.3/launchpad_0.43.3_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "c448ea0bb97e43e46f99f2ecca7340bb698cf546433c0954f17608050f9b220b"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
