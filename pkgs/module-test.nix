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
  options.default = lib.mkOption {
    type = lib.types.str;
    default = "default";
  };

  options.subraw = lib.mkOption {
    type = lib.types.submodule {
      options = {
        foo = lib.mkOption { type = lib.types.int; };
        bar = lib.mkOption { type = lib.types.str; };
      };
    };
  };

  options.sub = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          foo = lib.mkOption { type = lib.types.int; };
          bar = lib.mkOption { type = lib.types.str; };
        };
      }
    );
  };

  config.msg = "hello world";
  config.test = "${test-module-arg}";
  config.path = "${pkgs.hello}/bin/hello";
  config.test2 = "${test-specialArg}";

  config.subraw = {
    foo = 1;
    bar = "hello";
  };

  config.sub = {
    a = {
      foo = 1;
      bar = "hello";
    };
  };
}
