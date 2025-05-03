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
        # toJSON will output float upto precision limit
        # toString will round the float, causing imprecisions during check
        #
        # Example:
        #
        # nix-repl> builtins.toJSON (0-10+0.001*9985)
        # "-0.015000000000000568"
        #
        # nix-repl> builtins.toString (0-10+0.001*9985)
        # "-0.015000"
        name = builtins.toJSON v;
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
    "ln_large" = testRange 1 10000 1 math.ln;
    "ln_small" = testRange 0.001 2 0.001 math.ln;
    "log10" = testRange 1 10000 1 math.log10;
    "log2" = testRange 1 10000 1 math.log2;
    "mod_-2.5" = testRange (0 - 10) 10 0.001 (x: math.mod x (0 - 2.5));
    "mod_3_int" = testOnInputs (builtins.genList (x: x - 5) 11) (x: math.mod x 3);
    "mod_3" = testRange (0 - 10) 10 0.001 (x: math.mod x 3);
    "mod_4.5" = testRange (0 - 10) 10 0.001 (x: math.mod x 4.5);
    "pow_-2.5_x" = testRange 1 100 1 (math.pow (0 - 2.5));
    # Avoid `pow 0 -2` since that is undefined
    "pow_x_-2_positive" = testRange 0.001 10 0.001 (x: math.pow x (0 - 2));
    "pow_x_-2_negative" = testRange (0 - 10) (0 - 0.001) 0.001 (x: math.pow x (0 - 2));
    "pow_x_0" = testRange (0 - 10) 10 0.001 (x: math.pow x 0);
    "pow_x_3" = testRange (0 - 10) 10 0.001 (x: math.pow x 3);
    "pow_4.5_x" = testRange 1 100 0.01 (math.pow 4.5);
    "round" = testRange (0 - 10) 10 0.001 math.round;
    "sin" = testRange (0 - 10) 10 0.001 math.sin;
    "sqrt" = testRange 0 10 0.001 math.sqrt;
    "tan" = testRange (0 - 10) 10 0.001 math.tan;
  };
in
lib.mapAttrs (k: builtins.toJSON) tests
