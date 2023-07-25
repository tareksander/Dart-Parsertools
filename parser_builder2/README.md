<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# parser_builder2

Generates context-free language parsers in Dart.

## Features


### Done

- LALR(1) generator and parser



### Todo

- define associativity
- resolve conflicts with priority
- canonical LR(1) generator
- minimal LR(1) generator using IELR(1)
- GLR parser with minimal LR(1) or canonical LR(1) generator

## Getting started

Include `parser_builder2` and `build_runner` as dev_dependencies and `parser_builder2_runtime` in your pubspec.yml.

## Usage

Annotate a class with `Parser()` and methods in it with `ParserRule()` to define a parser.
See [the example](example) for detailed instructions.

## Additional information

For more information about grammars and the terms, see the manual for the GNU Bison parser generator.