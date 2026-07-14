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
  version "0.35.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.35.0/launchpad_0.35.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "2436ca9577d4989e12325ecad66ad590d614ed3986d842a4c9e4db14ca57ff41"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.35.0/launchpad_0.35.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "d803c31a5174a83ea81ef1980f0d9dc9d7b899cd3faaf802344c0e1b5cd8734d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
