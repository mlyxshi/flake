{ pkgs, lib, config, ... }: {

  sops.secrets.proxy-pwd = { };

  sops.templates.snell.content = ''
    [snell-server]                                                                                                                                            
    listen = 0.0.0.0:7777                                                                                                                                   
    psk = ${config.sops.placeholder.proxy-pwd}                                                                                                                    
    ipv6 = false
    obfs = tls
    obfs-host = www.bing.com
  '';

  systemd.services.snell = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.snell}/bin/snell-server -c ${config.sops.templates.snell.path}";
    };
  };
}