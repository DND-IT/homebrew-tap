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
  version "0.42.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.42.0/launchpad_0.42.0_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "14863b17ab01f237e21f3c09520dd267d411f91a2e9528e8315561e7c90aa935"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.42.0/launchpad_0.42.0_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "e6a5f556a4471ed02ddca16ac09ef50b56b77c9f816e050d49498b9fbab6b427"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
