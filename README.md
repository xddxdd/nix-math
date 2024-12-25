# nix-math

Experimental mathematical library in pure Nix, using no external library.

## Why?

1. Because I can.
2. Because I want to approximate the network latency between my servers using their latitudes/longitudes. No, I don't want to run `traceroute` between my servers every now and then.

## Limitations

- Nix does not provide some lower level operations, such as bit operation on floating point numbers. This leads to computation inaccuracies, and it's impossible to get the exact same result as GLibC or `numpy`, even if I have their code as reference. For functions where getting exact same results are impossible, I target for error within 0.0001%.

- This library does not support these features. ALthough I added exceptions for some situations, this is by no means comprehensive. Please consider these as undefined behaviors, and submit an issue when you encounter one.
  - Floating point infinity (+inf, -inf)
  - NaN
  - Floating power overflow and underflow
  - Operations where the value is extremely small (around `1e-38`) or extremely large (around `1e38`)
  - Imaginary numbers

## Usage

```nix
{
  inputs = {
    nix-math.url = "github:xddxdd/nix-math";
  };

  outputs = inputs: let
    math = inputs.nix-math.lib.math;
  in{
    value = math.sin (math.deg2rad 45);
  };
}
```

## Provided functions

- `abs [x]`: Absolute value of `x`
- `arange [min] [max] [step]`: Create a list of numbers from `min` (inclusive) to `max` (exclusive), adding `step` each time.
- `arange2 [min] [max] [step]`: Same as `arange`, but includes `max` as well.
- `atan [x]`: Arctangent function. Returns radian.
- `cos [x]`: Trigonometric function. Takes radian as input.
- `deg2rad [x]`: Degrees to radian.
- `div [a] [b]`: Divide `a` by `b` with no remainder.
- `exp [x]`: Exponential function. Returns `e^x`.
- `fabs [x]`: Absolute value of `x`
- `factorial [x]`: Returns factorial of `x`. `x` is an integer, `x >= 0`.
- `haversine [lat1] [lon1] [lat2] [lon2]`: Returns distance of two points on Earth for the given latitude/longitude.
- `int [x]`: Integer part of `x`.
- `ln [a] [b]`: Logarithmetic function. Returns `ln_a b`.
- `log [x]`: Logarithmetic function. Returns `log_e x`.
- `log10 [x]`: Logarithmetic function. Returns `log_10 x`.
- `log2 [x]`: Logarithmetic function. Returns `log_2 x`.
- `mod [a] [b]`: Modulos of dividing `a` by `b`.
- `pow [a] [b]`: Returns `a` to the power of `b`. Now supports floating point `b`.
- `sin [x]`: Trigonometric function. Takes radian as input.
- `sqrt [x]`: Square root of `x`. `x >= 0`.
- `tan [x]`: Trigonometric function. Takes radian as input.

## Implementation Details

- `sin` function is implemented with its Taylor series: for `x >= 0`, `sin(x) = x - x^3/3! + x^5/5!`. Calculation is repeated until the next value in series is less than epsilon (`1e-10`).
- `cos` is `cos(x) = sin (pi/2 - x)`.
- `tan` is `tan(x) = sin x / cos x`.
  - For `sin`, `cos` and `tan`, result error is within 0.0001% as checked by unit test.
- `atan` is implemented by approximating to polynomial function. This is faster and more accurate than using its Taylor series, because its Taylor series does not converge fast enough, and may cause "max-call-depth exceeded" error.
  - For `atan`, result error is within 0.0001%.
- `sqrt` is implemented with Newtonian method. Calculation is repeated until the next value is less than epsilon (`1e-10`).
  - For `sqrt`, result error is within `1e-10`.
- `exp` is implemented by approximating to polynomial function. This is faster and more accurate than using its Taylor series, because its Taylor series does not converge fast enough, and may cause "max-call-depth exceeded" error.
  - For `exp`, result error is within 0.0001%.
- `log` is implemented with its Taylor series:
  - For `1 <= x <= 1.9`, `log(x) = (x-1)/1 - (x-1)^2/2 + (x-1)^3/3`. Calculation is repeated until the next value in series is less than epsilon (`1e-10`).
  - For `x >= 1.9`, `log(x) = 2 * log(sqrt(x))`
  - For `0 < x < 1`, `log(x) = -log(1/x)`
  - Although the Taylor series applies to `0 <= x <= 2`, calculation outside `1 <= x <= 1.9` is very slow and may cause max-call-depth exceeded error.
  - For `log`, result error is within 0.0001%.
- `pow` is `pow(x, y) = exp(y * log(x))`.
- `ln` is `ln(x, y) = log(y) / log(x)`.
- `log2` is `log2(x) = log(x) / log(2)`.
- `log10` is `log10(x) = log(x) / log(10)`.
  - For `pow`, `ln`, `log2`, `log10`, result error is within 0.0001%.
- `haversine` is implemented based on <https://stackoverflow.com/a/27943>.

## Unit test

Unit test is defined in `tests/test.py`. It invokes `tests/test.nix` which tests the mathematical functions with a range of inputs, and compares the output to the same function from Numpy.

To run the unit test:

```bash
nix run .
```

## License

MIT.
