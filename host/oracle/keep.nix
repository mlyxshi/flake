# https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm

# Idle Always Free compute instances may be reclaimed by Oracle. Oracle will deem virtual machine and bare metal compute instances as idle if, during a 7-day period, the following are true:

# CPU utilization for the 95th percentile is less than 20%
# Network utilization is less than 20%
# Memory utilization is less than 20% (applies to A1 shapes only)

{ pkgs, lib, config, ... }:
let
  waste = pkgs.writeText "waste.py" ''
    memory = bytearray(int(4.8*1024*1024*1024)) # 4.8G (20% of 24G)
    while True:
      pass
  '';
in
{
  systemd.services.KeepCPUMemory = {
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.python3}/bin/python ${waste}";
    };
    serviceConfig.CPUQuota = "80%"; # E2.1.Micro 2 Core | A1 4 Core
    serviceConfig.CPUWeight = 1;
    wantedBy = [ "multi-user.target" ];
  };
}
