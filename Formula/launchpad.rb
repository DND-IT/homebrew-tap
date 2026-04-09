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
  version "0.7.4"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.4/launchpad_0.7.4_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ab409c727c8da16ebf137e954b310eaf34fa59f25f38311b5d050582e8554b31"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.4/launchpad_0.7.4_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "2c5fc0dabc25f469e9bd026dc5bf06ce96559defc79c927af3d5ca15acfd8020"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
