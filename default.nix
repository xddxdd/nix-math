{lib, ...}: rec {
  pi = 3.1415926;
  epsilon = 0.000001;

  sum = builtins.foldl' builtins.add 0;
  multiply = builtins.foldl' builtins.mul 1;

  abs = x:
    if x < 0
    then 0 - x
    else x;
  fabs = abs;

  arange = min: max: step: let
    count = floor ((max - min) / step);
  in
    lib.genList (i: min + step * i) count;

  arange2 = min: max: step: arange min (max + step) step;

  parseFloat = builtins.fromJSON;

  hasFraction = x: let
    splitted = lib.splitString "." (builtins.toString x);
  in
    builtins.length splitted >= 2 && builtins.length (builtins.filter (ch: ch != "0") (lib.stringToCharacters (builtins.elemAt splitted 1))) > 0;

  floor = x: let
    splitted = lib.splitString "." (builtins.toString x);
    num = lib.toInt (builtins.head splitted);
  in
    if x < 0 && (hasFraction x)
    then num - 1
    else num;

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

  mod = a: b:
    if b < 0
    then 0 - mod (0 - a) (0 - b)
    else if a < 0
    then mod (b - mod (0 - a) b) b
    else a - b * (div a b);

  pow = x: times: multiply (lib.replicate times x);

  factorial = x: multiply (lib.range 1 x);

  # Taylor series: for x >= 0, atan(x) = x - x^3/3! + x^5/5!
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

  cos = x: sin (0.5 * pi - x);

  tan = x: (sin x) / (cos x);

  # https://stackoverflow.com/questions/42537957/fast-accurate-atan-arctan-approximation-algorithm
  atan = x: let
    A = 0.0776509570923569;
    B = 0 - 0.287434475393028;
    C = pi / 4 - A - B;
  in
    if x < 0
    then -atan (0 - x)
    else if x > 1
    then pi / 2 - atan (1 / x)
    else ((A * x * x + B) * x * x + C) * x;

  deg2rad = x: x * pi / 180;

  sqrt = x:
    if x < epsilon
    then 0
    else builtins.foldl' (i: _: (i + 1.0 * x / i) / 2) (1.0 * x) (lib.range 1 10);

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
