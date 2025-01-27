/* Compile this file with the following command:
bcmc -- gcc factorial.c -o factorial
*/

#include <stdio.h>

#bcm_use factorial


int main()
{
    printf("Factorial of 5 is %d\n", #factorial(5));
}