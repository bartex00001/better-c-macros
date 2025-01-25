##macro mySwap{
    (a) => {b}
    (b) => {a}
}

// Expect this to be replaced with b
#mySwap(a)
