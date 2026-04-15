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
  version "0.14.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.14.0/launchpad_0.14.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "7593d2f7ab2cd58a601e77fc549406b4e4fc2840e2ada4e2628063a62a571f6d"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.14.0/launchpad_0.14.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "b94bab3e2710adb6248363fc2ce9287846fe2645caca860d07092388e630d37f"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
