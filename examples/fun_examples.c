#include <stdio.h>
#include <stdbool.h>

#bcm_use debug
#bcm_use "factorial.cmxs"

##macro bitwise {
	($var:ident [ $($inx:expr)* ] = $($val:expr)* ) => {
        $var = 
            ($var & ~(1 << ($($inx)*)))
            | ( ( (typeof($var))($($val)*) & 1 ) << ($($inx)*) )
    }
    ($var:ident [ $($inx:expr)* ] |= $($val:expr)* ) => {
        $var |= ( (typeof($var))($($val)*) & 1 ) << ($($inx)*)
    }
    ($var:ident [ $($inx:expr)* ] &= $($val:expr)* ) => {
        $var &= ( (typeof($var))($($val)*) & 1 ) << ($($inx)*)
    }
}


#derive(debug)
struct stuff {
    int a;
};


int main(int argc, char **argv)
{
    printf("some factorial: %d\n", #factorial(5));

    int n = 0;
    #bitwise(n[5] = true);
    #bitwise(n[1 + 1] |= argc && 1);

    printf("n = %d\n", n);

    stuff_debugPrint();
}
