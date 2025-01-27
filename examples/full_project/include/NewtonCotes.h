#pragma once

#include <derive_debug.h>


typedef struct NCCoefficients* NCCoefficients;

impl_debug(NCCoefficients)


NCCoefficients ncc_new(int n);
void ncc_free(NCCoefficients);

double ncc_integral(const NCCoefficients ncc, double a, double b, double (*f)(double x));
