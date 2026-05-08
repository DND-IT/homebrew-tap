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
  version "0.19.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.19.0/launchpad_0.19.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "57d8ba336db7b2a52ef391b1a266c89036a7fafd125a6bce57529258d7300f05"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.19.0/launchpad_0.19.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "b19d87af619091b6857d9e08472f1d0d5284e9fadd83271ed6561f89dc1a72b9"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
