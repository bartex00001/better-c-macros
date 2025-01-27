/*
 * letter_swap = function
 * | a :: rest -> b :: letter_swap(rest)
 * | b :: rest -> a :: letter_swap(rest)
 * | [] -> []
*/

##macro letter_swap {
    (a $($letters:tt)*) => {
        b #letter_swap($($letters)*)
    }
    (b $($letters:tt)*) => {
        a #letter_swap($($letters)*)
    }
    ($token:tt $($letters:tt)*) => {
        $token #letter_swap($($letters)*)
    }
    () => {}
}

#letter_swap(a b c d 123 a a b b)
