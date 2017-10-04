{ stdenv, requireFile, config, pkgs, ... }:

let 
    ocamlPackages = pkgs.recurseIntoAttrs pkgs.ocamlPackages_latest;
    ocamlVersion = (builtins.parseDrvName ocamlPackages.ocaml.name).version;
    merlinWithEmacsMode = ocamlPackages.merlin.override { withEmacsMode = true; };
in

{
  imports = [
    ./hardware-configuration.nix    
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sdb";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # filesystems = {
  #   "/home/sophia/hdd/" = { 
  #     device = "dev/sda";
  #   };
  # };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/New_York";

  nixpkgs.config = {
    allowUnfree = true;
     
    packageOverrides = pkgs: {

      packageKit = pkgs.packageKit.override {
        enableNixBackend = false;
      };

      myHaskellEnv = pkgs.haskellPackages.ghcWithHoogle
                       (haskellPackages: with haskellPackages; [
                         # libraries
                         arrows
                         async 
                         cgi 
                         criterion
                         lens
                         enumerator
                         generic-deriving
                         singletons
                         logict
                         either
                         either-unwrap
                         ghc-core 
                         mueval 
                         prelude-extras
                         protolude
                         idris
                         # tools
                         cabal-install
                         haskintex
                       ]);

      oraclejdk8distro = let
        abortArch = abort "jdk requires i686-linux, x86_64-linux, or armv7l-linux";
        productVersion = "8";
        patchVersion = "144";
        downloadUrl = http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html;
        sha256_i686 = "1i5pginc65xl5vxzwid21ykakmfkqn59v3g01vpr94v28w30jk32";
        sha256_x86_64 = "1r5axvr8dg2qmr4zjanj73sk9x50m7p0w3vddz8c6ckgav7438z8";
        sha256_armv7l = "10r3nyssx8piyjaspravwgj2bnq4537041pn0lz4fk5b3473kgfb";
        jceName = "jce_policy-8.zip";
        jceDownloadUrl = http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html;
        sha256JCE = "0n8b6b8qmwb14lllk2lk1q1ahd3za9fnjigz5xn65mpg48whl0pk";
      in pkgs.oraclejdk8distro.overrideAttrs (oldAttrs: {
        name = "oraclejdk-${productVersion}u${patchVersion}";
        src =
          if stdenv.system == "i686-linux" then
            requireFile {
              name = "jdk-${productVersion}u${patchVersion}-linux-i586.tar.gz";
              url = downloadUrl;
              sha256 = sha256_i686;
            }
          else if stdenv.system == "x86_64-linux" then
            requireFile {
              name = "jdk-${productVersion}u${patchVersion}-linux-x64.tar.gz";
              url = downloadUrl;
              sha256 = sha256_x86_64;
            }
          else if stdenv.system == "armv7l-linux" then
            requireFile {
              name = "jdk-${productVersion}u${patchVersion}-linux-arm32-vfp-hflt.tar.gz";
              url = downloadUrl;
              sha256 = sha256_armv7l;
            }
          else
            abortArch;
      });
    };
  };
          
  environment.variables = {
    findlib = "${ocamlPackages.findlib}/lib/ocaml/${ocamlVersion}/site-lib";
  };

  environment.systemPackages = with pkgs;
    [ 
      # unfree
      google-chrome
      dropbox
      spotify
      skype
      xflux
      (oraclejdk8distro true true) 
    ] ++
    [
      networkmanagerapplet
      firefox
      irssi
      gimp-with-plugins
      gnuplot
      libreoffice
      anki
      simplescreenrecorder
      simgrid
      git
      vim
      brackets
      marp
      gifsicle
      # xorg.xf86inputsynaptics
    ] ++
    [ 
      # Dev Stuff
      mitscheme
      guile
      chicken
      chez
      pltScheme
      clojure
      leiningen
      boot
      maven
      openjdk
      go
      myHaskellEnv
      cabal2nix
      nodejs
      closurecompiler
      gcc
      llvm
      clang
      cmake
      gnumake
      boost
      dmd
      python3
      puredata
      arduino
      processing
      ocaml
      heroku
    ] ++
    (with ocamlPackages; [
      camlp4
      core
      findlib
      merlinWithEmacsMode
      js_build_tools
    ]) ++
    [ 
      # System Tools
      nixops
      wget
      dhcpcd
      file
      less
      rlwrap
      findutils
      perf-tools
      htop
      pkgconfig
      numactl
      diffutils
      screen
      tmux
      hfsprogs
      dmg2img
      mkinitcpio-nfs-utils
      p7zip
      dpkg
    ] ++
    [(emacsWithPackages (with emacs25PackagesNg; [
      solarized-theme
      lush-theme
      cyberpunk-theme
      powerline
      nlinum
      magit
      geiser
      paredit
      clojure-mode
      clojure-cheatsheet
      cider
      haskell-mode
      tuareg
      idris-mode
      nix-mode
      web-mode
      js2-mode
      js-comint
      gnuplot-mode
      pandoc-mode
      evil
    ]))];

  environment.shellAliases.ghci = "ghci -ghci-script
    ${pkgs.writeText "ghci.conf"
      '':def hoogle \s -> return $ ":! hoogle search -cl --count=15 \"" ++ s ++ "\""'
        :def doc \s -> return $ ":! hoogle search -cl --info \"" ++ s ++ "\""''
     }";
 
  # Enable the OpenSSH server.
  # services.openssh.enable = true;

  # Eable CUPS to print documents
  # services.printing.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    # synaptics.enable = true;
    videoDriver = "nvidia";
    # displayManager.gdm.enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.default = "gnome3";

    # Gnome3 Desktop Environment
    desktopManager.gnome3 = {
     enable = true;
     sessionPath = [
      pkgs.gnome3.gnome_shell
      pkgs.gnome3.gnome-shell-extensions
     ];
    };

    # KDE Desktop Manager
    # desktopManager.kde4.enable = true;
    
    # XMonad Window Manager
    windowManager.xmonad = {
     enable = true;
     enableContribAndExtras = true;
     extraPackages = haskellPackages: [
      haskellPackages.xmonad-contrib
      haskellPackages.xmonad-extras
      haskellPackages.xmonad
     ];
    };
    windowManager.default = "xmonad";
  };

  fonts = {
     enableFontDir = true;
     enableGhostscriptFonts = true;
     fonts = with pkgs; [
       corefonts  # Micrsoft free fonts
       inconsolata  # monospaced
       ubuntu_font_family  # Ubuntu fonts
       unifont # some international languages
       dejavu_fonts
       vistafonts # contains Consolas
       emojione
     ];
   };

  users.extraUsers.guest = {
  };

  # NixOS Version
  system.stateVersion = "16.09";

}
