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
  version "0.47.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.47.0/launchpad_0.47.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "b83ad02587262ee032178d917b9fb1bd39c0953e20b2b152db67f625c15aaea3"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.47.0/launchpad_0.47.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "3f8ff2faca85d26ba3ee00d6608e37da79adad04f443efcc9814d5fe15c57f92"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
