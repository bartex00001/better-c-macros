#include <NewtonCotes.h>

#include <stdlib.h>


struct NCCoefficients {
    int n;
    double coeff[0];
};


// res = nat / (x - x0)
static void horner_divide(int n, const double* nat, double* res, double x0)
{
    res[n] = nat[n+1];
    for(int i = n-1; i >= 0; i--)
        res[i] = res[i+1] * x0 + nat[i+1];
}

static double horner_evaluate(int n, const double* nat, double x0)
{
    double res = 0;
    for(int i = n; i >= 0; i--)
        res = res * x0 + nat[i];
    return res;
}


NCCoefficients ncc_new(int n)
{
    int N = (n+1) / 2;
    NCCoefficients ncc = malloc(sizeof(struct NCCoefficients) + (N+1) * sizeof(double));
    ncc->n = n;

    double* nat = malloc((n+2) * sizeof(double));
    nat[0] = 0;

    // Determine coefficients of the polynomial x(x - 1)...(x-n)
    for(int i = 0; i <= n; i++) {
        nat[i+1] = 1;
        for(int j = i; j > 0; j--)
            nat[j] = nat[j-1] - nat[j] * i;
    }

    double* factorial = malloc((n+2) * sizeof(double));
    factorial[0] = 1;
    for(int i = 1; i <= n; i++)
        factorial[i] = (double)i * factorial[i-1];

    double* div = malloc((n+2) * sizeof(double));
    for(int i = 0; i <= N; i++)
    {
        horner_divide(n, nat, div, i);

        // Take the integral of div
        for(int i = n+1; i > 0; i--)
            div[i] = div[i-1] / i;
        div[0] = 0;

        const double valA = horner_evaluate(n+1, div, 0);
        const double valB = horner_evaluate(n+1, div, n);

        ncc->coeff[i] = (valB - valA)
                        /  (factorial[i] * factorial[n-i]);
    }

    free(div);
    free(nat);
    return ncc;
}

void ncc_free(NCCoefficients ncc)
{
    free(ncc);
}


double ncc_integral(const NCCoefficients ncc, double a, double b, double (*f)(double x))
{
    double res = 0;
    const double h = (b - a) / (double)ncc->n;

    int i = 0;
    for(; i <= ncc->n / 2; i++)
        res += h * ncc->coeff[i] * ((ncc->n-i) & 1 ? -1 : 1)
            * f(a + i * h);

    for(; i <= ncc->n; i++)
        res += h * ncc->coeff[ncc->n - i] * ((i) & 1 ? -1 : 1)
            * f(a + i * h);

    return res;
}
