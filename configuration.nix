{ config, pkgs, ... }:

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
    import = /root/.nixpkgs/config.nix;
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
                         ghc-core 
                         mueval
                         either-unwrap 
                         prelude-extras
                         xmonad
                         xmonad-extras
                         xmonad-contrib
                         # tools
                         cabal-install
                         haskintex
                       ]);
   };
  };

  environment.systemPackages = with pkgs; [
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
    xorg.xf86inputsynaptics
    #coding tools
    mitscheme
    guile
    chicken
    chez
    pltScheme
    clojure
    leiningen
    maven
    openjdk
    go
    myHaskellEnv
    cabal2nix
    ocaml
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
    #system tools
    wget
    dhcpcd
    less
    rlwrap
    findutils
    perf-tools
    htop
    pkgconfig
    numactl
    diffutils
    hfsprogs
    dmg2img
    p7zip
    (emacsWithPackages (with emacs24PackagesNg; [
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
      nix-mode
      web-mode
      js-comint
      gnuplot-mode
      pandoc-mode
      evil
    ]))
    # unfree
    google-chrome
    dropbox
    spotify
    skype
    xflux
    (oraclejdk8distro true true)
  ];
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
    # displayManager.kdm.enable = true;
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

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
