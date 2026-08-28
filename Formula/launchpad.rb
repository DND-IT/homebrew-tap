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
  version "0.38.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.38.1/launchpad_0.38.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "b7f7969b7657a245db4bdd9b10dd658bba10d497e3dc7436964533d530536881"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.38.1/launchpad_0.38.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9ffaeec32184dd7cb66eca78d8cba3fd4639f334d9261274cace2bcaf67044c4"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
