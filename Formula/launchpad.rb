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
  version "0.5.4"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.4/launchpad_0.5.4_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "f35a623819ea090e9a6bd520a587e2a7fbc5fe00cd694a83e942ffa5555b8502"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.4/launchpad_0.5.4_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "1a9d6e73d89eada818487c6ccbf64ae9d064b0b8dd18c26881ff8b70e2b51b8d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
