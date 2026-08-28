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
  version "0.38.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.38.2/launchpad_0.38.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "24c3e43827b5e720c64f70dbc90890505e5bc320f9462e07149615d1c80e6813"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.38.2/launchpad_0.38.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "f0cd1b3758d7487994a6a51780ea146de6e99040edbfc2e367940c2fd580cd9d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
