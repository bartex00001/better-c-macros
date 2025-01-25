##macro asBytes {
	($data:ident [ $($inx:expr)* ])	=> {
        ((uint8_t*)($data))[ $($inx)* ]
    }
}

unsigned* n;

#asBytes(n[1+(2*/*commet*/x)])
