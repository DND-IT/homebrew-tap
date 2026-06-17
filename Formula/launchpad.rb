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
  version "0.29.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.29.2/launchpad_0.29.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "44e77b0d271ae3e88bf3a857311dac9b0a1bf44b05aa963c03df994a75fac795"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.29.2/launchpad_0.29.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ff6c8453669ca156b94f0bfa97ab1e8fb9406367df3e1040663c10df9f2de449"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
