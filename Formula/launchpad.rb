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
  version "0.6.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.6.0/launchpad_0.6.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "76e4775e8c997bf18f3c6ecd872a6a6854ecd372247248f709b918617c8ee98b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.6.0/launchpad_0.6.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9cb2f6068bb95463e9a0b17ed6ef9534684fbb3129abdb6a8e6fded9bfe48b71"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
