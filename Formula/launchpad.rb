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
  version "0.7.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.2/launchpad_0.7.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "1110a44fa10ccee152671d6c106db2aa761f2566813822983faddab8b1d9b0b3"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.2/launchpad_0.7.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "681186d9512a12cd374d2aef4baf049da774fdd23a055b26014659dbc4162117"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
