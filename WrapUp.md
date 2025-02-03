# Better C Macros

Podsumowanie

---

## Co To Właściwie Miało Być?

+ Preprocesor makr dla języka c
	+ Makra funkcyjne na tokenach
	+ Makra derive dla `struct`
	+ ~~compile-time type-checking~~
+ Narzędzia pozwalające używać tych makr

--

### No To Patrzymy Co Wyszło

[Better C Macros](https://github.com/bartex00001/better-c-macros)

---

### Ewaluacja Makr Inline

...czyli regex ze środowiskiem


No a skoro regex, to...

--

##### Automat Mealy'ego

$$\small\mathcal{M} = \langle{Q, \sum, \Omega, \delta, \chi, q_{0}}\rangle$$

--

$Q$  – zbiór stanów

```ocaml
type sm_state =
  { position: int
  ; env: env
  ; buffer: (macro_token * ident option) list }
```

--

$\sum$ – alfabet *wejściowy*

```ocaml
type macro_token =
  | Direct of string
  | Ident of ident
  | Int of int
  | Float of float
  | String of string
  | Char of char
  | EndToken
```

--

$\Omega$ – alfabet *wyjściowy*

```ocaml
type macro_use = ident * macro_token_results
and macro_token_result =
  | Tok of macro_token
  | Use of macro_use
```

--

$\delta : Q\times\sum \rightarrow Q$ – funkcje przejścia

```ocaml
type sm_action =
  | SMGoto of sm_state * macro_tokens
  | SMFinish of sm_state
  | SMFail

type state_transition =
  sm_state * macro_token * macro_tokens -> sm_action
```

--

$\chi : Q \times\sum \rightarrow \Omega$ – funkcja wyjścia

```ocaml
val print_result_tokens :
  env -> macro_result list -> macro_token_results
```

```ocaml
match result with
| Some (sm_state, token_result) ->
  print_result_tokens sm_state.env token_result
```

Stan końcowy jest implicit, stąd brak go w typie.

--

$q_0$ – stan początkowy

```ocaml
{ position = 0
; env = StrMap.empty
; buffer = []}
```
