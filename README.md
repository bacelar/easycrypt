Installing requirements
====================================================================

EasyCrypt uses the following third-party tools/libraries:

 * OCaml (>= 4.02)

     Available at http://caml.inria.fr/

 * Why3 (>= 0.85)

     Available at http://why3.lri.fr/

     Why3 must be installed with a set a provers.
     See [http://why3.lri.fr/#provers]

     Why3 libraries must be installed (make byte && make install-lib)

 * Menhir [http://gallium.inria.fr/~fpottier/menhir/]

 * Yojson [http://mjambon.com/yojson.html]

 * OCaml Batteries Included [http://batteries.forge.ocamlcore.org/]
 
 * OCaml PCRE (>= 7) [https://github.com/mmottl/pcre-ocaml]

Installing requirements using OPAM (POSIX systems - preferred)
--------------------------------------------------------------------

Starting with opam 1.2.0, you can install all the needed dependencies
via the opam OCaml packages manager.

  0. Optionally, switch to a dedicated compiler for EasyCrypt:

        $> opam switch -A $OVERSION easycrypt

     where $OVERSION is a valid OCaml version (e.g. 4.02.1)

  1. Add the EasyCrypt repository:

        $> opam repository add easycrypt git://github.com/EasyCrypt/opam.git
        $> opam update
        
  2. Add the EasyCrypt meta-packages:

        $> opam install ec-toolchain
        $> opam install ec-provers

Opam can be easily installed from source or via your packages manager:

  * On Ubuntu and derivatives:
  
        $> add-apt-repository ppa:avsm/ppa
        $> apt-get update
        $> apt-get install ocaml ocaml-native-compilers camlp4-extra opam
        
  * On MacOSX using brew:

        $> brew install ocaml opam

    Note that you MacOSX does not include `/usr/local/{lib,include}` in the
    system library/include path. Be sure to have the following environment
    variables set while compiling the Easycrypt dependencies
    
        C_INCLUDE_PATH=/usr/local/include
        LDFLAGS="-L/usr/local/lib"

See [https://opam.ocaml.org/doc/Install.html] for how to install opam.

See [https://opam.ocaml.org/doc/Usage.html] for how to initialize opam


Installing requirements using a local toolchain
--------------------------------------------------------------------

### On POSIX systems

You can install a local copy of OCaml and all the needed libraries by
running [make toolchain]. You only need [curl] and the [gcc] compiler.

By default, the destination directory is ${PWD}/_tools. You can change
this by setting the $EC_TOOLCHAIN_ROOT variable, e.g.:

        $> make EC_TOOLCHAIN_ROOT=/opt/ec-toolchain toolchain

Note that $EC_TOOLCHAIN_ROOT cannot contain spaces.

The toolchain is not activated by default. You have to:

        $> source ./scripts/activate-toolchain.sh

This command has to be repeated each time you start a fresh terminal.

We also provide an automated way to install a set of core
provers. After having installing the toolchain, type:

        $> make provers

This also create a configuration file for Why3 in _tools/why3.local.conf.
This file is automatically loaded by EasyCrypt when started locally.


### On Cygwin (POSIX over Win32)

WARNING: the ocaml compiler currently shipped with cygwin64 is
broken. You have to use the 32bits version of cygwin.

First, install the following cygwin32 packages:

        git,wget,unzip,make,m4,gcc-core,gcc-g++,libmpfr4,autoconf,flexdll,
        libncurses-devel,curl,ocaml,ocaml-compiler-libs,patch,ncurses

By default, the destination directory is ${PWD}/_tools. You can change
this by setting the $EC_TOOLCHAIN_ROOT variable, e.g.:

        $> make EC_TOOLCHAIN_ROOT=/opt/ec-toolchain toolchain

Note that $EC_TOOLCHAIN_ROOT cannot contain spaces.

The toolchain is not activated by default. You have to:

        $> source ./scripts/activate-toolchain.sh

This command has to be repeated each time you start a fresh terminal.

We do NOT provide an automated way to install provers.


### On Win32

WARNING: wodi is no more maintained. We are thinking on a new
way of installing EasyCrypt requirements on Windows.

WARNING: the instructions are given for the 32bit version of
cygwin. Replace 32- by 64- if you are using the 64bit version.

NOTE: The build process relies on cygwin. Still, the resulting
EasyCrypt binary will by a native win32 program independent from the
cygwin DLL.

First, install cygwin32 && wodi32 (a package manager for OCaml
targetting win32). Wodi is coming with an automated installer that
install both. However, you may already have a installation and
cygwin. In that case, you can install wodi32 in your cygwin32
installation as follows. Otherwise, jump directly to step 5.

  1. Download http://ml.ignorelist.com/wodi/8/wodi32.tar.xz

     The EasyCrypt webpage is hosting a copy of the archive:

     https://www.easycrypt.info/wodi/wodi32-4.02.1.tar.xz

  2. Extract the archive. You will obtain a wodi32/ directory.

     Go to wodi32/ and run ./install.sh

     Wodi will be installed in /opt/wodi32.

     The installer may require you to install some cygwin packages:

        bash bzip2 coreutils cpio cygwin dash diffutils dos2unix file
        findutils gawk getent grep gzip make mingw64-i686-gcc-core
        mingw64-x86_64-gcc-core mintty patch sed tar xz

     For easing their installation, you may want to use apt-cyg:

        $> lynx -source https://rawgit.com/transcode-open/apt-cyg/master/apt-cyg > /tmp/apt-cyg
        $> install apt-cyg /bin && rm /tmp/apt-cyg
        $> apt-cyg install <packages list>

     See [https://github.com/transcode-open/apt-cyg] for more informations.

  3. Some wodi packages expect to be installed in C:/wodi32.

     Create a win32 symlink from C:/cygwin (or wherever your cygwin
     base directory is) to C:/wodi32. For that, you may start a win32
     shell command as an administrator and type

       $> mklink /D C:\wodi32 C:\cygwin

  4. Restart a fresh cygwin shell to get a working wodi
     environment. Type:

       $> /opt/wodi32/lib/godi/winconfig.sh --add-startmenu-folder

  5. Install the following wodi packages:

       godi-menhir godi-yojson godi-batteries godi-ocamlgraph godi-zarith
       godi-zip godi-pcre

     Use either the wodi32 package manager (from the start menu), or the
     CLI interface:

       $> godi_add <packages list>

  6. Install why3 0.85. Download why3 from [http://why3.lri.fr/]

     Untar, go to the why3-0.85/ directory and type

       $> CC=i686-w64-mingw32-gcc.exe ./configure --prefix=C:/wodi32/opt/wodi32/ \
            --disable-coq-tactic --disable-coq-libs --disable-pvs-libs \
            --disable-ide --disable-bench
       $> make opt byte
       $> make install install-lib

     You may have to apply some patches before configuring/building
     Why3. Check the following directories for patches:

       scripts/toolchain/patches/why3-0.85
       scripts/toolchain/patches/why3-0.85/win32

     After installation, you can check that why3 is correctly installed:

       $> ocamlfind list | fgrep -w why3

We do NOT provide an automated way to install provers. However, for a
first test, you may want to install alt-ergo form the wodi package
manager.


Configuring Why3
====================================================================

Before running EasyCrypt and after the installation/removal/update
of an SMT prover, you need to (re)configure Why3.

By EasyCrypt is using the default Why3 location, i.e. ~/.why3.conf,
or _tools/why3.local.conf when it exists. If you have several versions
of Why3 installed, it may be impossible to share the same configuration
file among them. EasyCrypt via the option -why3, allows you to load a
Why3 configuration file from a custom location. For instance:

  why3 config --detect -C $WHY3CONF.conf
  ./ec.native -why3 $WHY3CONF.conf


Compilation
====================================================================

The shell commands

        $> make
        $> make install

should build and install easycrypt.

It is possible to change the installation prefix by setting the
environment variable PREFIX:

        $> make PREFIX=/my/prefix install


Proof General Front-End
====================================================================

Requirements
--------------------------------------------------------------------

 * GNU Emacs (>= 23.3)

     Available at http://www.gnu.org/software/emacs/

 * ProofGeneral 4.2

     Available at http://proofgeneral.inf.ed.ac.uk/


Installing locally
--------------------------------------------------------------------

You can install a local copy of ProofGeneral by running:

        $> make -C proofgeneral local

This process is trying to find emacs in different places and then
searches it in the $PATH. You can change this by setting the $EMACS
environment variable.

To run this local copy, run [make pg].

Installing system-wide (manual installation)
--------------------------------------------------------------------

Add the following entry to <proof-general-home>/generic/proof-site.el
in the definition of `proof-assistant-table-default':

        (easycrypt "EasyCrypt" "ec")

Copy the directory easycrypt/ to <proof-general-home>/

If you have not done so, add the following line to your Emacs
configuration file (typically ~/.emacs):

        (load-file "<proof-general-home>/generic/proof-site.el")

If the EasyCrypt executable is not in your $PATH, set the path to the
EasyCrypt executable by modifying the variable easycrypt-prog-name
inside Emacs:

        Proof-General
          -> Advanced 
            -> Customize 
              -> EasyCrypt
                -> EasyCrypt prog name
    
setting its value to:

        "<path-to-easycrypt>/easycrypt -emacs"

Installing system-wide (automatic installation)
--------------------------------------------------------------------

The manual process can be automatized by running:

        $> make PGROOT=/path/to/proof-general-home install

along with

        $> make PGROOT=/path/to/proof-general-home uninstall

for uninstalling the EasyCrypt mode. If the EasyCrypt executable is not
in your path, refer to the previous section to configure ProofGeneral
properly.
