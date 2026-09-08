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
  version "0.39.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.39.1/launchpad_0.39.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "bdba7c1890d3d9ca4396fc178bfd2670dabd6e9e63d6a4ca1c129f5bf11a7512"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.39.1/launchpad_0.39.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "dc8c5b4a86d91cb29ef07afbe90c6cd6c6578ee23c18057646e90f6cd2df6ca8"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
