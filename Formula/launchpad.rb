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
  version "0.43.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.43.0/launchpad_0.43.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "7d5a746b906507d20830d6c8bdc7ca6ad484c48b1d1c3d6aaf6bbad7d817a014"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.43.0/launchpad_0.43.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "545849d76eb80502dce1d4bcc155970e32c35d790e1eac56e1a546cb760de13e"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
