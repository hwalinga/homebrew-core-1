class Carthage < Formula
  desc "Decentralized dependency manager for Cocoa"
  homepage "https://github.com/Carthage/Carthage"
  url "https://github.com/Carthage/Carthage.git",
      :tag      => "0.33.0",
      :revision => "c8ac06e106b6b61f907918bfb2b7a5c432de4678",
      :shallow  => false
  head "https://github.com/Carthage/Carthage.git", :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "3e2ac935092f11a43bf2f45811a176bbb6c37a48f41eea1222a46a35b81555c6" => :mojave
    sha256 "7f88034cfbd51439cd45467745ea3b1a21e6eec2cdd8a7eb2a8945382404b5f0" => :high_sierra
  end

  depends_on :xcode => ["10.0", :build] if OS.mac?

  def install
    if MacOS::Xcode.version >= "10.2" && MacOS.version < "10.14.4" && MacOS.version >= "10.14.4"
      odie "Xcode >=10.2 requires macOS >=10.14.4 to build Swift formulae."
    end

    system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "Source/Scripts/carthage-bash-completion" => "carthage"
    zsh_completion.install "Source/Scripts/carthage-zsh-completion" => "_carthage"
    fish_completion.install "Source/Scripts/carthage-fish-completion" => "carthage.fish"
  end

  test do
    (testpath/"Cartfile").write 'github "jspahrsummers/xcconfigs"'
    system bin/"carthage", "update"
  end
end
