class Launchpad < Formula
  desc "Launchpad CLI — deploy apps to the PaaS platform"
  homepage "https://github.com/DND-IT/launchpad"
  version "0.4.10"

  depends_on "gh"

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    tarball = "launchpad_#{version}_darwin_#{arch}.tar.gz"
    system Formula["gh"].opt_bin/"gh", "release", "download", version.to_s,
           "--repo", "DND-IT/launchpad",
           "--pattern", tarball,
           "--dir", buildpath
    system "tar", "-xzf", buildpath/tarball, "-C", buildpath
    bin.install "launchpad"
  end

  test do
    system "#{bin}/launchpad", "--version"
  end
end
