{ config, pkgs, ... }:

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

  boot.kernelPackages = pkgs.linuxPackages_4_9;

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
     
    packageOverrides = super: let self = super.pkgs; in
    {
      myHaskellEnv = self.haskellPackages.ghcWithHoogle
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
                         xmonad
                         xmonad-extras
                         xmonad-contrib
                         # tools
                         cabal-install
                         haskintex
                       ]);
       };
    # import /root/.nixpkgs/config.nix;
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
      xorg.xf86inputsynaptics
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
      # core_extended
      findlib
      merlinWithEmacsMode
      js_build_tools
    ]) ++
    [ 
      # System Tools
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
      powerline
      lush-theme
      cyberpunk-theme
      magit
      geiser
      paredit
      clojure-mode
      clojure-cheatsheet
      cider
      haskell-mode
      tuareg
      nix-mode
      web-mode
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
    displayManager.gdm.enable = true;
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
    #windowManager.xmonad = {
    #  enable = true;
    #  enableContribAndExtras = true;
    #  extraPackages = haskellPackages: [
    #    haskellPackages.xmonad-contrib
    #    haskellPackages.xmonad-extras
    #    haskellPackages.xmonad
    #  ];
    #};
    #windowManager.default = "xmonad";
    displayManager.sessionCommands = with pkgs; 
    lib.mkAfter ''xmodmap /path/to/.Xmodmap'';
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
