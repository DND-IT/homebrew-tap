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
  version "0.5.3"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.3/launchpad_0.5.3_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9a1cd37f546fdcd98d5f338dc41e0cdc7baa7f8f004f8122a6d46baeb7ce30b9"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.3/launchpad_0.5.3_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "88f5afcc28ad4577c0d940b7f2c65593237bd61f0c4ba3b44d6871f55c40bf29"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
