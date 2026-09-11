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
  version "0.46.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.46.0/launchpad_0.46.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "fc0f93801cd1732df813c08e7fab0964315565f45f0d123d910912c8f8ee2d64"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.46.0/launchpad_0.46.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "8470e8dd64bd7ae15827a8b2c75ba0b69e7a5c932cce976aa7745709c7b97e10"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
