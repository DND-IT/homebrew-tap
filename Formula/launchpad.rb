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
  version "0.16.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.16.1/launchpad_0.16.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "cfc13292f6f64ea39dafd24a591a6fc15f1641503248194333f93cdf1f3c75a0"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.16.1/launchpad_0.16.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "f77f459ee0b03e62ea0b0f027d94a525c3f5a30b54ac05b8a227ba5ba9350b59"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
