##macro counter {
	() => {+0}
	(a $($rest:ident)*) => { +1 #counter($($rest)*) }
	(b $($rest:ident)*) => { -1 #counter($($rest)*) }
}

#counter( a b a b )
