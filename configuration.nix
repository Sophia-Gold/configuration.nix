{ config, pkgs, ... }:

let 
    ocamlPackages = pkgs.recurseIntoAttrs pkgs.ocamlPackages_latest;
    ocamlVersion = (builtins.parseDrvName ocamlPackages.ocaml.name).version;
    merlinWithEmacsMode = ocamlPackages.merlin.override { withEmacsMode = true; };

    baseconfig = { allowUnfree = true; };
    unstable = import <unstable> { config = baseconfig; };
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

  hardware.u2f.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  nixpkgs.config = baseconfig // {
    allowUnfree = true;
    allowBroken = true;

    packageOverrides = super: let self = super.pkgs; in {
      myHaskellEnv = pkgs.haskellPackages.ghcWithHoogle
                       (haskellPackages: with haskellPackages; [
                         arrows
                         async 
                         criterion
                         lens
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

  programs.browserpass.enable = true;

  environment.systemPackages = with pkgs;
    [ 
      # unfree
      google-chrome
      dropbox
      spotify
      skype
      xflux
      # (oraclejdk8distro true true) 
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
      bluez
      blueman
      pandoc
      brave
      hplip
      saneBackends
      audio-recorder
      gnupg
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
      ocaml
      opam
      jbuilder
      docker
      heroku
      pari
      rustup
      rustfmt
      mercurial
      darcs
      hydra
      nox
      coq
    ] ++
    (with ocamlPackages; [
      # lwt3
      # js_of_ocaml
      # js_of_ocaml-ppx
      merlin
      utop
      findlib
      yojson
      zarith
      batteries
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
      tree
    ] ++
    [(emacsWithPackages (with emacsPackagesNg; [
      solarized-theme
      lush-theme
      cyberpunk-theme
      powerline
      nlinum
      magit
      geiser
      paredit
      clojure-mode
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
      proofgeneral
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
   
    windowManager.i3.enable = true;
 
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
