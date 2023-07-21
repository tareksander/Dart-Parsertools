// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// LexerGenerator
// **************************************************************************

abstract class _StringLexer<T extends Token> extends LexerBase<T> {
  TokenResponse<T> word(String token, int line, int char, int index);
  TokenResponse<T> space(String token, int line, int char, int index);
  TokenResponse<T> quote(String token, int line, int char, int index);
  TokenResponse<T> wordQuoted(String token, int line, int char, int index);
  _StringLexer() : super(0) {
    rules = [
      [LexerRule(RegExp("[^\"]+"), wordQuoted, 1)],
      [LexerRule(RegExp("\""), quote, null)],
      [LexerRule(RegExp("[a-zA-Z0-9]+"), word, null)],
      [LexerRule(RegExp("\\s+"), space, null)],
    ];
  }
}
