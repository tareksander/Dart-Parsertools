# lexer_builder

A lexer generator for dart.

## Features

- Match tokens using RegExp syntax.
- Rules dependent on lexer state.
- Generates lexer code automatically.

## Getting started

Include `lexer_builder` and `build_runner` as dev_dependencies and `lexer_builder_runtime` in your pubspec.yml.

## Usage

Annotate a class with `Lexer()` and methods in it with `Rule()` to define a lexer.
See [the example](example) for detailed instructions.


<!--
## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
-->
