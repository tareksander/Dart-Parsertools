import 'package:lexer_builder_runtime/lexer_builder_runtime.dart';
import 'package:test/test.dart';

abstract class _StringLexer<T extends Token> extends LexerBase<T> {
  TokenResponse<T> word(String token, int line, int char, int index);

  TokenResponse<T> space(String token, int line, int char, int index);

  TokenResponse<T> quote(String token, int line, int char, int index);

  TokenResponse<T> wordQuoted(String token, int line, int char, int index);

  _StringLexer() : super(0) {
    rules = [
      [
        LexerRule(RegExp('"'), quote, null),
        LexerRule(RegExp('[^"]+'), wordQuoted, 1)
      ],
      [
        LexerRule(RegExp('[a-zA-Z0-9]+'), word, null),
        LexerRule(RegExp('\\s+'), space, null)
      ],
    ];
  }
}

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
}

@Lexer()
class StringLexer extends _StringLexer<StringLexerToken> {
  @override
  @Rule("[a-zA-Z0-9]+", 0)
  TokenResponse<StringLexerToken> word(
      String token, int line, int char, int index) {
    return TokenResponse.accept(StringLexerToken(token));
  }

  @override
  @Rule(r"\s+", 0)
  TokenResponse<StringLexerToken> space(
      String token, int line, int char, int index) {
    return TokenResponse.accept(null);
  }

  @override
  @Rule('"', 1)
  TokenResponse<StringLexerToken> quote(
      String token, int line, int char, int index) {
    if (state == 0) {
      state = 1;
    } else {
      state = 0;
    }
    return TokenResponse.accept(null);
  }

  @override
  @Rule('[^"]+', 1, state: 1)
  TokenResponse<StringLexerToken> wordQuoted(
      String token, int line, int char, int index) {
    return TokenResponse.accept(StringLexerToken(token));
  }
}

void main() {
  test("correct output", () {
    expect(StringLexer().tokenize('word "words in string literal" word2'), [
      StringLexerToken("word"),
      StringLexerToken("words in string literal"),
      StringLexerToken("word2")
    ]);
  });
}
