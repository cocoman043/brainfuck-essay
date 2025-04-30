#set page(columns: 2, footer: context [
  #set align(right)
  #set text(8pt)
  #counter(page).display(
    "1 of 1",
    both: true,
  )
])
#set par(justify: true, first-line-indent: 1em, spacing: 1.5em)

#place(
  top+center,
  scope: "parent",
  float: true,
  [
    #text(2em, weight: "bold", hyphenate: false)[A Comprehensive Essay on the Brainfuck Programming Langauge]\
    #text(fill: gray)[
    Campita, Renz Andrei O.\
    CD-1L\
    #datetime.today().display()
    ]
  ],
)



= Introduction
\

1. _What is the effect of old PLs to the one you have chosen to evaluate? Do you think the PL you have chosen has considerably improved the process of lexical analysis or has it preserved a lot of the characteristics defined by earlier PLs?_
\

#lorem(50)

#lorem(50)

#lorem(50)

#lorem(50)
#pagebreak()

= Lexical Analysis
\

#figure(

  image("./Wed Apr 30 05:07:07 PM PST 2025"),
  caption: [tsoding's Lexer implementation]
)\

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

3. _Syntax Analysis can be implemented with varying complexity. What are the impacts of this varying complexity in Syntax Analysis in the other phases of the compiler?_
\

#lorem(100)

4. _How about the usage/popularity of the compiler? Does the complexity of the compiler play a role in that?_
\

#lorem(100)

#lorem(100)


