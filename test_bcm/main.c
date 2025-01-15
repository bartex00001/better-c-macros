#include <stdio.h>
#include <math.h>

#include <NewtonCotes.h>

#define L 2
#define R 30

int main()
{
    for(int i = L; i <= R; i++)
    {
        NCCoefficients ncc = ncc_new(i);

        const double cos_i = ncc_integral(ncc, -3, 4, cos);

        double divx(double x) { return 1. / x; }
        const double divx_i = ncc_integral(ncc, 1, 2, divx);

        double divx2_1(double x) { return 1. / (1. + x*x); }
        const double divx2_1_i = ncc_integral(ncc, -5, 5, divx2_1);

        printf(
            "n = %d\t|\t\t"
            "Q(cos, -3, 4) = %#.10lg \t\t"
            "Q(1/x, 1, 2) = %#.10lg \t\t"
            "Q(1/(1+x^2), -5, 5) = %#.10lg\n",
            i, cos_i, divx_i, divx2_1_i
        );

        ncc_free(ncc);
    }

    printf(
        "---------\n"
        "real\t|\t\t"
        "I(cos, -3, 4) = %#.10lg \t\t"
        "I(1/x, 1, 2) = %#.10lg \t\t"
        "I(1/(1+x^2), -5, 5) = %#.10lg\n",
        -0.6156824872480610292718,
         0.6931471805599453094172,
         2.7468015338900317217225
    );
}
