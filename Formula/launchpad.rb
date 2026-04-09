class GhAuthDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @token = ENV["GH_TOKEN"] || ENV["GITHUB_TOKEN"] || gh_cli_token
    raise "Not authenticated. Set GH_TOKEN or run: gh auth login" if @token.to_s.empty?
  end

  def gh_cli_token
    [Utils::Which.which("gh"), "/opt/homebrew/bin/gh", "/usr/local/bin/gh"].compact.each do |gh|
      token = `#{gh} auth token 2>/dev/null`.chomp
      return token unless token.empty?
    end
    nil
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
  version "0.4.8"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.8/launchpad_0.4.8_darwin_arm64.tar.gz",
          using: GhAuthDownloadStrategy
      sha256 "0c8ab171ff0dd225ddcb55131674aad963e1719039bf6faa54ab68d958959e6b"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.8/launchpad_0.4.8_darwin_amd64.tar.gz",
          using: GhAuthDownloadStrategy
      sha256 "713712df33dcf8a64e3cc324e130aad7c283c4e49c517e2b189ac1275c42c2b6"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system "#{bin}/launchpad", "--version"
  end
end
