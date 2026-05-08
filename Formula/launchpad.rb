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
  version "0.19.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.19.1/launchpad_0.19.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "a0c73cf6ad59eb3af0e0fa2bed945652c2272264e56c9ae86d02074265e0fa0b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.19.1/launchpad_0.19.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "e36827b1655a78cc54d3ac07e2a67b02916d2573146fa78e7b6d3e2a690250de"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
