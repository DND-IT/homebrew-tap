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
  version "0.5.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.1/launchpad_0.5.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "b29edefa5125ee07d748b5fb84c27ffe5e0ca60f4e70bfb26bdc040f377a9b0b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.5.1/launchpad_0.5.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "8507f0ee611b1de5e5f7c39ab34ff992f561c852539b4fa4293586630fe3222d"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
