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
  version "0.22.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.22.0/launchpad_0.22.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "f4b63a9b3e37999908001ecd86cdea3e2e5453fffd5706bb6c720ace80cd4b27"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.22.0/launchpad_0.22.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "acf0f22c68593e019cd4d6a4150bb16b593f42ff4b8d90f7c385c87393ccb982"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
