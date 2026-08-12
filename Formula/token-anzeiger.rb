# token-anzeiger is a private repo, so a plain `url` cannot fetch the release
# asset. This download strategy shells out to `gh`, matching the existing
# launchpad.rb formula in the same tap.
class GhReleaseDownloadStrategy < AbstractDownloadStrategy
  def fetch(timeout: nil)
    gh_bin = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh"].find { |p| File.exist?(p) }
    raise "gh CLI not found. Run: brew install gh" unless gh_bin

    filename = File.basename(@url)
    cached_location.dirname.mkpath
    safe_system gh_bin, "release", "download", "v#{version}",
                "--repo", "DND-IT/token-anzeiger",
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

class TokenAnzeiger < Formula
  desc "Terminal dashboard for AI token usage and cost"
  homepage "https://github.com/DND-IT/token-anzeiger"
  version "0.2.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.2.0/tokenanzeiger_0.2.0_darwin-arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "d69250825b2aa167dd74197bbab2a3e4361e6f1f4693cf9adc5b1346125e5bc7"
    else
      odie "token-anzeiger only ships Apple Silicon macOS builds"
    end
  end

  on_linux do
    url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.2.0/tokenanzeiger_0.2.0_linux-x64.tar.gz",
        using: GhReleaseDownloadStrategy
    sha256 "3754d694abaaaa2067ec8ffdcf0bb40b3b39be1d71d09ba429fb939e4379763e"
  end

  def install
    bin.install "tokenanzeiger"
  end

  def caveats
    <<~EOS
      token-anzeiger reports AI usage to the team dashboard by default.

      See exactly what your machine would send:
        tokenanzeiger --telemetry-dry-run

      Disable it permanently by pressing s in the app, or for one run with
        tokenanzeiger --no-telemetry

      Claude profiles marked "personal": true are never reported.
    EOS
  end

  test do
    assert_match "tokenanzeiger", shell_output("#{bin}/tokenanzeiger --help")
  end
end
