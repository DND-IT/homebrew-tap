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
  version "0.18.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.18.0/launchpad_0.18.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "6174557c32153feb25cf1d826f61a40ad550abd7ee9981f76470f3cb853544fb"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.18.0/launchpad_0.18.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "bfc3947601ccfc303780721e39c780c9fbda425daea62f7404548f6893f9e45a"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
