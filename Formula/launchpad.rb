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
  version "0.7.8"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.8/launchpad_0.7.8_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "dd0aa5d5bc0f83ef9e45d6677238284292e75c57e1adbd9884ab7c6983250438"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.8/launchpad_0.7.8_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "40d9286670eff6f2fb8e63ae5fe77b6e8cb976dc676f501a41463b150ecf14a4"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
