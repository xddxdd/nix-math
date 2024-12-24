import json
import math
import numpy as np
import os
import subprocess

EPSILON = 1e-10;
SCRIPT_PATH = os.path.realpath(os.path.dirname(__file__))
FLAKE_PATH = os.path.realpath(os.path.join(SCRIPT_PATH, ".."))

def compare_absolute(epsilon: float):
    def fn(expected: float, actual: float) -> bool:
        return np.fabs(expected - actual) <= epsilon
    return fn

def compare_ratio(error: float, epsilon: float = EPSILON):
    def fn(expected: float, actual: float) -> bool:
        # Avoid division by zero
        if np.fabs(expected) < epsilon and np.fabs(actual) < epsilon:
            return True
        return np.fabs(actual / expected - 1) < error
    return fn

comparators = {
    "atan": compare_ratio(0.000001),
    "sin": compare_ratio(0.000001),
    "cos": compare_ratio(0.000001),
    "tan": compare_ratio(0.000001),
    "deg2rad": compare_ratio(0.000001),
    "exp_large": compare_ratio(0.000001),
    "exp_small": compare_ratio(0.000001),
    "log_large": compare_ratio(0.000001),
    "log_small": compare_ratio(0.000001),
    "log2": compare_ratio(0.000001),
    "log10": compare_ratio(0.000001),
    "powf_4.5": compare_ratio(0.000001),
    "powf_-2.5": compare_ratio(0.000001),
}

ground_truths = {
    "fabs": np.fabs,
    "div_3": lambda x: x // 3,
    "div_3_int": lambda x: x // 3,
    "div_4.5": lambda x: x // 4.5,
    "div_-2.5": lambda x: x // -2.5,
    "mod_3": lambda x: x % 3,
    "mod_3_int": lambda x: x % 3,
    "mod_4.5": lambda x: x % 4.5,
    "mod_-2.5": lambda x: x % -2.5,
    "pow_3": lambda x: np.power(x, 3),
    "pow_0": lambda x: np.power(x, 0),
    "factorial": lambda x: math.factorial(int(x)),
    "sin": np.sin,
    "cos": np.cos,
    "tan": np.tan,
    "atan": np.arctan,
    "int": int,
    "exp_large": np.exp,
    "exp_small": np.exp,
    "log_large": np.log,
    "log_small": np.log,
    "log2": np.log2,
    "log10": np.log10,
    "powf_4.5": lambda x: np.power(4.5, x),
    "powf_-2.5": lambda x: np.power(-2.5, x),
    "deg2rad": np.deg2rad,
    "sqrt": np.sqrt,
}

test_success = 0
test_fail = 0

for test_item in ground_truths.keys():
    try:
        test_results = json.loads(subprocess.check_output(["nix", "eval", "--raw", f"{FLAKE_PATH}#test.mathOutput.\"{test_item}\""]))
        comparator = comparators.get(test_item, compare_absolute(EPSILON))
        for input, output in test_results.items():
            expected = ground_truths[test_item](float(input))
            if comparator(expected, output):
                test_success += 1
            else:
                test_fail += 1
                print(f"FAIL: test {test_item} input {input} expected {expected} actual {output}")
    except subprocess.CalledProcessError as e:
        test_fail += 1
        print(f"FAIL: test {test_item} caused nix error")

print(f"{test_success}/{test_success+test_fail} tests succeeded.")
exit(1 if test_fail else 0)
