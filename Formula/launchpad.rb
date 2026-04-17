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
  version "0.15.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.15.1/launchpad_0.15.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "3566457fbb0de56313a1869bf39e857d4bff10559f630d680a70cc9623d901c1"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.15.1/launchpad_0.15.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "2db5dfab34085eceb4f6049d464c5790c973ac69478fc5584aa0d92408cf2365"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
