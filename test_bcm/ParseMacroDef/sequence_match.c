##macro a1b2{
    ($id:ident = $($val:float)*) => 
    {
        let $id = $($val +)*;
    }

    ($($id2:char ^ )* $last:char) => 
    {
        char arr[] = { $($id2,)* $last, 'a' };
        // Ocaml cannot comprehend end of string character so just 'a' is used here...
    }
}
