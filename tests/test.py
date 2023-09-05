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
    "atan": compare_ratio(0.01),
    "sin": compare_ratio(0.001),
    "cos": compare_ratio(0.001),
    "tan": compare_ratio(0.001),
    "deg2rad": compare_ratio(0.001),
}

ground_truths = {
    "fabs": np.fabs,
    "floor": np.floor,
    "floor_int": np.floor,
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
    "deg2rad": np.deg2rad,
    "sqrt": np.sqrt,
}

actual_results = json.loads(subprocess.check_output(["nix", "eval", "--raw", f"{FLAKE_PATH}#test.mathOutput"], stderr=subprocess.DEVNULL))

test_success = 0
test_fail = 0
for test_item, test_results in actual_results.items():
    comparator = comparators.get(test_item, compare_absolute(EPSILON))
    for input, output in test_results.items():
        expected = ground_truths[test_item](float(input))
        if comparator(expected, output):
            test_success += 1
        else:
            test_fail += 1
            print(f"FAIL: test {test_item} input {input} expected {expected} actual {output}")

print(f"{test_success}/{test_success+test_fail} tests succeeded.")
exit(1 if test_fail else 0)
