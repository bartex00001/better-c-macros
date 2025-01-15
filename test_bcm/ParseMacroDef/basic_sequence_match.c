##macro sequence{
    ($($x:tt)*) => {
        $($x,)* 
    }
}