# dbus: Build a bottle for Linuxbrew
class Dbus < Formula
  # releases: even (1.10.x) = stable, odd (1.11.x) = development
  desc "Message bus system, providing inter-application communication"
  homepage "https://wiki.freedesktop.org/www/Software/dbus"
  url "https://dbus.freedesktop.org/releases/dbus/dbus-1.12.12.tar.gz"
  mirror "https://deb.debian.org/debian/pool/main/d/dbus/dbus_1.12.12.orig.tar.gz"
  sha256 "9546f226011a1e5d9d77245fe5549ef25af4694053189d624d0d6ac127ecf5f8"

  bottle do
    sha256 "35bf723ad353d87124779bcc175aa59c236bb327519d7606c0919859cd906dde" => :mojave
    sha256 "8044e64e37449d5f91c0410263ddda23a7ed74e216bf619b89bb534b319473cd" => :high_sierra
    sha256 "1fe2295f71bc0a96a12600741f11c4973b50b2c0ec3342521f0cbcee4f2a6e8b" => :sierra
    sha256 "66c0420704c06297b1a2e50d98d262e19198a4fae70fbba5d7f4f9136b99bcfc" => :x86_64_linux
  end

  head do
    url "https://anongit.freedesktop.org/git/dbus/dbus.git"

    depends_on "autoconf" => :build
    depends_on "autoconf-archive" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "xmlto" => :build if OS.mac?
  unless OS.mac?
    depends_on "pkg-config" => :build
    depends_on "expat"
  end

  # Patch applies the config templating fixed in https://bugs.freedesktop.org/show_bug.cgi?id=94494
  # Homebrew pr/issue: 50219
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/0a8a55872e/d-bus/org.freedesktop.dbus-session.plist.osx.diff"
    sha256 "a8aa6fe3f2d8f873ad3f683013491f5362d551bf5d4c3b469f1efbc5459a20dc"
  end

  def install
    # Fix the TMPDIR to one D-Bus doesn't reject due to odd symbols
    ENV["TMPDIR"] = "/tmp"

    if OS.mac?
      # macOS doesn't include a pkg-config file for expat
      ENV["EXPAT_CFLAGS"] = "-I#{MacOS.sdk_path}/usr/include"
      ENV["EXPAT_LIBS"] = "-lexpat"
    end

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "./autogen.sh", "--no-configure" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          ("--enable-xml-docs" if OS.mac?),
                          ("--disable-xml-docs" unless OS.mac?),
                          "--disable-doxygen-docs",
                          ("--enable-launchd" if OS.mac?),
                          ("--with-launchd-agent-dir=#{prefix}" if OS.mac?),
                          "--without-x",
                          "--disable-tests"
    system "make", "install"
  end

  def post_install
    # Generate D-Bus's UUID for this machine
    system "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
  end

  test do
    system "#{bin}/dbus-daemon", "--version"
  end
end
