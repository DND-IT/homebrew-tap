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
  version "0.24.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.24.0/launchpad_0.24.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ca06e00f722012c5e37cf98705b0a4da5d3c4cb8ab8a667a4be609ea6ce19101"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.24.0/launchpad_0.24.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "04b1b9cc556c140ab4bbb097e45373bbb6cf5740074009b66cb6d348ff684ce0"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
