{zx-dev}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cfg = config.services.zx-dev;
in {
  options.services.zx-dev = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable serving zx.dev via nginx";
    };

    domain = mkOption {
      type = types.str;
      default = "example.local";
      description = "Domain name for the site";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the default ports in the firewall for nginx.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.enable = true;

    services.nginx.virtualHosts.${cfg.domain} = {
      root = "${zx-dev}";
      extraConfig = ''
        autoindex off;
      '';
    };
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [80];
    };
  };
}
