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
    "fabs" = testRange (0 - 2) 2 0.001 math.fabs;
    "div_3" = testRange (0 - 10) 10 0.001 (x: math.div x 3);
    "div_3_int" = testOnInputs (builtins.genList (x: x - 5) 11) (x: math.div x 3);
    "div_4.5" = testRange (0 - 10) 10 0.001 (x: math.div x 4.5);
    "div_-2.5" = testRange (0 - 10) 10 0.001 (x: math.div x (0 - 2.5));
    "mod_3" = testRange (0 - 10) 10 0.001 (x: math.mod x 3);
    "mod_3_int" = testOnInputs (builtins.genList (x: x - 5) 11) (x: math.mod x 3);
    "mod_4.5" = testRange (0 - 10) 10 0.001 (x: math.mod x 4.5);
    "mod_-2.5" = testRange (0 - 10) 10 0.001 (x: math.mod x (0 - 2.5));
    "pow_3" = testRange (0 - 10) 10 0.001 (x: math.pow x 3);
    "pow_0" = testRange (0 - 10) 10 0.001 (x: math.pow x 0);
    "factorial" = testRange 0 10 1 math.factorial;
    "sin" = testRange (0 - 10) 10 0.001 math.sin;
    "cos" = testRange (0 - 10) 10 0.001 math.cos;
    "tan" = testRange (0 - 10) 10 0.001 math.tan;
    "atan" = testRange (0 - 10) 10 0.001 math.atan;
    "int" = testRange (0 - 10) 10 0.001 math.int;
    "exp_large" = testRange (0 - 700) 700 0.1 math.exp;
    "exp_small" = testRange (0 - 2) 2 0.001 math.exp;
    "log_large" = testRange 1 10000 1 math.log;
    "log_small" = testRange 0.001 2 0.001 math.log;
    "log2" = testRange 1 10000 1 math.log2;
    "log10" = testRange 1 10000 1 math.log10;
    "powf_4.5" = testRange 1 100 0.01 (math.pow 4.5);
    "powf_-2.5" = testRange 1 100 1 (math.pow (0 - 2.5));
    "deg2rad" = testRange (0 - 360) 360 0.001 math.deg2rad;
    "sqrt" = testRange 0 10 0.001 math.sqrt;
  };
in
lib.mapAttrs (k: builtins.toJSON) tests
