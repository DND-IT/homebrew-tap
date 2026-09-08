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
  version "0.41.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.41.0/launchpad_0.41.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ffc797f0677760a7062e13db7f93b13bb4b81a53e72557cd83b8a9e56bac767b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.41.0/launchpad_0.41.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ac52a9921278ca45e9ecb0e1324a33ea345efb0165a4d88e6102e026f2cca18a"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
