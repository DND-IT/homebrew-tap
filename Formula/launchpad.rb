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
  version "0.21.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.21.0/launchpad_0.21.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "7a742da9d80ae07bc6083eaa2931251eee6eef8d5075e8d1a105489452e42019"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.21.0/launchpad_0.21.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9bfbea153e6fc6303ae399a043d6051f5ed985cc0132d87f0fe30a6f893bcf57"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
