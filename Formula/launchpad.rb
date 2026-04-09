class GhAuthDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @token = ENV["GH_TOKEN"] || ENV["GITHUB_TOKEN"] || gh_cli_token
    raise "Not authenticated. Set GH_TOKEN or run: gh auth login" if @token.to_s.empty?
  end

  def gh_cli_token
    ["/opt/homebrew/bin/gh", "/usr/local/bin/gh"].each do |gh|
      next unless File.exist?(gh)
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
  version "0.4.9"

  depends_on "gh"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.9/launchpad_0.4.9_darwin_arm64.tar.gz",
          using: GhAuthDownloadStrategy
      sha256 "a300bf20f8cfbe4619e1dae78b987dd52583cc9caeb7a60ec32c7e984f12a2d8"
    else
      url "https://github.com/DND-IT/launchpad/releases/download/0.4.9/launchpad_0.4.9_darwin_amd64.tar.gz",
          using: GhAuthDownloadStrategy
      sha256 "9849fc963eb4d77de5a9173f63417a55506fb4777bf67a8104244fcddb226abe"
    end
  end

  def install
    bin.install "launchpad"
  end

  test do
    system "#{bin}/launchpad", "--version"
  end
end
