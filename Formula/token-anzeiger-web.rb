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

class TokenAnzeigerWeb < Formula
  desc "Browser dashboard for AI token usage and cost (token-anzeiger)"
  homepage "https://github.com/DND-IT/token-anzeiger"
  version "0.1.1"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.1.1/tokenanzeiger-web_0.1.1_darwin-arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "b4df13abd7475f2e7c4e90d76790965c0d25de55b2a82663e03e2c81288504e9"
    else
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.1.1/tokenanzeiger-web_0.1.1_darwin-x64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "21aea9bbfcc01bc2cb3277489cd9e4a27fe87b8e40e1688b1035b64ed8193986"
    end
  end

  on_linux do
    url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.1.1/tokenanzeiger-web_0.1.1_linux-x64.tar.gz",
        using: GhReleaseDownloadStrategy
    sha256 "a1624bb5b2775e225ed5ab4bac4850f41daa21a188a079fdd794fdb1a516751d"
  end

  def install
    bin.install "tokenanzeiger-web"
  end

  def caveats
    <<~EOS
      Serves the same usage data as token-anzeiger in a browser.

      tokenanzeiger-web               # http://127.0.0.1:4646
      PORT=8080 tokenanzeiger-web     # custom port
      HOST=0.0.0.0 tokenanzeiger-web  # expose beyond localhost

      Display-only: never sends telemetry.
    EOS
  end

  test do
    assert_predicate bin/"tokenanzeiger-web", :exist?
  end
end
