// See also the example for lexer_builder

import 'package:lexer_builder_runtime/lexer_builder_runtime.dart';

class StringLexerToken extends Token {
  String value;

  StringLexerToken(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringLexerToken &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "'$value'";
  }
}

// Extend the base lexer class and pass in your token type.
class StringLexer extends LexerBase<StringLexerToken> {
  // Call the super constructor with the starting state, and initialize the lexer rules.
  StringLexer() : super(0) {
    // The rules are lists ordered by descending priority.
    rules = [
      [
        // Each rule contains the matching RegExp, the action method and the state it can be used in.
        LexerRule(RegExp('"'), quote, null),
        LexerRule(RegExp('[^"]+'), wordQuoted, 1)
      ],
      [
        LexerRule(RegExp('[a-zA-Z0-9]+'), word, null),
        LexerRule(RegExp('\\s+'), space, null)
      ],
    ];
  }

  TokenResponse<StringLexerToken> word(
      String token, int line, int char, int index) {
    return TokenResponse.accept(StringLexerToken(token));
  }

  TokenResponse<StringLexerToken> space(
      String token, int line, int char, int index) {
    return TokenResponse.accept(null);
  }

  TokenResponse<StringLexerToken> quote(
      String token, int line, int char, int index) {
    if (state == 0) {
      state = 1;
    } else {
      state = 0;
    }
    return TokenResponse.accept(null);
  }

  TokenResponse<StringLexerToken> wordQuoted(
      String token, int line, int char, int index) {
    return TokenResponse.accept(StringLexerToken(token));
  }
}

void main() {
  print(StringLexer().tokenize('word "words in string literal" word2'));
}
