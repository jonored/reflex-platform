{ nixpkgs }: 
let
   jdk = nixpkgs.jdk7;
   #fhs = nixpkgs.buildFHSUserEnv {
   name = "android-env";
   targetPkgs = pkgs: with pkgs; [
     git gitRepo gnupg1compat python2
     curl procps openssl gnumake nettools
     rsync androidenv.buildTools
     androidenv.platformTools ccache ncurses5
     jdk schedtool utillinux
     m4 gperf perl libxml2 zip unzip bison
     flex lzop bc which # gcc binutils
     coreutils
     gdb python
     emacs vim
     ];
     multiPkgs = pkgs: with pkgs;       [ zlib       ];
     extraOutputsToInstall = [ "dev" ];
     runScript = "bash";
     profile = ''
     export USE_CCACHE=1
     export ANDROID_JAVA_HOME=${jdk}
     export LANG=C
     unset _JAVA_OPTIONS
     export BUILD_NUMBER=$(date --utc +%Y.%m.%d.%H.%M.%S)
     export DISPLAY_BUILD_NUMBER=true
     '';
     #};
     
     repo = nixpkgs.fetchurl {
      url = "https://storage.googleapis.com/git-repo-downloads/repo";
      sha256 = "e147f0392686c40cfd7d5e6f332c6ee74c4eab4d24e2694b3b0a0c037bf51dc5";
     };
     android_manifest_url = "https://android.googlesource.com/platform/manifest";
     android_branch = "master";
     in nixpkgs.stdenv.mkDerivation {
      name = "aosp";
      buildInputs = targetPkgs nixpkgs;
      unpackPhase = ''
        mkdir $out
        cd $out
        ${nixpkgs.python}/bin/python ${repo} init -u ${android_manifest_url} -b ${android_branch}
        ${nixpkgs.python}/bin/python ${repo} sync

      '';

     }
