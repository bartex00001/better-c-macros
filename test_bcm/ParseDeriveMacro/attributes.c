#derive(attr)
struct Art {
    #[]
    int n;

    #[string, str_len]
    char *str;

    #[len(n), display_name("ArrAy")]
    unsigned long long array[0];
};
