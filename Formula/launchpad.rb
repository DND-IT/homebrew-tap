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
  version "0.29.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.29.1/launchpad_0.29.1_darwin_arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "3d185c7d8188aba21efda53f9ad4b00fedd9dad9ab95f391ea6873e0485428fb"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.29.1/launchpad_0.29.1_darwin_amd64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "6f22c1ac977868ae086a29a4a2df1ba9ac499634be5dc7bbe796dcceddf8cf1c"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system bin/"launchpad", "--version"
  end
end
