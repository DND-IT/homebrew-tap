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
  version "0.11.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.11.0/launchpad_0.11.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "985965e66e6c5bea5273b84d03d2c606af0450876f644b29fa2a60990c687bc2"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.11.0/launchpad_0.11.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9b15533e862a697986ae0be0b75a391edb7866990924fd1906108062fcaa2352"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
