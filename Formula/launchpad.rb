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
  version "0.17.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.17.0/launchpad_0.17.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "75f56dee1aceb739e4765a0c2bfc2ea1534f1aae5a51aaddc9966ecdccce273b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.17.0/launchpad_0.17.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "af16407d6be86275ff43bfac5f5d8c65ab3155ca9a94c8e6b551893458607759"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
