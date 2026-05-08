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
  version "0.17.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.17.1/launchpad_0.17.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "bcca0e7e3d3878d87ebec5f32291876f2be31bb397293d80659180805308dd5e"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.17.1/launchpad_0.17.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "c6d236441d554673011ce3b052942693ef1abf548683e3298b9c3909cfabb99d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
