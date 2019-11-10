class Libsodium < Formula
  desc "NaCl networking and cryptography library"
  homepage "https://libsodium.org/"
  url "https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz"
  sha256 "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1"
  revision 1

  bottle do
    cellar :any
    sha256 "1cc1552646fee1e528a06e00e23fc57b7d76fb39b8287bacc716400a906d57f7" => :catalina
    sha256 "f0c5a9db15c8798edfa438b6911c6e354591f22ae3ed53696bf81c0a18afb0be" => :mojave
    sha256 "2b7cb72aaf03b3e6b4ae4e03133001abd134c8ebf008bbb788115df5df42cf97" => :high_sierra
    sha256 "e54c6a8913c83ef3201e15a4d68bed3ff329dd773d70aaf6cf7771ea93abe6a6" => :sierra
  end

  head do
    url "https://github.com/jedisct1/libsodium.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <sodium.h>

      int main()
      {
        assert(sodium_init() != -1);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}",
                   "-lsodium", "-o", "test"
    system "./test"
  end
end
