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
  version "0.30.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.30.0/launchpad_0.30.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "37c3dab9d2e09007789477d8dfa644574c6d0e0449694a51f108dd7a59ba43bb"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.30.0/launchpad_0.30.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "39b7957300b6fd4c693e098d93897ae168f557b30b4bf4361793af5e929f7c36"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
