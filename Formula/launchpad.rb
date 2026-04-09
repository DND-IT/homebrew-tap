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
  version "0.7.5"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.5/launchpad_0.7.5_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "8662bf1af49844c30811c1da3ad6b9f5ada7e091dc63b138ecd73d1f544f1253"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.5/launchpad_0.7.5_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "e9a6abc1d531886076d5ff5a4ca613a2891f2df31d2523bcbb72621bc89e4921"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
