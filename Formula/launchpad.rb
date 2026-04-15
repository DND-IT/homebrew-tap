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
  version "0.15.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.15.0/launchpad_0.15.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "5662e95ffad82546b5c0f8131f9cf8a83190453657caa835b5f8ddf79eb70fd1"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.15.0/launchpad_0.15.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "56cf9eb666b98c04931797c6206c97d6f76593449d14dd6692a85e753445da2d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
