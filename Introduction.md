

# Better C Macros

---

## Spis Treści

+ *Zwykły* preprocesor w C – przypomnienie
+ Dlaczego to nie wystarcza?
	+ Cel projektu
+ Specyfikacja
+ *Inspiracje*

---

## Preprocesor C

- Kompilacja warunkowa
- Object-like macros
- Function-like macros
- Dyrektywa include
- Operacje na tekście
- Makra variadic?

--

#### Kompilacja Warunkowa

```txt
#if (e1)
	// -- kod kompilowany jeśli "e1" --
#elif (e2)
	// -- Kod jeśli nie "e1", ale "e2" --
#else
	// -- kod kompilowany jeśli nie "e1" i nie "e2 --
#endif
```

Gdzie wyrażenie może składać się tylko z liczb całkowitych oraz operatorów na nich.

--

```txt
#if LIBRARY_VERSION <= 10
  // Legacy code adaptation
#else
  // Normal version
#endif
```

```txt
#ifdef linux
  // Linux-specific code
#elif _WIN32
  // Windows-specific code
#endif
```

--

#### Object-Like

```txt
#define BUFF_LEN 128
#define VERSION_MAJOR 2
#define VERSION_MINOR 1

#ifndef MAGIC_CONSTANT
#define MAGIC_CONSTANT 951784242.1231
#endif

#define AUTHORS "Some people"
```

--

#### Function-Like

```txt
#define ABS(a) a < 0 ? -a : a
#define MAX(a, b) a > b ? a : b
#define SQR(x) x * x

#define ctg(x) 1 / tg(x)
```

+ Wszystkie te makra mogą działać niepoprawnie

--

#### Include

```C
#include <SomeLibrary.h>
// Tu 'wklejony' zostanie kod 'SomeLibrary.h'
```

Co jeśli wielokrotnie dołączony zostanie ten sam include??

```C
#include <SomeLibrary.h>
#include <SomeLibrary.h>
```

+ Prawdopodobnie błąd kompilacji przez wielokrotne definiowanie nazw/symboli
+ Dłuższy czas kompilacji – jest więcej doku do kompilacji

--

Skoro jest to po prostu wklejenie kodu...

```C
#define QUEUE_TYPE int
#include <UniversalQueue.h>
// Definiuje int_UniversalQueue
#undef QUEUE_TYPE

#define QUEUE_TYPE float
#include <UniversalQueue.h>
// Definiuje float_UniversalQueue
#undef QUEUE_TYPE
```

--

#### *Stringify*

```c
#define STR(x) #x

// Zamieni "wartość" na tekst: c-string
#define XSTR(x) STR(x)

#define PYTHON_VERSION_STRING \
	XSTR(PY_MAJOR_VERSION) "." XSTR(PY_MINOR_VERSION)
```

To jest [oficjalny sposób](https://gcc.gnu.org/onlinedocs/cpp/Stringizing.html)

--

#### Variadic

```c
#define eprintf(...) fprintf(stderr, __VA_ARGS__)

#define FUNCTION_CALL(Fun, ...) \
	registerCall(#Fun, Fun, #__VA_ARGS__, __VA_ARGS__)
```

Innych zastosowań niż wywoływanie funkcji variadic *jeszcze* nie widziałem...

---

## Dlaczego To Nie Wystarcza?

--

Wszystkie dyrektywy preprocesora sprowadzają się do *parametryzowanych* podmian tekstu.

Na podstawie parametrów nie można *podejmować decyzji*.

--

### Cel Projektu

Utworzenie systemu makr pozwalającego na **prawdziwe** generowanie kodu.

--

+ Makra Funkcyjne
	+ Deklaratywne
	+ Proceduralne
+ Makra *Derive*
+ Makra-atrybuty

--

Czyli co to tak naprawdę będzie?

> Makra operujące na Tokenach i AST,  
> a nie składni konkretnej.

---

## Specyfikacja

---

## Makra Funkcyjne

```C
#nazwa_makra(tokeny)
```

Tokeny wewnątrz makra mogą nie być wyrażeniami C.

Pozwoli to na tworzenie *nowej składni* poprzez makra dostępnej wewnątrz nawiasów.

--

### Wersja Deklaratywna

Definicja makra:

```txt
##macro nazwa {
	(dopasowanie do ciągu tokenów) => {ciąg tokenów};
	...
}
```

Dopuszczalne będzie rekurencyjne zamieszczanie makr jako wyniki dopasowania.

--

#### Dopasowanie

Może składać się z oddzielonych whitespace:

+ Konkretnych fragmentów
+ Nazwanych dopasowań: `$name:token_kind`
+ Wielokrotnych dopasowań: `$(...)*`

--

```txt
##macro choice {
	(a) => {"first option"};
	(b) => {"second option"};
}
```

```txt
printf(#choice(a));    // printf("first option");
printf(#choice(b));    // printf("second option");
```

--

```txt
##macro asBytes {
	($data:expr [ $inx:expr ])
		=> {((uint8_t*)($data))[$inx]}
}
```

```txt
#asBytes(someData[123]);

((uint8_t*)(someData))[123]
```

--

```txt
##macro counter {
	() => {+0};
	(a $(rest:ident)*) =>  {+1 #counter($rest) };
	(b $(rest:ident)*) =>  {-1 #counter($rest) };
}
```

```txt
#counter(a b a b)

+1 -1 +1 -1 +0
```

--

### Proceduralne

```ocaml
val nazwa : TokenStream -> ResultTokenStream
```

+ `TokenStream` – lista tokenów
+ `ResultTokenStream` – enum:
	- lista tokenów
	- Informacje o błędzie

--

#### Dlaczego nie C?

1. Pisanie transformacji list tokenów w C było by bardzo niewygodne
2. Wyraźny podział makra/właściwy program

--

```ocaml
let silnia = function
| [Lit(Int(n))] -> TokenList [Lit(Int(policz_silnie n))]
| _ -> SyntaxError ...
```

```txt
#silnia(5)

120
```

--

```ocaml
val token_stream_to_expr_ast : TokenStream -> ExprAst

val symbolic_derivative : TokenStream -> ResultTokenStream
```

```c
#symbolic_derivative( (3x * x + x) / sqrt(x), x )

(9x + 1) / (2 * sqrt(x))
```

--

```ocaml
val create_json : TokenStream -> ResultTokenStream
```

```text
#create_json({
	"magic_number": 42,
	"some_text": text%str,
	"some_flag": is_flag%bool
	
	"inner": other_json%json
})
```

--

#### Jeśli Będzie Czas...

Możliwość przyjmowania *środowiska* zawierającego typy dla zdefiniowanych operatorów.  
Pozwoliło by to na implementację makr w stylu:

```
#format("{x} + {y} = {x + y}")
```

> Dla C++ *możliwe* było by utworzenie takiego makra bez *środowisk*.

---

### Makra Derive

Pisane w OCaml

```ocaml
val nazwa : ObjectDefinition -> CAst
```

+ `ObjectDefinition` – opis struct
+ `CAst` – Abstrakcyjne drzewo syntaktyczne C

--

```C
#derive(debugPrint)
typedef struct {
	double x;
	double y;
} Vector2D;
```

```C
// w main...

Vector2D vec;
// ...
Vector2D_debugPrint(&vec);
// "{ x = ..., y = ... }"
```

--

```C
#defive(deepCopy)
typedef struct {
	char* someString;
	ComplexData* someData;
	// ...
} SmartPointer;

// ComplexData również musi 'implementować' deepCopy
```

```C
// w main...

SmartPointer newInstace =
	SmartPointer_deepCopy(&otherOne);
```

---

### Makra Atrybuty

```txt
#[nazwa_atrybutu(tokeny), ...]
// Obiekt do którego doczepiony jest atrybut
```

Atrybuty będą możliwe do odczytania w:

- Makrach Derive przy każdym elemencie
- Środowisku typów –  jeśli będzie czas

--

```txt
#[debugPrint()]
typedef struct {
	int normal;

	#[debugPrint_skip]
	char* secretText;

	#[debugPrint_binary]
	void* someData;

	#[debugPrint_as(int)]
	void* otherData;
} SomeStruct;
```

---

## Inspiracje

--

### Rust

Porządne makra *wbudowane w język*\*.

+ [Debug trait](https://doc.rust-lang.org/std/fmt/trait.Debug.html)
+ [Clap – command line argument parser](https://docs.rs/clap/latest/clap/)
+ [Serde JSON – serialization/deserialization for JSON](https://docs.rs/serde_json/latest/serde_json/)
+ [Rocket – web framework](https://rocket.rs/guide/v0.5/requests/#dynamic-paths)

--

### [blackhole89/macros](https://github.com/blackhole89/macros)

*Podobny* projekt, ale...

+ Implementuje jedynie makra deklaratywne
+ Dziwne decyzje projektowe
+ Brak kompatybilności z *zewnętrznym* kodem c
+ Brak typów tokenów przy pattern matching (????)
+ Mutowalny, globalny stan (????????)

--

## Pytania?

+ [github: bartex00001/better-c-macros](https://github.com/bartex00001/better-c-macros)

