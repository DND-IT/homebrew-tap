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
  version "0.10.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.10.0/launchpad_0.10.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "f081fff62da5acba26d730d7375ee58aa1d325b497a5b4d77ba104a3cc65eb47"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.10.0/launchpad_0.10.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "909bc03aa9880dc2fa16adb55a5f15603d8e121c96064c2491a64d9eb1728bce"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
