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
  version "0.12.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.12.0/launchpad_0.12.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "81c62638a3cd593bb0b6f9792f759a01655ebfc705a112818a3b60a8d0e66646"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.12.0/launchpad_0.12.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "d2efa0a92506e31f2e5758ae70baeaec2576ed5b5ed58d4e7df4b9cbb96562d0"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
