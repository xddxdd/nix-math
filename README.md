# nix-math

Experimental mathematical library in pure Nix, using no external library.

## Why?

1. Because I can.
2. Because I want to approximate the network latency between my servers using their latitudes/longitudes. No, I don't want to run `traceroute` between my servers every now and then.

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

- `abs [x]`, `fabs [x]`: Absolute value of `x`
- `arange [min] [max] [step]`: Create a list of numbers from `min` (inclusive) to `max` (exclusive), adding `step` each time.
- `arange2 [min] [max] [step]`: Same as `arange`, but includes `max` as well.
- `div [a] [b]`: Divide `a` by `b` with no remainder.
- `mod [a] [b]`: Modulos of dividing `a` by `b`.
- `pow [a] [b]`: Returns `a` to the power of `b`. **Only supports integer for `b`!**
- `factorial [x]`: Returns factorial of `x`. `x` is an integer, `x >= 0`.
- `sin [x], cos [x], tan [x]`: Trigonometric function. Takes radian as input.
- `atan [x]`: Arctangent function.
- `deg2rad [x]`: Degrees to radian.
- `sqrt [x]`: Square root of `x`. `x >= 0`.
- `haversine [lat1] [lon1] [lat2] [lon2]`: Returns distance of two points on Earth for the given latitude/longitude.

## Implementation Details

- `sin` function is implemented with its Taylor series: for `x >= 0`, `sin(x) = x - x^3/3! + x^5/5!`. Calculation is repeated until the next value in series is less than epsilon (`1e-10`).
- `cos` is `sin (pi/2 - x)`.
- `tan` is `sin x / cos x`.
  - For `sin`, `cos` and `tan`, result error is within 0.0001% as checked by unit test.
- `atan` is implemented with this estimation algorithm: <https://stackoverflow.com/a/42542593>. This is faster and more accurate than using `atan`'s Taylor series, because its Taylor series does not converge as fast as `sin`.
  - For `atan`, result error is within 0.0001%.
- `sqrt` is implemented with Newtonian method. Calculation is repeated until the next value is less than epsilon (`1e-10`).
  - For `sqrt`, result error is within `1e-10`.
- `haversine` is implemented based on <https://stackoverflow.com/a/27943>.

## Unit test

Unit test is defined in `tests/test.py`. It invokes `tests/test.nix` which tests the mathematical functions with a range of inputs, and compares the output to the same function from Numpy.

To run the unit test:

```bash
nix run .
```

## License

MIT.
