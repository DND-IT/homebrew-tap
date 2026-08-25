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
  version "0.37.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.37.0/launchpad_0.37.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "211526b6bacb382bac67709c0d17ae5a6aa119cb99a1bed71a4d64832954753b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.37.0/launchpad_0.37.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ba73cd1ad14f087af14003282b184fef55a10365afd49edcc6de903591d6e565"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
