# lexer_builder

A lexer generator for dart.


## Features

- Match tokens using RegExp syntax.
- Rules dependent on lexer state.
- Generates lexer code automatically.

## Caveats

- Generated lexers using regex are likely slower than handwritten ones.


## Getting started

Include `lexer_builder` and `build_runner` as dev_dependencies and `lexer_builder_runtime` in your pubspec.yml.

## Usage

Annotate a class with `Lexer()` and methods in it with `Rule()` to define a lexer.
See [the example](example) for detailed instructions.


## TODO

- Eventually generate custom code for the rules instead of using RegExp internally.
- Support async lexing with that by accurately measuring partly-matched subgroups, dispatching a rule if the next character doesn't make any match longer.



## Additional information

For more information about lexers in general, see the [flex](https://github.com/westes/flex) lexer generator and its [documentation](https://westes.github.io/flex/manual/).

