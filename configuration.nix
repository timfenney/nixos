# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.etc."keyd/default.conf" = {
    source = /home/hb/setup/keyd/default.conf;
    mode = "0440";
  };

  boot.loader = {
    # systemd-boot.enable = true; # no splash image :(
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      splashImage = ./xroyp.png; # put xroyp.png in /etc/nixos/, 640x480 png
    };
  };

  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    #keyd.enable = true; # wtf why won't this work
    logind.lidSwitch = "ignore";
    logind.lidSwitchDocked = "ignore";
    logind.lidSwitchExternalPower = "ignore";
    openssh.enable = true;
    picom.enable = true;
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };  
    xserver = {
      displayManager = {
        gdm.enable = true;
        defaultSession = "none+i3";
      };
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };
      enable = true;
      layout = "us";
      xkbVariant = "";
      # xkbOptions = "ctrl:swapcaps";

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
          i3blocks
        ];
      };
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # xserver.libinput.enable = true;
  };


  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hb = {
    isNormalUser = true;
    description = "Timothy Fenney";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    direnv
    docker
    docker-compose
    firefox-devedition-bin-unwrapped
    firefox-unwrapped
    gimp
    git
    i3-rounded
    jq
    keyd
    neovim
    picom
    tmux
    vim
    warsow
    wget
    zsh
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  systemd.packages = [ pkgs.keyd ];

  systemd.services.keyd = {
    description = "key remapping daemon";
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.keyd}/bin/keyd";
    };
    wantedBy = [ "sysinit.target" ];
    requires = [ "local-fs.target" ];
    after = [ "local-fs.target" ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "22.11";

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
