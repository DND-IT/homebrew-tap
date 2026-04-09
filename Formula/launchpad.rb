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
  version "0.5.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.2/launchpad_0.5.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ae129541d66e549ac17076dca5a38772e54099bd3ff1fc5aee2a7b50b2e2755e"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.2/launchpad_0.5.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "cc5c92f53ee52fc3c687ef27b01843e14e6a7aeb04499670b31d835b871696ed"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
