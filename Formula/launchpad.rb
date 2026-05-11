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
  version "0.23.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.23.0/launchpad_0.23.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "a4bde9b1d2505f8d90bb03c5237eaa595584771fa7d545198e8334de542d8bfa"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.23.0/launchpad_0.23.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ca20648d30bc1d5ee6150e6013c0566f66735bf2a46db6a57c494b793ded40d3"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
