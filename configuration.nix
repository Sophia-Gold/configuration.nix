{ config, pkgs, ... }:

let 
    ocamlPackages = pkgs.recurseIntoAttrs pkgs.ocamlPackages_latest;
    ocamlVersion = (builtins.parseDrvName ocamlPackages.ocaml.name).version;
    merlinWithEmacsMode = ocamlPackages.merlin.override { withEmacsMode = true; };
in

{
  imports = [
    <nixos-hardware/lenovo/thinkpad/t480s>
    ./hardware-configuration.nix    
    # ./opam2nix-packages.nix
  ];

  boot = { 
    loader = {
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
      systemd-boot.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  
    extraModulePackages = [ config.boot.kernelPackages.bbswitch ];   

    blacklistedKernelModules = [ "nouveau" "nvidia" ];

    kernelParams = [
      "acpi_osi=!" 
      ''acpi_osi="Windows 2009"''
      "nvidia-drm.modeset=1"
    ];
 
    initrd.availableKernelModules = [
      "xkhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
      "sr_mod"
      "rtsx_pci_sdmmc"
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"    
    ];

  };

  networking = {
    hostName = "_";
    networkmanager.enable = true;
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Eastern";

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; 

    packageOverrides = pkgs: {

      packageKit = pkgs.packageKit.override {
        enableNixBackend = false;
      };

      myHaskellEnv = pkgs.haskellPackages.ghcWithHoogle
                       (haskellPackages: with haskellPackages; [
                         arrows
                         async 
                         criterion
                         lens
                         # enumerator
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
                         cabal-install
                         haskintex
                       ]);
      };
  };
          
  environment.variables = { 
    __GLVND_DISALLOW_PATCHING = "1";
    findlib = "${ocamlPackages.findlib}/lib/ocaml/${ocamlVersion}/site-lib";
  };

  environment.systemPackages = with pkgs;
    [ 
      # unfree
      google-chrome
      dropbox
      spotify
      # skype
      xflux
      (oraclejdk8distro true true) 
    ] ++
    [
      patchelf
      networkmanagerapplet
      pass
      browserpass
      gnupg1
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
      graphviz
      gifsicle
      vlc
      rhythmbox
      ispell
      brasero
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
      go2nix
      myHaskellEnv
      stack
      cabal2nix
      nodejs
      closurecompiler
      gcc
      llvm
      clang
      cmake
      gnumake
      gnum4
      gmp
      fftw
      boost
      dmd
      python3
      puredata
      arduino
      # processing
      ocaml
      opam
      jbuilder
      docker
      heroku
      pari
      rustup
      mercurial
      darcs
    ] ++
    (with ocamlPackages; [
      # async
      lwt3
      # core
      js_of_ocaml
      js_of_ocaml-ppx
      merlinWithEmacsMode
      # utop
      findlib
      yojson
      zarith
      # batteries
      # ocpIndent
      alcotest
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
      xorg.libpciaccess
      hfsprogs
      dmg2img
      mkinitcpio-nfs-utils
      p7zip
      dpkg
      jq
      tshark
      pciutils
      parted
      gparted
      binutils
      unzip
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
      idris-mode
      tuareg
      opam
      nix-mode
      web-mode
      js2-mode
      js-comint
      gnuplot-mode
      pandoc-mode
      evil
      exec-path-from-shell
      rainbow-mode
      rainbow-delimiters
      rainbow-identifiers
      rainbow-blocks
      json-mode
      yaml-mode
      highlight-indentation
      pcap-mode
      markdown-mode
      rust-mode
      toml-mode
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

  hardware.bumblebee = {
    enable = true;
    driver = "nvidia";
    group = "video";
  };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "ctrl:nocaps";
    # videoDriver = "nvidia";
    displayManager.gdm.enable = false;
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
    # windowManager.xmonad = {
    #   enable = true;
    #  enableContribAndExtras = true;
    # extraPackages = haskellPackages: [
    #   haskellPackages.xmonad-contrib
    #   haskellPackages.xmonad-extras
    #   haskellPackages.xmonad
    #   ];
    # };
    # windowManager.default = "xmonad";
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
  system.stateVersion = "18.03";

}
