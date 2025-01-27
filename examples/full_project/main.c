#include <stdio.h>
#include <math.h>

#include <NewtonCotes.h>

#define L 2
#define R 4


int main()
{
    for(int i = L; i <= R; i++)
    {
        NCCoefficients ncc = ncc_new(i);
        const double cos_i = ncc_integral(ncc, -3, 4, cos);

        printf(
            "n = %d\t -> "
            "Q(cos, -3, 4) = %#.10lg\n",
            i, cos_i
        );

        NCCoefficients_debugPrint(ncc);

        ncc_free(ncc);
    }

    printf(
        "---------\n"
        "real\t-> "
        "I(cos, -3, 4) = %#.10lg\n",
        -0.6156824872480610292718
    );
}


































// #bcm_use parseArgs

// #derive(parseArgs)
// typedef struct Args {
//     #[short('l'), desc("Left bound")]
//     int l;
//     #[short('r'), desc("Right bound")]
//     int r;

//     #[short('v'), desc("Print verbose output")]
//     bool verbose;
// } Args;
