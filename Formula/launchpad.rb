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
  version "0.34.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.34.0/launchpad_0.34.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "26e82aae92278c8dfccd81aa41b632595fe6b133d228cb73788c712e6566fdb9"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.34.0/launchpad_0.34.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "5060cfacfb0faba267552aeb9b4a3b0bf58fdf00d184ee7f4c08e710a313703a"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
