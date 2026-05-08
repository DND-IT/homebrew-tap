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
  version "0.19.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.19.2/launchpad_0.19.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "18126cbc88e0efc15aa49e15f12e83748f2ab8ed519fcdf51d97cde9c29ad664"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.19.2/launchpad_0.19.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "04764c72c5f81793f27107808c1e1c0899d9bde017e4345bb97bb4116038194f"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
