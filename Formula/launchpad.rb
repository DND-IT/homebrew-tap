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
  version "0.26.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.26.0/launchpad_0.26.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "96142c2df79755a4628e7a83afa23526a843663f2ac06eafd93fccb4a38c816c"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.26.0/launchpad_0.26.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9644e32e7191386b5263cb07766c2d524e5b26e85b9370d9512f32dea12d43e2"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
