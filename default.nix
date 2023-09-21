{lib, ...}: rec {
  inherit (builtins) floor ceil;

  pi = 3.14159265358979323846264338327950288;
  epsilon = pow (0.1) 10;

  sum = builtins.foldl' builtins.add 0;
  multiply = builtins.foldl' builtins.mul 1;

  # Absolute value of `x`
  abs = x:
    if x < 0
    then 0 - x
    else x;

  # Absolute value of `x`
  fabs = abs;

  # Create a list of numbers from `min` (inclusive) to `max` (exclusive), adding `step` each time.
  arange = min: max: step: let
    count = floor ((max - min) / step);
  in
    lib.genList (i: min + step * i) count;

  # Create a list of numbers from `min` (inclusive) to `max` (inclusive), adding `step` each time.
  arange2 = min: max: step: arange min (max + step) step;

  # Calculate x^0*poly[0] + x^1*poly[1] + ... + x^n*poly[n]
  polynomial = x: poly: let
    step = i: (pow x i) * (builtins.elemAt poly i);
  in
    sum (lib.genList step (builtins.length poly));

  parseFloat = builtins.fromJSON;

  hasFraction = x: let
    splitted = lib.splitString "." (builtins.toString x);
  in
    builtins.length splitted >= 2 && builtins.length (builtins.filter (ch: ch != "0") (lib.stringToCharacters (builtins.elemAt splitted 1))) > 0;

  # Divide `a` by `b` with no remainder.
  div = a: b: let
    divideExactly = !(hasFraction (1.0 * a / b));
    offset =
      if divideExactly
      then 0
      else (0 - 1);
  in
    if b < 0
    then offset - div a (0 - b)
    else if a < 0
    then offset - div (0 - a) b
    else floor (1.0 * a / b);

  # Modulos of dividing `a` by `b`.
  mod = a: b:
    if b < 0
    then 0 - mod (0 - a) (0 - b)
    else if a < 0
    then mod (b - mod (0 - a) b) b
    else a - b * (div a b);

  # Returns `a` to the power of `b`. **Only supports integer for `b`!**
  pow = x: times: multiply (lib.replicate times x);

  # Returns factorial of `x`. `x` is an integer, `x >= 0`.
  factorial = x: multiply (lib.range 1 x);

  # Trigonometric function. Takes radian as input.
  # Taylor series: for x >= 0, sin(x) = x - x^3/3! + x^5/5! - ...
  sin = x: let
    x' = mod (1.0 * x) (2 * pi);
    step = i: (pow (0 - 1) (i - 1)) * multiply (lib.genList (j: x' / (j + 1)) (i * 2 - 1));
    helper = tmp: i: let
      value = step i;
    in
      if (fabs value) < epsilon
      then tmp
      else helper (tmp + value) (i + 1);
  in
    if x < 0
    then -sin (0 - x)
    else helper 0 1;

  # Trigonometric function. Takes radian as input.
  cos = x: sin (0.5 * pi - x);

  # Trigonometric function. Takes radian as input.
  tan = x: (sin x) / (cos x);

  # Arctangent function. Polynomial approximation.
  atan = x: let
    poly = [
      0.0000000
      0.9999991
      0.0000366
      (0 - 0.3339528)
      0.0056430
      0.1691462
      0.1069422
      (0 - 0.3814731)
      0.3316130
      (0 - 0.1347978)
      0.0222419
    ];
  in
    if x < 0
    then -atan (0 - x)
    else if x > 1
    then pi / 2 - atan (1 / x)
    else polynomial x poly;

  # Degrees to radian.
  deg2rad = x: x * pi / 180;

  # Square root of `x`. `x >= 0`.
  sqrt = x: let
    helper = tmp: let
      value = (tmp + 1.0 * x / tmp) / 2;
    in
      if (fabs (value - tmp)) < epsilon
      then value
      else helper value;
  in
    if x < epsilon
    then 0
    else helper (1.0 * x);

  # Returns distance of two points on Earth for the given latitude/longitude.
  # https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
  haversine = lat1: lon1: lat2: lon2: let
    radius = 6371000;
    rad_lat = deg2rad ((1.0 * lat2) - (1.0 * lat1));
    rad_lon = deg2rad ((1.0 * lon2) - (1.0 * lon1));
    a = (sin (rad_lat / 2)) * (sin (rad_lat / 2)) + (cos (deg2rad (1.0 * lat1))) * (cos (deg2rad (1.0 * lat2))) * (sin (rad_lon / 2)) * (sin (rad_lon / 2));
    c = 2 * atan ((sqrt a) / (sqrt (1 - a)));
  in
    radius * c;
}
