{
  lib,
  math,
  ...
}:
let
  testOnInputs =
    inputs: fn:
    builtins.listToAttrs (
      builtins.map (v: {
        name = builtins.toString v;
        value = fn v;
      }) inputs
    );

  testRange =
    min: max: step:
    testOnInputs (math.arange2 min max step);

  tests = {
    "atan" = testRange (0 - 10) 10 0.001 math.atan;
    "cos" = testRange (0 - 10) 10 0.001 math.cos;
    "deg2rad" = testRange (0 - 360) 360 0.001 math.deg2rad;
    "div_-2.5" = testRange (0 - 10) 10 0.001 (x: math.div x (0 - 2.5));
    "div_3_int" = testOnInputs (builtins.genList (x: x - 5) 11) (x: math.div x 3);
    "div_3" = testRange (0 - 10) 10 0.001 (x: math.div x 3);
    "div_4.5" = testRange (0 - 10) 10 0.001 (x: math.div x 4.5);
    "exp_large" = testRange (0 - 700) 700 0.1 math.exp;
    "exp_small" = testRange (0 - 2) 2 0.001 math.exp;
    "fabs" = testRange (0 - 2) 2 0.001 math.fabs;
    "factorial" = testRange 0 10 1 math.factorial;
    "int" = testRange (0 - 10) 10 0.001 math.int;
    "log_large" = testRange 1 10000 1 math.log;
    "log_small" = testRange 0.001 2 0.001 math.log;
    "log10" = testRange 1 10000 1 math.log10;
    "log2" = testRange 1 10000 1 math.log2;
    "mod_-2.5" = testRange (0 - 10) 10 0.001 (x: math.mod x (0 - 2.5));
    "mod_3_int" = testOnInputs (builtins.genList (x: x - 5) 11) (x: math.mod x 3);
    "mod_3" = testRange (0 - 10) 10 0.001 (x: math.mod x 3);
    "mod_4.5" = testRange (0 - 10) 10 0.001 (x: math.mod x 4.5);
    "pow_-2.5" = testRange 1 100 1 (math.pow (0 - 2.5));
    "pow_0" = testRange (0 - 10) 10 0.001 (x: math.pow x 0);
    "pow_3" = testRange (0 - 10) 10 0.001 (x: math.pow x 3);
    "pow_4.5" = testRange 1 100 0.01 (math.pow 4.5);
    "sin" = testRange (0 - 10) 10 0.001 math.sin;
    "sqrt" = testRange 0 10 0.001 math.sqrt;
    "tan" = testRange (0 - 10) 10 0.001 math.tan;
  };
in
lib.mapAttrs (k: builtins.toJSON) tests
