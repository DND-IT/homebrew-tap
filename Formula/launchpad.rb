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
  version "0.5.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.0/launchpad_0.5.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "cf40dbc3b56cadceb926e757b9e87255ddbd36fb9e7200b28b794c89cf6825ba"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.0/launchpad_0.5.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "137fee623f0aebae668c9976e12c269e2b02b1ae1e6864f9220eceabcab46306"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
