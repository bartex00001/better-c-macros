#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include <math.h>

#include <NewtonCotes.h>


#bcm_use parseArgs

#derive(parseArgs)
typedef struct Args {
    #[short('l'), desc("Left bound")]
    int l;
    #[short('r'), desc("Right bound")]
    int r;

    #[short('v'), desc("Print verbose output")]
    bool verbose;
} Args;


int main(int argc, char* argv[])
{
    Args args = Args_parseArgs(argc, argv);

    for(int i = args.l; i <= args.r; i++)
    {
        NCCoefficients ncc = ncc_new(i);
        const double cos_i = ncc_integral(ncc, -3, 4, cos);

        printf(
            "n = %d\t -> "
            "Q(cos, -3, 4) = %#.10lg\n",
            i, cos_i
        );

        if(args.verbose)
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
