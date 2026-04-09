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
  version "0.7.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.0/launchpad_0.7.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "62747d98265823d97b59faf56740114983bd696285c94109fb95b747cb276d50"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.0/launchpad_0.7.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "0b8621313899c9da08129a8625320487a8ea2ce0c3c2e5185b1161441fcd668d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
