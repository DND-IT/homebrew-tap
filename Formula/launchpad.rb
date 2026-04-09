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
  version "0.7.3"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.3/launchpad_0.7.3_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "dba363b6b0c48be77238e5ff6de872699bd1eff28ab552e9117c609f28549b23"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.7.3/launchpad_0.7.3_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "1d2bffc317d52b1e146eb3606563480e7c8397e5a6798b57c271c9335e2a92ac"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
