#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>


// Macro 'module' must be brought in scope before the module is used
#bcm_use debug


#derive(debug)
typedef struct Point {
    int x;
    int y;
} Point;

#derive(debug)
typedef struct TestPrinting {
    int a;
    float f;

    #[str]
    char* someStr;

    int* ptr;

    #[deref]
    int* derefMe; // if `derefMe` is `NULL` then it will be printed as `<null>`

    int arrLen;
    #[length(arrLen)]
    double* imArray; // This will be printed as an array of length `arrLen`

    #[hide]
    int imHidden;

    // Make sure thath `Point` implements `debug` trait as well
    // otherwise, the compiler will throw an error
    Point p;
} TestPrinting;


int main(int argc, char **argv)
{
    int n = 1234567890;

    TestPrinting tp = {
        .a = 5,
        .f = 3.14,
        .someStr = "Hello, World!",
        .ptr = &n,
        .derefMe = &n,
        .arrLen = 3,
        .imArray = (double[]){1.0, 2.0, 3.0},
        .imHidden = 42,
        .p = (Point){ .x = -123, .y = 123 }
    };

    TestPrinting_debugPrint(&tp);
}
