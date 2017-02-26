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

  # fileSystems = {
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
  };
  environment.systemPackages = with pkgs; [
    wget
    networkmanagerapplet
    dhcpcd
    hfsprogs
    dmg2img
    p7zip
    firefox
    irssi
    gimp-with-plugins
    git
    vim
    brackets
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
    ghc
    cabal-install
    stack
    nodejs
    closurecompiler
    gcc
    llvm
    clang
    dmd
    puredata
    arduino
    processing
    gnuplot
    xorg.xf86inputsynaptics
    (emacsWithPackages (with emacs24PackagesNg; [
      powerline
      lush-theme
      clojure-mode
      haskell-mode
      geiser
      web-mode
      js-comint
      gnuplot-mode
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
    };
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
