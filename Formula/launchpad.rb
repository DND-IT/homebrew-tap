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
  version "0.1.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.1.0/launchpad_0.1.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "25f8073e23bbca5528d6c5e9ad1a46106ac3188dfebd9f1447f0068a74534812"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.1.0/launchpad_0.1.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "3fc4e6f66646cdc53b2604d2eafa599b3912c7fa676a32e63980c0ba5dba8948"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
