class Glade < Formula
  desc "RAD tool for the GTK+ and GNOME environment"
  homepage "https://glade.gnome.org/"
  url "https://download.gnome.org/sources/glade/3.20/glade-3.20.0.tar.xz"
  sha256 "82d96dca5dec40ee34e2f41d49c13b4ea50da8f32a3a49ca2da802ff14dc18fe"
  revision 2

  bottle do
    sha256 "b4790dc430258b21b802773032e0c63104d21c2a490b9066f3e7d31bddfb5b8a" => :sierra
    sha256 "5d1ad60bdfe6dd1a2495fac84443262e529b0fc0fb7390ca8096e8535e15ed33" => :el_capitan
  end

  # fixes build error against glib 2.54.x
  # bugzilla ticket: https://bugzilla.gnome.org/show_bug.cgi?id=782161
  # patch committed into master on May 4, 2017
  patch do
    url "https://github.com/GNOME/glade/commit/8a73d114ca5b4d37a770d0b6b69dd17a366dbcf4.diff?full_index=1"
    sha256 "4bf7c21985b27fb1198fc5ef19a8447805783f394bcb699200ef2e7e99cc81f2"
  end

  # remove next five lines when new release is available
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "yelp-tools" => :build
  depends_on "gnome-common" => :build

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "itstool" => :build
  depends_on "docbook-xsl" => :build
  depends_on "gettext"
  depends_on "libxml2"
  depends_on "adwaita-icon-theme"
  depends_on "hicolor-icon-theme"
  depends_on "gtk+3"
  if OS.mac?
    depends_on "gtk-mac-integration"
  else
    depends_on "libxslt" => :build
  end

  def install
    # Find our docbook catalog
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    # remove next line when new release is available
    system "autoreconf", "-fi"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-gladeui",
                          "--enable-introspection"
    # objective-c is needed for glade-registration.c. unfortunately build fails if -x objective-c is added to global CFLAGS.
    # Bugreport Upstream: https://bugzilla.gnome.org/show_bug.cgi?id=768032
    inreplace "src/Makefile", "-c -o glade-glade-registration.o", "-x objective-c -c -o glade-glade-registration.o"

    system "make" # separate steps required
    system "make", "install"
  end

  test do
    # executable test (GUI)
    system "#{bin}/glade", "--version"
    # API test
    (testpath/"test.c").write <<-EOS.undent
      #include <gladeui/glade.h>

      int main(int argc, char *argv[]) {
        gboolean glade_util_have_devhelp();
        return 0;
      }
    EOS
    ENV.libxml2
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx3 = Formula["gtk+3"]
    harfbuzz = Formula["harfbuzz"]
    libepoxy = Formula["libepoxy"]
    libpng = Formula["libpng"]
    pango = Formula["pango"]
    pcre = Formula["pcre"]
    pixman = Formula["pixman"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtkx3.opt_include}/gtk-3.0
      -I#{harfbuzz.opt_include}/harfbuzz
      -I#{include}/libgladeui-2.0
      -I#{libepoxy.opt_include}
      -I#{libpng.opt_include}/libpng16
      -I#{pango.opt_include}/pango-1.0
      -I#{pcre.opt_include}
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx3.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lcairo-gobject
      -lgdk-3
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lgladeui-2
      -lglib-2.0
      -lgobject-2.0
      -lgtk-3
      -lpango-1.0
      -lpangocairo-1.0
      -lxml2
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
