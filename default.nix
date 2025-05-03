{ lib, ... }:
rec {
  inherit (builtins) floor ceil;

  pi = 3.14159265358979323846264338327950288;
  e = 2.718281828459045235360287471352;
  epsilon = _pow_int (0.1) 10;

  sum = builtins.foldl' builtins.add 0;
  multiply = builtins.foldl' builtins.mul 1;

  # Absolute value of `x`
  abs = x: if x < 0 then 0 - x else x;

  # Absolute value of `x`
  fabs = abs;

  # Returns `a` to the power of `b`. **Only supports integer for `b`!**
  # Internal use only. Users should use `_pow_int`, which supports floating point exponentials.
  _pow_int =
    x: times:
    if times == 0 then
      1
    else if times < 0 then
      1 / (_pow_int x (0 - times))
    else
      multiply (lib.replicate times x);

  # Create a list of numbers from `min` (inclusive) to `max` (exclusive), adding `step` each time.
  arange =
    min: max: step:
    let
      count = floor ((max - min) / step);
    in
    lib.genList (i: min + step * i) count;

  # Create a list of numbers from `min` (inclusive) to `max` (inclusive), adding `step` each time.
  arange2 =
    min: max: step:
    arange min (max + step) step;

  # Calculate x^0*poly[0] + x^1*poly[1] + ... + x^n*poly[n]
  polynomial =
    x: poly:
    let
      step = i: (_pow_int x i) * (builtins.elemAt poly i);
    in
    sum (lib.genList step (builtins.length poly));

  parseFloat = builtins.fromJSON;

  int = x: if x < 0 then -int (0 - x) else builtins.floor x;

  round =
    x:
    let
      intPart = builtins.floor x;
      intIsEven = 0 == mod intPart 2;
      fractionPart = x - intPart;
    in
    if abs (fractionPart - 0.5) < epsilon then
      if intIsEven then intPart else intPart + 1
    else if fractionPart < 0.5 then
      intPart
    else
      intPart + 1;

  hasFraction =
    x:
    let
      splitted = lib.splitString "." (builtins.toString x);
    in
    builtins.length splitted >= 2
    &&
      builtins.length (
        builtins.filter (ch: ch != "0") (lib.stringToCharacters (builtins.elemAt splitted 1))
      ) > 0;

  # Divide `a` by `b` with no remainder.
  div =
    a: b:
    let
      divideExactly = !(hasFraction (1.0 * a / b));
      offset = if divideExactly then 0 else (0 - 1);
    in
    if b < 0 then
      offset - div a (0 - b)
    else if a < 0 then
      offset - div (0 - a) b
    else
      floor (1.0 * a / b);

  # Modulos of dividing `a` by `b`.
  mod =
    a: b:
    if b < 0 then
      0 - mod (0 - a) (0 - b)
    else if a < 0 then
      mod (b - mod (0 - a) b) b
    else
      a - b * (div a b);

  # Returns factorial of `x`. `x` is an integer, `x >= 0`.
  factorial = x: multiply (lib.range 1 x);

  # Trigonometric function. Takes radian as input.
  # Taylor series: for x >= 0, sin(x) = x - x^3/3! + x^5/5! - ...
  sin =
    x:
    let
      x' = mod (1.0 * x) (2 * pi);
      step = i: (_pow_int (0 - 1) (i - 1)) * multiply (lib.genList (j: x' / (j + 1)) (i * 2 - 1));
      helper =
        tmp: i:
        let
          value = step i;
        in
        if (fabs value) < epsilon then tmp else helper (tmp + value) (i + 1);
    in
    if x < 0 then -sin (0 - x) else helper 0 1;

  # Trigonometric function. Takes radian as input.
  cos = x: sin (0.5 * pi - x);

  # Trigonometric function. Takes radian as input.
  tan = x: (sin x) / (cos x);

  # Arctangent function. Polynomial approximation.
  atan =
    x:
    let
      poly = builtins.fromJSON "[-3.45783607234591e-15, 0.99999999999744, 5.257304414192212e-10, -0.33333336391488594, 8.433269318729302e-07, 0.1999866363777591, 0.00013446991236889277, -0.14376659407790288, 0.00426000182788111, 0.097197156521193, 0.030912220117352136, -0.133167493353323, 0.020663690408239177, 0.11398478735740854, -0.06791459641806276, -0.06663597903061667, 0.11580255232044795, -0.07215375057397233, 0.022284945086684438, -0.0028573630133916046]";
    in
    if x < 0 then
      -atan (0 - x)
    else if x > 1 then
      pi / 2 - atan (1 / x)
    else
      polynomial x poly;

  # Exponential function. Polynomial approximation.
  # (https://github.com/nadavrot/fast_log)
  exp =
    x:
    let
      x_int = int x;
      x_decimal = x - x_int;
      decimal_poly = builtins.fromJSON "[0.9999999999999997, 0.9999999999999494, 0.5000000000013429, 0.16666666664916754, 0.04166666680065545, 0.008333332669176907, 0.001388891142716621, 0.00019840730702746657, 2.481076351588151e-05, 2.744709498016379e-06, 2.846575263734758e-07, 2.0215584670370862e-08, 3.542885385105854e-09]";
    in
    if x < 0 then 1 / (exp (0 - x)) else (_pow_int e x_int) * (polynomial x_decimal decimal_poly);

  # Logarithmetic function. Takes radian as input.
  # Taylor series: for 1 <= x <= 1.9, ln(x) = (x-1)/1 - (x-1)^2/2 + (x-1)^3/3
  #   (https://en.wikipedia.org/wiki/Logarithm#Taylor_series)
  # For x >= 1.9, ln(x) = 2 * ln(sqrt(x))
  # For 0 < x < 1, ln(x) = -ln(1/x)
  #
  # Although Taylor series applies to 0 <= x <= 2, calculation outside
  # 1 <= x <= 1.9 is very slow and may cause max-call-depth exceeded
  ln =
    x:
    let
      step = i: (_pow_int (0 - 1) (i - 1)) * (_pow_int (1.0 * x - 1.0) i) / i;
      helper =
        tmp: i:
        let
          value = step i;
        in
        if (fabs value) < epsilon then tmp else helper (tmp + value) (i + 1);
    in
    if x <= 0 then
      throw "ln(x<=0) returns invalid value"
    else if x < 1 then
      -ln (1 / x)
    else if x > 1.9 then
      2 * (ln (sqrt x))
    else
      helper 0 1;

  # Power function that supports float.
  # pow(x, y) = exp(y * ln(x)), plus a few edge cases.
  pow =
    x: times:
    let
      is_int_times = abs (times - int times) < epsilon;
    in
    if is_int_times then
      _pow_int x (int times)
    else if x == 0 then
      0
    else if x < 0 then
      throw "Calculating power of negative base and decimal exponential is not supported"
    else
      exp (times * ln x);

  log = base: x: (ln x) / (ln base);
  log2 = log 2;
  log10 = log 10;

  # Degrees to radian.
  deg2rad = x: x * pi / 180;

  # Square root of `x`. `x >= 0`.
  sqrt =
    x:
    let
      helper =
        tmp:
        let
          value = (tmp + 1.0 * x / tmp) / 2;
        in
        if (fabs (value - tmp)) < epsilon then value else helper value;
    in
    if x < epsilon then 0 else helper (1.0 * x);

  # Returns distance of two points on Earth for the given latitude/longitude.
  # https://stackoverflow.com/questions/27928/calculate-distance-between-two-latitude-longitude-points-haversine-formula
  haversine = haversine' 6371000;
  haversine' =
    radius: lat1: lon1: lat2: lon2:
    let
      rad_lat = deg2rad ((1.0 * lat2) - (1.0 * lat1));
      rad_lon = deg2rad ((1.0 * lon2) - (1.0 * lon1));
      a =
        (sin (rad_lat / 2)) * (sin (rad_lat / 2))
        +
          (cos (deg2rad (1.0 * lat1)))
          * (cos (deg2rad (1.0 * lat2)))
          * (sin (rad_lon / 2))
          * (sin (rad_lon / 2));
      c = 2 * atan ((sqrt a) / (sqrt (1 - a)));
      result = radius * c;
    in
    if result < 0 then 0 else result;
}
