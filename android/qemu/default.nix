{ nixpkgs }: let
  qemu = nixpkgs.qemu.overrideAttrs (old: {
    patches = old.patches ++ [./android-qemu-support.patch];
    configureFlags = 
      old.configureFlags
      ++ ["--target-list=arm-linux-user,aarch64-linux-user"];
    });
  aosp = import ./aosp { nixpkgs = nixpkgs; };
  aospPrebuilt = nixpkgs.stdenv.mkDerivation {
    name = "aosp-prebuilt";
    src = nixpkgs.fetchurl {
      url = "https://s3.amazonaws.com/jonored/reflex/android-aarch64-dual-system.tar.gz";
      sha256 = "1a0xh9rq9dm1whgzabcasc5acg70alppz5zq0jm4m5lj7gip0npy";
    };
    buildCommand = ''
        mkdir $out
        cd $out
        tar -xzvf $src
    '';
  };
  qemuAndroidUser = nixpkgs.stdenv.mkDerivation {
    name = "qemu-user-android";
    buildInputs = [ aospPrebuilt qemu nixpkgs.makeWrapper ];
    passthru = { inherit qemu aospPrebuilt aosp; };
    inherit aospPrebuilt qemu;
    buildCommand = ''
      mkdir -p $out/bin
      # This does have the downside of "these aren't valid shebang-line interpreters anymore"
      makeWrapper ${qemu}/bin/qemu-arm $out/bin/qemu-arm --set QEMU_LD_PREFIX ${aospPrebuilt}
      makeWrapper ${qemu}/bin/qemu-aarch64 $out/bin/qemu-aarch64 --set QEMU_LD_PREFIX ${aospPrebuilt}
    '';
  };
in qemuAndroidUser
