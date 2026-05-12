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
  version "0.28.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.28.1/launchpad_0.28.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "cb91f2ede1e8c0bb20558f005da431b5aecdcf9116f3312a0be6207b307fb1c0"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.28.1/launchpad_0.28.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "8c946044aa4ab3d428a5be16607e249084eb4a962720c40301985c405218da8c"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
