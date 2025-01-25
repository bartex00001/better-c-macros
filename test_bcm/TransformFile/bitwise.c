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


#bitwise(n[5] = true);

#bitwise(n[1 + 1] |= a && b);

#bitwise(n[1 % ((b)) ] &= a || (b ^^ c));

