{
  lib,
  options,
  config,
  test-module-arg,
  pkgs,
  test-specialArg,
  ...
}:
{
  options.msg = lib.mkOption { type = lib.types.str; };
  options.test = lib.mkOption { type = lib.types.str; };
  options.path = lib.mkOption { type = lib.types.str; };
  options.test2 = lib.mkOption { type = lib.types.str; };
  options.default = lib.mkOption { type = lib.types.str; default = "default";};

  config.msg = "hello world";
  config.test = "${test-module-arg}";
  config.path = "${pkgs.hello}/bin/hello";
  config.test2 = "${test-specialArg}";
}
