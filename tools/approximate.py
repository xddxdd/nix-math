#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.numpy
import json
from typing import Callable, Iterable, List, Optional, Tuple
import numpy as np
from numpy.polynomial.polynomial import Polynomial

EPSILON = 1e-10

class Approximate:
    def __init__(self, fn: Callable[[Iterable[float]], Iterable[float]], linspace: Tuple[float, float, float], max_poly_degrees: Optional[int] = None, target_error_percent: Optional[float]=None):
        self.fn = fn
        self.linspace = linspace
        self.input = np.linspace(*linspace)
        self.expected = fn(self.input)

        if not max_poly_degrees and not target_error_percent:
            raise ValueError("Either max_poly_degrees or target_error_percent must be set to specify search range")
        self.max_poly_degrees = max_poly_degrees
        self.target_error_percent = target_error_percent

    def _fit(self, deg: int) -> Tuple[float, Polynomial]:
        fit: Polynomial = Polynomial.fit(self.input, self.expected, deg, domain=(self.linspace[0], self.linspace[1]), window=(self.linspace[0], self.linspace[1]))
        result = fit(self.input)
        error_percent = np.fabs((result - self.expected) / self.expected)
        max_error_percent = np.max(error_percent[error_percent < 1e308] * 100)
        return max_error_percent, fit

    def _run_max_poly_degrees(self) -> Tuple[float, Polynomial]:
        error, poly = self._fit(1)
        for deg in range(2, self.max_poly_degrees+1):
            _error, _poly = self._fit(deg)
            if _error < error:
                error = _error
                poly = _poly
        return error, poly

    def _run_target_error_percent(self) -> Tuple[float, Polynomial]:
        deg = 0
        while True:
            deg += 1
            error, poly = self._fit(deg)
            if error <= self.target_error_percent:
                return error, poly

    def run(self) -> Tuple[float, Polynomial]:
        if self.max_poly_degrees:
            return self._run_max_poly_degrees()
        elif self.target_error_percent:
            return self._run_target_error_percent()
        else:
            raise NotImplementedError()

    def explain(self) -> Polynomial:
        error, poly = self.run()
        print(f"Degree: {poly.degree()}")
        print(f"Error %: {error}")
        print(f"Coefficients: {json.dumps(json.dumps(list(poly.coef)))}")
        return poly

Approximate(np.exp, (0, 1, 10000), max_poly_degrees=100).explain()
# Approximate(np.exp, (0, 1, 10000), target_error_percent=1e-4).explain()
Approximate(np.arctan, (0, 1, 10000), max_poly_degrees=100).explain()
