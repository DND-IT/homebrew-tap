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
  version "0.25.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.25.0/launchpad_0.25.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "87f22cb3cd5e42adaded670d4089f28f5c8b95209c51d921b89a7301e73339f6"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.25.0/launchpad_0.25.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "16e47ea84a3ec7cae197b1c8bb984babd64e806a6d0883b8480c1dbccae0862b"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
