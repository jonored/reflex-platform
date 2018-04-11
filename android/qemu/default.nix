pkgs: {
  qemu = pkgs.pkgs.qemu.overrideAttrs (old: {
    patches = old.patches ++ [./android-qemu-support.patch];
    configureFlags = 
      old.configureFlags
      ++ ["--target-list=arm-linux-user,aarch64-linux-user"];
    });
}
