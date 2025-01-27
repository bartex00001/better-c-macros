/*
 * letter_swap letters =
 *   List.Map single_letter_swal letters
*/

##macro single_letter_swap {
    (a) => { b }
    (b) => { a }
    ($token:tt) => { $token }
}

##macro letter_swap {
    ($($tokens:tt)*) => {
        $(#single_letter_swap($tokens))*
    }
}

#letter_swap(a b c d 123 a a b b)
