{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix    
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sdb"; # or "nodev" for efi only

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config = {
    allowUnfree = true;
    import = /root/.nixpkgs/config.nix;
  };
  environment.systemPackages = with pkgs; [
    wget
    networkmanagerapplet
    dhcpcd
    firefox
    irssi
    git
    vim
    brackets
    mitscheme
    guile
    chicken
    chez
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
    xorg.xf86inputsynaptics
    (emacsWithPackages (with emacs24PackagesNg; [
      powerline
      lush-theme
      clojure-mode
      haskell-mode
      geiser
      web-mode
      js-comint
    ])) 
    # unfree
    google-chrome
    dropbox
    spotify
    xflux
    (oraclejdk8distro true true)
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
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
    # KDE Desktop Environment
    # displayManager.kdm.enable = true;
    # desktopManager.kde4.enable = true;
    # XMonad Desktop Environment
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  # Fonts
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
     ];
   };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.guest = {
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

}
