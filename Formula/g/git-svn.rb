class GitSvn < Formula
  desc "Bidirectional operation between a Subversion repository and Git"
  homepage "https://git-scm.com"
  url "https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.43.1.tar.xz"
  sha256 "2234f37b453ff8e4672c21ad40d41cc7393c9a8dcdfe640bec7ac5b5358f30d2"
  license "GPL-2.0-only"
  head "https://github.com/git/git.git", branch: "master"

  livecheck do
    formula "git"
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "a5ff9c43018b2f9b5f0330d4bcecc129862abcbe1debf64e27a225c17d113d6a"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "a4b272ec1f74dca1ef816be766011430e8445056214f4087662dfbef2af10c5b"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a4b272ec1f74dca1ef816be766011430e8445056214f4087662dfbef2af10c5b"
    sha256 cellar: :any_skip_relocation, sonoma:         "a5ff9c43018b2f9b5f0330d4bcecc129862abcbe1debf64e27a225c17d113d6a"
    sha256 cellar: :any_skip_relocation, ventura:        "a4b272ec1f74dca1ef816be766011430e8445056214f4087662dfbef2af10c5b"
    sha256 cellar: :any_skip_relocation, monterey:       "a4b272ec1f74dca1ef816be766011430e8445056214f4087662dfbef2af10c5b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "25dfd2560ba471987971e98189891a623cd364d152208687fe7a686d0e1657b0"
  end

  depends_on "git"
  depends_on "subversion"

  uses_from_macos "perl"

  def install
    perl = DevelopmentTools.locate("perl")
    perl_version, perl_short_version = Utils.safe_popen_read(perl, "-e", "print $^V")
                                            .match(/v((\d+\.\d+)(?:\.\d+)?)/).captures

    ENV["PERL_PATH"] = perl
    subversion = Formula["subversion"]
    os_tag = OS.mac? ? "darwin-thread-multi-2level" : "x86_64-linux-thread-multi"
    ENV["PERLLIB_EXTRA"] = subversion.opt_lib/"perl5/site_perl"/perl_version/os_tag
    if OS.mac?
      ENV["PERLLIB_EXTRA"] += ":" + %W[
        #{MacOS.active_developer_dir}
        /Library/Developer/CommandLineTools
        /Applications/Xcode.app/Contents/Developer
      ].uniq.map do |p|
        "#{p}/Library/Perl/#{perl_short_version}/darwin-thread-multi-2level"
      end.join(":")
    end

    args = %W[
      prefix=#{prefix}
      perllibdir=#{Formula["git"].opt_share}/perl5
      SCRIPT_PERL=git-svn.perl
    ]

    mkdir libexec/"git-core"
    system "make", "install-perl-script", *args

    bin.install_symlink libexec/"git-core/git-svn"
  end

  test do
    system "svnadmin", "create", "repo"

    url = "file://#{testpath}/repo"
    text = "I am the text."
    log = "Initial commit"

    system "svn", "checkout", url, "svn-work"
    (testpath/"svn-work").cd do |current|
      (current/"text").write text
      system "svn", "add", "text"
      system "svn", "commit", "-m", log
    end

    system "git", "svn", "clone", url, "git-work"
    (testpath/"git-work").cd do |current|
      assert_equal text, (current/"text").read
      assert_match log, pipe_output("git log --oneline")
    end
  end
end
