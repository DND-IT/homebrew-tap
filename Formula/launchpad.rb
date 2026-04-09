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
  version "0.8.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.8.0/launchpad_0.8.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "60a352264c9390d42ce6110bb2e03fcd717c054be2c6c24adf3379c5b8b30771"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.8.0/launchpad_0.8.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "dc1c46c7c44399647dd24ce80dda24265b7a53a01e57326c150a544f81b727b6"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
