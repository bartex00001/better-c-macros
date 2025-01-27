/* Compile this example with the following command:
bcmc -- gcc bitwise.c -o bitwise
*/

#include <stdio.h>
#include <stdbool.h>

/* Allowed operations are:
 * 
 * - Set chosen bit: `name[ index ] = value`
 * - Or-assign chosen bit to 1: `name[ index ] |= 1`
 * - And-assign chosen bit to 0: `name[ index ] &= 0`
 * - Get chosen bit: `name[ index ]`
 */
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
    ($var:ident [ $($inx:expr)* ]) => {
        ((($var) >> ($($inx)*)) & 1)
    }
}


int main(int argc, char **argv)
{
    int n = 0;

    printf("n = %d\n", n);
}
