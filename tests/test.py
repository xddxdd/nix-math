import json
import math
from typing import Callable, Dict
import numpy as np
import os
import pytest
import subprocess

EPSILON = 1e-10
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


def get_nix_output(test_item: str) -> Dict[str, str]:
    return json.loads(
        subprocess.check_output(
            ["nix", "eval", "--raw", f'{FLAKE_PATH}#test.mathOutput."{test_item}"']
        )
    )


@pytest.mark.parametrize(
    "test_item,ground_truth,comparator",
    [
        ("atan", np.arctan, compare_ratio(0.000001)),
        ("cos", np.cos, compare_ratio(0.000001)),
        ("deg2rad", np.deg2rad, compare_ratio(0.000001)),
        ("div_-2.5", lambda x: x // -2.5, compare_absolute(EPSILON)),
        ("div_3_int", lambda x: x // 3, compare_absolute(EPSILON)),
        ("div_3", lambda x: x // 3, compare_absolute(EPSILON)),
        ("div_4.5", lambda x: x // 4.5, compare_absolute(EPSILON)),
        ("exp_large", np.exp, compare_ratio(0.000001)),
        ("exp_small", np.exp, compare_ratio(0.000001)),
        ("fabs", np.fabs, compare_absolute(EPSILON)),
        ("factorial", lambda x: math.factorial(int(x)), compare_absolute(EPSILON)),
        ("int", int, compare_absolute(EPSILON)),
        ("log_large", np.log, compare_ratio(0.000001)),
        ("log_small", np.log, compare_ratio(0.000001)),
        ("log10", np.log10, compare_ratio(0.000001)),
        ("log2", np.log2, compare_ratio(0.000001)),
        ("mod_-2.5", lambda x: x % -2.5, compare_absolute(EPSILON)),
        ("mod_3_int", lambda x: x % 3, compare_absolute(EPSILON)),
        ("mod_3", lambda x: x % 3, compare_absolute(EPSILON)),
        ("mod_4.5", lambda x: x % 4.5, compare_absolute(EPSILON)),
        ("pow_0", lambda x: np.power(x, 0), compare_absolute(EPSILON)),
        ("pow_3", lambda x: np.power(x, 3), compare_absolute(EPSILON)),
        ("pow_-2.5", lambda x: np.power(-2.5, x), compare_ratio(0.000001)),
        ("pow_4.5", lambda x: np.power(4.5, x), compare_ratio(0.000001)),
        ("sin", np.sin, compare_ratio(0.000001)),
        ("sqrt", np.sqrt, compare_absolute(EPSILON)),
        ("tan", np.tan, compare_ratio(0.000001)),
    ],
)
def test_runner(
    test_item: str,
    ground_truth: Callable[[float], float],
    comparator: Callable[[float, float], float],
):
    test_results = get_nix_output(test_item)
    has_failure = False
    for input, output in test_results.items():
        expected = ground_truth(float(input))
        if not comparator(expected, output):
            has_failure = True
            print(
                f"FAIL: test {test_item} input {input} expected {expected} actual {output}"
            )
    if has_failure:
        raise RuntimeError("Some items did not pass test")
