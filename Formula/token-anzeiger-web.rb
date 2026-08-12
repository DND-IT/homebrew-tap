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
  version "0.1.2"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.1.2/tokenanzeiger-web_0.1.2_darwin-arm64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "9bee67325e61bec92ff3d140388afb6ee589efdddfeb91270a5d6612d251a161"
    else
      url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.1.2/tokenanzeiger-web_0.1.2_darwin-x64.tar.gz",
          using: GhReleaseDownloadStrategy
      sha256 "a1af592b300216ece131bc590299dc56406faf40fb1ab521da5e144658b3e6ba"
    end
  end

  on_linux do
    url "https://github.com/DND-IT/token-anzeiger/releases/download/v0.1.2/tokenanzeiger-web_0.1.2_linux-x64.tar.gz",
        using: GhReleaseDownloadStrategy
    sha256 "64e1a9580ecede5c2a7a43cac3b0a3b0fe9fafd2d82ce06eecc6eb165207d1ae"
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
