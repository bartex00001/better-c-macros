##macro counter {
	() => {+0}
	(a $($rest:ident)*) =>  {+1 #counter($($rest)*) }
	(b $($rest:ident)*) =>  {-1 #counter($($rest)*) }
    /* Comments do no interfere! */
    () => { (#result(a /* Can be placed even
            here! */ b 1 "d")) }
}
