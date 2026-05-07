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
  version "0.16.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.16.2/launchpad_0.16.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "7fd9f9c98300f7407abfc5334157ed58851f22ff8bb6c70526216976ce8f3e00"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.16.2/launchpad_0.16.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "36cff5a225433e05d655312fc86a3c5db6d688447d6395feed7bdfb09669d96d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
