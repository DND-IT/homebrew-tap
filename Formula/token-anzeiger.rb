# token-anzeiger is a private repo, so a plain `url` cannot fetch the release
# asset. This download strategy shells out to `gh`, matching the existing
# launchpad.rb formula in the same tap.
class GhReleaseDownloadStrategy < AbstractDownloadStrategy
  def fetch(timeout: nil)
    gh_bin = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh"].find { |p| File.exist?(p) }
    raise "gh CLI not found. Run: brew install gh" unless gh_bin

    filename = File.basename(@url)
    cached_location.dirname.mkpath
    system_command! gh_bin, args: ["release", "download", "v#{version}",
                                   "--repo", "DND-IT/token-anzeiger",
                                   "--pattern", filename,
                                   "--output", cached_location.to_s]
  end

  def cached_location
    @cached_location ||= HOMEBREW_CACHE/File.basename(@url)
  end

  def clear_cache
    cached_location.unlink if cached_location.exist?
  end
end

class TokenAnzeiger < Formula
  desc "Terminal and browser dashboard for AI token usage and cost"
  homepage "https://github.com/DND-IT/token-anzeiger"
  version "0.5.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.5.0/tokenanzeiger_0.5.0_darwin-arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "4dc18c9da7123a8e1927e2732ac504d13a10b2f1132630140ce199bf56b40237"
    else
      odie "token-anzeiger only ships Apple Silicon macOS builds"
    end
  end

  on_linux do
    url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.5.0/tokenanzeiger_0.5.0_linux-x64.tar.gz",
        using: GhReleaseDownloadStrategy
    sha256 "964f8d563b8a7165f5d1e18a667d76aada9e0062752873f85e8800f442045471"
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

      The browser dashboard serves the same data from this binary:
        tokenanzeiger web                # http://127.0.0.1:4646
        tokenanzeiger web --port 8080    # custom port
        HOST=0.0.0.0 tokenanzeiger web   # expose beyond localhost

      Web mode is display-only: it never sends telemetry.
    EOS
  end

  test do
    assert_match "tokenanzeiger", shell_output("#{bin}/tokenanzeiger --help")
  end
end
