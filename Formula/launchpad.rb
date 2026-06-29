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
  version "0.31.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.31.0/launchpad_0.31.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9c32595216f23ab0edb74f0e9a77e09142b227df9f8ca6b7943c1c64a83b1ef2"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.31.0/launchpad_0.31.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "e853101269617c699714f768c832d250e06506c1cfd1100bb1d921df7aae967c"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
