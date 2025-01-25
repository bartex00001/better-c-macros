##macro asBytes {
	($data:ident [ $inx:tt ])
		=> {((uint8_t*)($data))[$inx]}
}

unsigned* n;

#asBytes(n[2])
