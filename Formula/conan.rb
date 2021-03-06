class Conan < Formula
  include Language::Python::Virtualenv

  desc "Distributed, open source, package manager for C/C++"
  homepage "https://github.com/conan-io/conan"
  url "https://github.com/conan-io/conan/archive/1.13.2.tar.gz"
  sha256 "1697d8a17339562f786c45010860ce22218c01b6a0ab602251c8abdc1062d224"
  head "https://github.com/conan-io/conan.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "13af7210b0b4859c324aaa926ea5935e1d02e2884c84454c38cf82dd5864a799" => :mojave
    sha256 "6b7ecf2ce079307a5b6cc3aad40323b79c59880bd74e465fbc0f0621cb73e204" => :high_sierra
    sha256 "ee787e991ad152d3f12de0c1bb95eb96b9b69c82bf7f97e00ddb624b54eda3be" => :sierra
    sha256 "fe2fc5cec110a37d7a1722c34c00f3ccd4af1e656ade74871281466660b8c413" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "libffi"
  depends_on "openssl"
  depends_on "python"

  def install
    inreplace "conans/requirements.txt", "PyYAML>=3.11, <3.14.0", "PyYAML>=3.11"
    venv = virtualenv_create(libexec, "python3")
    system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:",
                              "--ignore-installed", "PyYAML==3.13", buildpath
    system libexec/"bin/pip", "uninstall", "-y", name
    venv.pip_install_and_link buildpath
  end

  test do
    system bin/"conan", "install", "zlib/1.2.11@conan/stable", "--build"
    assert_predicate testpath/".conan/data/zlib/1.2.11", :exist?
  end
end
