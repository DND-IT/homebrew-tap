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
  version "0.35.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.35.1/launchpad_0.35.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9b84e0acfbf767f94ecce28d485d8c2f403356c5d9c362a2b6b1b300786dc2fc"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.35.1/launchpad_0.35.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "edae34379b4f76ca82850005dfb96c6ef100eab3b957b08751d9361dd492a57a"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
