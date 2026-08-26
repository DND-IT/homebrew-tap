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
  version "0.37.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.37.1/launchpad_0.37.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9a5ada6bb79caebba145435a6dc3f1d38b72cccd5b22ea9b5f2b23564868d6aa"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.37.1/launchpad_0.37.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "1a70963942b3c08cfcf3ede3598679fbf509f419c18aaea105b484469dca70c1"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
