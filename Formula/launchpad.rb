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
  version "0.38.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.38.0/launchpad_0.38.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "d1202c7b6a79880cc3265426682d032e6eac073d197a61b3dfa069d8c4946a92"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.38.0/launchpad_0.38.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "a58cccc2eca3528868f715cc3bc645e0379133c623da03fc755047526d5476ad"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
