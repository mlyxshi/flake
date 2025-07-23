{ self, pkgs, lib, config, ... }: {
  # imports = [
  #   self.nixosModules.containers.podman
  # ];


  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  # '';  

  environment.systemPackages = with pkgs; [
    sing-box
  ];

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log.level = "info";
    dns = { };
    inbounds = [
      {
        type = "shadowsocks";
        tag = "ss-in-9999";
        listen = "0.0.0.0";
        listen_port = 9999;
        method = "aes-128-gcm";
        password = { _secret = "/secret/ss-password"; };
      }
    ];
  #   outbounds = [
  #     {
  #       type = "direct";
  #       tag = "direct-out";
  #     }
  #   ];

  #   route = {
  #   };
  # };
}
