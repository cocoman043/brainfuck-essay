#import "@preview/diagraph:0.3.3"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#let code_snippet(code, caption) = figure(
  [#code],
  caption: [#caption],
  kind: "code",
  supplement: [Code Snippet]
)

#show link: set text(fill: blue)
#show link: underline

// #show raw.where(block: true): box.with(
//   stroke: 1pt,
//   width: 100%,
//   inset: 1em,
//   radius: 2pt
// )
//
// #show raw.where(block: true): it => { set par(justify: false); grid(
//   columns: (100%, 100%),
//   column-gutter: -100%,
//   block(width: 100%, inset: 1em, for i, line in it.text.split("\n") {
//     box(width: 0pt, align(right, str(i + 1) + h(2em)))
//     hide(line)
//     linebreak()
//   }),
//   block(radius: 1em, fill: luma(246), width: 100%, inset: 1em, it),
// )}

#set page(columns: 2, footer: context [
  #set align(right)
  #set text(8pt)
  #counter(page).display(
    "1 of 1",
    both: true,
  )
])
#set par(justify: true, first-line-indent: 1em, spacing: 1.5em)
#set heading(numbering: "1.")

#place(
  top+center,
  scope: "parent",
  float: true,
  [
    #text(2em, weight: "bold", hyphenate: false)[A Comprehensive Essay on tsoding's JIT Compiler for Brainf*ck]\
    #text(fill: gray)[
    Campita, Renz Andrei O.\
    CD-1L\
    #datetime.today().display()
    ]
  ],
)



= Introduction
\

#link("https://youtu.be/mbFY3Rwv7XMhtt")[
#image("thumbnail.jpg")
]
#link("https://youtu.be/mbFY3Rwv7XM")[I made JIT Compiler for Brainf*ck lol] (Tsoding Daily, 2024)

1. _What is the effect of old PLs to the one you have chosen to evaluate? Do you think the PL you have chosen has considerably improved the process of lexical analysis or has it preserved a lot of the characteristics defined by earlier PLs?_
\

Brainf*ck was invented by Urban Müller as an attempt to make language that would require the smallest compiler. It was inspired by Wouter van Oortmerssen's esoteric langauge in 1993 -- FALSE (named after the author's favorite truth value).

The FALSE programming language had features such as: literals, a stack, arithmetic, comparison, lambda and flow control, identifiers, I/O, and comments. This is an extremely simple language that had a *1024-byte compiler*. In comparison, Brainf*ck was even simpler only having a pointer, an array of 30,000 memory cells, and 8 operations. Müller was able to write a compiler for this language using only *240 bytes*.

Brainf*ck is one of the most popular esoteric programming languages both due to its name and features. With its goal to be a language that would require an extremely small compiler, it has been a staple language to use for recreational programming.

This paper will analyze one of these imlementations: Alexey Kutepov#footnote[https://github.com/rexim]'s (aka. tsoding) Brainf*ck JIT Compiler#footnote[https://github.com/tsoding/bfjit]. This implementation has been chosen because it also has an accompanying YouTube video#footnote[https://youtu.be/mbFY3Rwv7XM], a recording of the livestream when tsoding created the compiler from scratch. This shows the whole process of creating the compiler, and all of the decisions tsoding made.

To have a general grasp of the language, here is how to display "Hello World!" in Brainf*ck:

#code_snippet(
```
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
```,
  "Hello World! in Brainf*ck"
)


#pagebreak()

= Lexical Analysis
\

#code_snippet(
 [#codly()
```c
typedef struct {
  Nob_String_View content;
  size_t pos;
} Lexer;


bool is_bf_cmd(char ch) 
{
  const char *cmds = "+-<>,.[]";
  return strchr(cmds, ch) != NULL;
}

char lexer_next(Lexer *l)
{
  while (l->pos < l->content.count && !is_bf_cmd(l->conent.data[1->pos])
  {
    l->pos += 1;
  }
  if (l->pos >= l->content.count) return 0;
  return l->content.data[l->pos++];
}
```]
  ,
  "tsoding's Lexer implementation"
)


In tsoding's implementation of the Brainf*ck JIT compiler, the lexer is extremely minimal. Its main purpose is only to clean the scoure code by removing all invalid characters.

#figure(
  table(
    columns: (auto,1fr),
    inset: 10pt,
    align: horizon,
    table.header(
      [Character],[Operation],
    ),
    [+],[Increment Data],
    [-],[Decrement Data],
    [>],[Move Pointer Right],
    [<],[Move Pointer Left],
    [.],[Output Data],
    [,],[Input Data],
    [\[],[Jump Forward],
    [\]],[Jump Backward],
  ),
  caption: [All valid characters in Brainf*ck]
)

_Comments_

Since there is a fixed set of valid characters, it is trivial to implement comments. All other chracters are treated as comments and are removed by the lexer. In tsoding's implementation, all comments cannot include any of the valid 

_Tokens_

Since in Brainf*ck, each of the operations are represented by a single character, tokenization is not needed. The lexer will just give the parser the cleaned up source code.

_In the life span of Lexical Analyzers, we have mentioned that some of its functions and features are already merged in other software besides lexical analyzers themselves. What characteristics of the lexical analyzer makes it easy to merge it with these other software? and do you think it would be possible to do it with other phases of the compiler?_

"functions and features already merged in other software -> text editors; linters"

It is easy to merge with other software since the grammar of the language is already defined and the underlying semantics of the language is not yet processed at this stage, making implementation of these features lightweight enough for supporting software such as text editors or linters to execute said features in real time.

_Do you think it would be possible to do it with other phases of the compiler?_

It could be possible to also do it with other phases of the compiler. An example of this is Language Server Protocol (LSP) servers that the most popular text editors or IDEs use. Well implemented LSPs can give programmers warnings about unused variables, bounds checking, type mismatches, etc.

For the later phases of the compiler, these are harder to implement but some do. Just in time (JIT) compilers are examples of these other software that merges compilation steps into its own process. JITs generate intermediate representation before it generates machine code.

#pagebreak()

= Syntax Analysis
\

tsoding's implementation of the Brainf*ck JIT compiler does not produce a parse tree. Since Brainf*ck source code basically processes each character as its own "expression" -- as what other programming languages may treat them, the compiler does not need to generate a parse tree for each expression.

For example, here is a comparison between C and Brainf*ck.

C:
#code_snippet(
```c
int main() {
  int x = 0;
  while (x < 5) {
    x++;
  }

  print("%s", x);

  return 0;
}
```,
  "Printing \"5\" in C"
)

Parse tree for the statement `x = x - y`:


#diagraph.raw-render(```
  digraph G {
  node[shape=circle]
  e -> x0
  e -> m
  m -> x1
  m -> y
  }
  ```,
  labels: (
  "e": "=",
  "m": "-",
  "x0": "x",
  "x1": "x",
  "y": "y"
)
)

Brainf*ck:
#code_snippet(
```
+
+
+
+
+
.
```,
  "Printing \"5\" in Brainf*ck"

)

Since Brainf*ck does not require a parse tree, tsoding's implementation of the parser only has these functions:

- Transform the source code into Intermediate Representation
- Check for unbalanced brackets

#code_snippet(
  text(size: 8pt,
    ```c
case '[': {
  size_t addr = ops->count;
  Op op = {
      .kind = c,
      .operand = 0,
  };
  nob_da_append(ops, op);
  nob_da_append(&stack, addr);

  c = lexer_next(&l);
} break;

case ']': {
  if (stack.count == 0) {
      // TODO: reports rows and columns
      printf("%s [%zu]: ERROR: Unbalanced loop\n", file_path, l.pos);
      nob_return_defer(false);
  }

  size_t addr = stack.items[--stack.count];
  Op op = {
      .kind = c,
      .operand = addr + 1,
  };
  nob_da_append(ops, op);
  ops->items[addr].operand = ops->count;

  c = lexer_next(&l);
} break;
  ```
  ),
  "Unbalanced brackets checking"
)\

The transformation of source code into intermediate representation will be discussed further in the paper. See #ref(<ir-heading>).

To check for unbalanced brackets, a stack of brackets is used.


3. _Syntax Analysis can be implemented with varying complexity. What are the impacts of this varying complexity in Syntax Analysis in the other phases of the compiler?_
\

// TODO: FIX THIS SHIT
The work that the syntax analyzer or the parser does with the tokens --or in Brainf*ck's case, the source code tself-- can greately affect the proceeding steps in compilation. In general, the more processing the parser does: syntax errors, intermediate code generation, parenthesis balancing, etc., the less the following steps has to take care of.

4. _How about the usage/popularity of the compiler? Does the complexity of the compiler play a role in that?_
\

The complexity of the compiler also affects its popularity. Giving a simple interface that programmers can interact with, with good documentation will also increase the communication between programmers using the same language.

#pagebreak()

= Semantic Analysis
\

tsoding's implementation does not have semantic analysis. This is not required as there are no semantics that has to be analyzed. If anything, maybe this step can optimize commonly used patterns in Brainf*ck such as the `[-]` pattern, which sets the current memory cell to zero. So if a certain sequence of operations can be seen in the array of operations, maybe it can be represented with another intermediate representation or operation eg.:

`
OP_JUMP_IF_ZERO
OP_DECREMENT
OP_JUMP_IF_NONZERO`

can be optimized to

`
OP_SET_ZERO
`

which would be translated into its own machine code equivalent. There are a lot of these common patterns/algorithms in Brainf*ck that could be possibly be optimized this way too.#footnote[https://esolangs.org/wiki/Brainfuck_algorithms]

_1. Many of the programming languages that have been created over the years have improved and made steps to automate some parts of the compilation process to both improve performance and lessen errors in the side of the programmers. These are easily implementable in some of the phases of the compiler. How about in Semantic Analysis? is this also the case? Is it different?_


// Languages improve
//
// eg. type inference
//
// Automate parts of compilation
//
// eg. sentax and semantic error in IDEs
// eg. vairbale not declared
// eg. type mismatches
//
// Improve performance and lessen errors

Improvements in the Semantic Analysis step of compilation are also being made constantly. An example of this are Language Server Protocol Servers that text editors such as Visual Studio Code or Vim uses to detect and suggest fixes for syntactic or semantic errors.

#figure(
  image("./rust_analyzer"),
  caption: "rustanalyzer (Rust LSP) showing semantic error"
)\

There's also been improvements with implicit types, where languages with static typing can have variables that does not have their type declared but is implied by the language itself given the value it was assigned. Some LSPs also help with this feature by showing the type implied by the language.

#figure(
  image("./Mon May  5 10:40:36 AM PST 2025"),
  caption: "rustanalyzer showing the implied type of x with ghost/virtual text"
)\

_2. Type Checking has been around for quite some time. Looking at older PLs, type checking has been considered to be less of a priority compared to other parts of the compiler. Discuss how this increase in importance in type checking came about._

// Discuss security, mention C's lack of strong types, and how this was used in creating tsoding's JIT Compiler.

Type checking has been important since the early programming languages.


#pagebreak()

= Intermediate Representation <ir-heading>
\

#code_snippet(
  ```c
typedef enum {
    OP_INC             = '+',
    OP_DEC             = '-',
    OP_LEFT            = '<',
    OP_RIGHT           = '>',
    OP_OUTPUT          = '.',
    OP_INPUT           = ',',
    OP_JUMP_IF_ZERO    = '[',
    OP_JUMP_IF_NONZERO = ']',
} Op_Kind;

typedef struct {
    Op_Kind kind;
    size_t operand;
} Op;
```,
  "tsoding's Operation structure"

)


_3. Intermediate Representation that we have discussed include DAGs and Three-Address Code Representations. Are these the only representations that exist in PLs or are there others? If there are, what advantages do these other approaches bring to the table? If there are non, why do you think PLs have stuck with this approach?_

#text(fill:gray)[#lorem(200)]

#pagebreak()

= Code Generation
\

_1. The determination of Basic Blocks and Creation of Flow Graphs is one prominent example of an algorithm for code generation. Are there different approaches done in other PLs? IF so, give an example._

#text(fill:gray)[#lorem(200)]


#text(fill:gray)[#lorem(200)]

#pagebreak()

= Code Optimization
\

tsoding plainly translates all of the intermediate representation into machine code with a simple mapping ie. if an operation is `x`, then the machine code is `y`. Generating the machine code for the current operation does not depend on what previous operations have already been made and this is a point that can be optimized in the compiler.

_2. Code Optimization is a very broad topic but we only focus on code-improving transformations that are machine-independent. Besides proper memory management, what other code optimization techniques are existing? Use your chosen PL to discuss these techniques_

#text(fill:gray)[#lorem(200)]

_3. We talk generally about the necessity of each of the phases of the compiler. Nowadays, with the improvemnt of hardware, what would be the effect of taking off or skipping this phase of the compiler? Would it be beneficial or not?_

The essence of a compiler is to translate source code into machine code that a particular hardware can execute. This Brainf*ck JIT compiler shows that not all phases of the compiler is strictly necessary. Due to the simplicity of the language itself, it is almost a trivial step to translate it to machine code.

Considering constant improvements in hardware with newer processors and optimizations in processors such us out of order execution, it is difficult to tell the effect of removing steps in a compilation process. It is possible that the CPU itself would recognize hotspots in the program it is executing and optimize it on the fly, or even do optimizations that the programmer or the compiler would catch. The only real and reliable way to know the effects of modifying the compiler is to empirically test and measure performance in specific hardware configurations. 

// [CITE CASEY MURATORI HERE]

#pagebreak()
