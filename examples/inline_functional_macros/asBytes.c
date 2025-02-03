##macro asBytes {
	($data:ident [ $inx:expr ]) => {
        ((uint8_t*)($data))[$inx]
    }
}

#asBytes(someData[5])
