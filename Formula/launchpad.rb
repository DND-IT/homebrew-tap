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
  version "0.7.7"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.7/launchpad_0.7.7_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "78e98b7b7a166848e6fab119ddde496c7f06c564dcf17fc05a81bfc819313570"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.7/launchpad_0.7.7_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "1d9ea4bf0abe57dc5219881cab99779bf78e43e4f663c62eaa7800849c4b54b8"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
