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
  version "0.2.0"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.2.0/tokenanzeiger-web_0.2.0_darwin-arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "ea963d6ffeaa58d4ee7e34062a61323efcec30797f05e688d48cc696ad7d7e34"
    else
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.2.0/tokenanzeiger-web_0.2.0_darwin-x64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "3193070ce93de182418ba72d8e92451667afbacde1bd1ac0f80d19c90df409cf"
    end
  end

  on_linux do
    url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.2.0/tokenanzeiger-web_0.2.0_linux-x64.tar.gz",
        using: GhReleaseDownloadStrategy
    sha256 "036f21587d8b0b2b59a91cd8139857f680ca9cc49a403e3373b5cbbd3c8f5a10"
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
