class GhAuthDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @token = `gh auth token 2>/dev/null`.chomp
    raise "Not authenticated with gh CLI. Run: gh auth login" if @token.empty?
  end

  def _fetch(url:, resolved_url:, timeout:)
    curl_download resolved_url,
                  "--header", "Authorization: Bearer #{@token}",
                  "--header", "Accept: application/octet-stream",
                  "--header", "X-GitHub-Api-Version: 2022-11-28",
                  to: temporary_path,
                  timeout: timeout
  end
end

class Launchpad < Formula
  desc "Launchpad CLI — deploy apps to the PaaS platform"
  homepage "https://github.com/DND-IT/launchpad"
  version "0.4.7"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.7/launchpad_0.4.7_darwin_arm64.tar.gz",
          using: GhAuthDownloadStrategy
      sha256 "6d4b6b2ec53503ce8a10b2f32460a774a659dc6d452852a7c5bb1e5716895dcc"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.7/launchpad_0.4.7_darwin_amd64.tar.gz",
          using: GhAuthDownloadStrategy
      sha256 "97ec268c4d4a52f41356a09cedb6bab9f5ce104f301d0ee8e4bee73b75afa659"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system "#{bin}/launchpad", "--version"
  end
end
