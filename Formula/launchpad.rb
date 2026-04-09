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
  version "0.7.6"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.6/launchpad_0.7.6_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "7a378ceb2481e98807c23373d8e259d66e690ee6d3b63f7cdf493b2a9515896c"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.6/launchpad_0.7.6_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "cb3a3397db49a82159773c8eecfdbfeea8650fc36dcaaf4be4869315fd1eee98"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
