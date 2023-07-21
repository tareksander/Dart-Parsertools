import 'package:collection/collection.dart';
import 'exception.dart';
import 'rule.dart';
import 'package:meta/meta.dart';

/// Base class for generated lexers.
/// The lexer gets a List of rule lists, ordered by priority.
/// The highest priority rule that matches is chosen, if only one in the list matches.
/// If multiple rules in a list match, the longest match is used.
abstract class LexerBase<T extends Token> {
  /// List of rule lists, already sorted by descending priority.
  @protected
  late final List<List<LexerRule<T>>> rules;
  final int _startState;

  /// The current state.
  @protected
  int state = 0;

  /// Constructs a lexer with the start state.
  /// You have to initialize [rules] yourself in your constructor.
  LexerBase(this._startState);

  /// Tokenizes a String according to the rules.
  List<T> tokenize(String source) {
    state = _startState;
    List<T> tokens = [];
    int index = 0;
    int line = 1;
    int char = 1;
    while (index < source.length) {
      bool matchFound = false;
      for (var l in rules) {
        // calculate matches, if any, and sort by longest
        List<(Match, LexerRule<T>)> matches = l
            .map((rule) {
              if (rule.state != null && rule.state != state) {
                return null;
              } else {
                Match? m = rule.pattern.matchAsPrefix(source, index);
                if (m == null || m.end == index) {
                  return null;
                }
                return (m, rule);
              }
            })
            .whereType<(Match, LexerRule<T>)>()
            .sorted((a, b) => b.$1.end - a.$1.end)
            .toList();
        for (var v in matches) {
          var (m, r) = v;
          TokenResponse<T> res = r.action(m.group(0)!, line, char, index);
          if (res.type == TokenResponseType.accept) {
            var token = res.token;
            if (token != null) {
              tokens.add(token);
            }
            matchFound = true;
            index = m.end;
            char += m.end - m.start;
            int lines = '\n'.allMatches(m.group(0)!).length;
            line += lines;
            if (lines != 0) {
              char = m.group(0)!.length - m.group(0)!.lastIndexOf('\n');
            }
            break;
          }
        }
        if (matchFound) {
          break;
        }
      }
      if (!matchFound) {
        throw LexerNoMatchException(index, line, char);
      }
    }
    return tokens;
  }
}
