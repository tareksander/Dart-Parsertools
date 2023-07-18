// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// LexerGenerator
// **************************************************************************

abstract class _StringLexer<T extends Token> {
  TokenResponse<T> wordQuoted(String token);
  TokenResponse<T> quote(String token);
  TokenResponse<T> word(String token);
  TokenResponse<T> space(String token);
  int _state = 0;
  List<T> tokenize(String source) {
    int max(int a, int b) {
      if (a > b) {
        return a;
      } else {
        return b;
      }
    }

    _state = 0;
    int index = 0;
    int line = 1;
    int char = 1;
    List<T> tokens = [];
    while (index < source.length) {
      List<LexerRule<T>> rules = [
        LexerRule(RegExp("[^\"]+"), wordQuoted, 1),
        LexerRule(RegExp("\""), quote, null),
        LexerRule(RegExp("[a-zA-Z0-9]+"), word, null),
        LexerRule(RegExp("\\s+"), space, null)
      ];
      List<int> lengths = rules.map((e) {
        if (e.state == _state || e.state == null) {
          return (e.pattern.matchAsPrefix(source, index)?.end ?? index) - index;
        } else {
          return 0;
        }
      }).toList();
      while (true) {
        if (lengths.isEmpty) throw LexerNoMatchException(index, line, char);
        int maxLength = lengths.reduce(max);
        if (maxLength == 0) throw LexerNoMatchException(index, line, char);
        int matched = lengths.indexWhere((element) => element == maxLength);
        Match m = rules[matched].pattern.matchAsPrefix(source, index)!;
        TokenResponse<T> resp = rules[matched].action(m.group(0)!);
        if (resp.type == TokenResponseType.reject) {
          lengths.removeAt(matched);
          rules.removeAt(matched);
          continue;
        }
        index = m.end;
        char += maxLength;
        int lines = '\n'.allMatches(m.group(0)!).length;
        line += lines;
        if (lines != 0) {
          char = m.group(0)!.length - m.group(0)!.lastIndexOf('\n');
        }
        if (resp.token != null) {
          tokens.add(resp.token!);
        }
        break;
      }
    }
    return tokens;
  }
}
