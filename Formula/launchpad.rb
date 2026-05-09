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
  version "0.21.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.21.2/launchpad_0.21.2_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "0b4834cde8f01051fbe1806fd6cf3ff789147399e65e39b77dacb64fc8a3239c"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.21.2/launchpad_0.21.2_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "60a9ffcf531e816c72d41501e72b8abb10773ab9d69605c1d592348b2969db7e"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
