require 'formula'

class Gregorio < Formula
  url 'http://download.gna.org/gregorio/releases/current/gregorio-2.0.tar.gz'
  homepage 'http://home.gna.org/gregorio/'
  md5 '53994e8ea7f3fe4148a66262b6c7d144'
  head 'svn://svn.gna.org/svn/gregorio/trunk'
  depends_on 'fontforge'

  if ARGV.build_head?
    depends_on 'gettext'
  end

  def install
    if `which lualatex`.chomp == ''
      onoe <<-EOS.undent
        Gregorio requires a TeX/LaTeX installation; aborting now.
        You can obtain the TeX distribution for Mac OS X from
            http://www.tug.org/mactex/
      EOS
      Process.exit
    end

    if ARGV.build_head?
      system "autoreconf", "-f", "-i"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"

    # Check to see if the texmf-local directory is owned by root
    texmfdir=`find \`kpsewhich --var-value TEXMFLOCAL\` -maxdepth 0 -user root`
    if texmfdir.chomp != ''
      ohai <<-EOS.undent
      Your sudo password is required to copy fonts
      and style files to your TeX installation.
      EOS
      system "cd fonts && sudo ./install.py"
    else
      system "cd fonts && ./install.py"
    end
    system "updmap"
  end

  def caveats; <<-EOS.undent
    You will need to run

    $ updmap

    as each user that will use GregorioTeX. It has already been
    run for the current user.

    Fonts and style files have been copied
    to $TEXMFLOCAL/tex/gregoriotex.
    EOS
  end
end
