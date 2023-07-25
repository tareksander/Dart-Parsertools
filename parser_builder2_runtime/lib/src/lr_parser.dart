import 'parser.dart';
import 'package:meta/meta.dart';



class _LRParserState {
  final int state;
  final dynamic value;

  _LRParserState(this.state, this.value);
}

class LRParser<R, T extends TerminalSymbol> extends BaseParser<R, T> {
  final LRParserTable _table;
  /// The reduction rules of the parser.
  @protected
  late final List<LRParserRule> rules;
  final Map<String, int> _terminalMap;
  
  
  LRParser(this._table, this._terminalMap);
  
  
  @override
  R parse(List<T> input) {
    List<_LRParserState> stack = [_LRParserState(0, null)];
    List<TerminalSymbol> inputReal = List.of(input);
    inputReal.add(EndSymbol());
    int index = 0;
    while (index < inputReal.length) {
      TerminalSymbol? peekedSymbol = inputReal[index];
      int? peeked = _terminalMap[peekedSymbol.name];
      if (peeked == null) {
        throw ParserException();
      }
      int state = stack.last.state;
      ParserAction a = _table[state][peeked];
      switch (a.type) {
        case ParserActionType.accept:
          return stack.last.value as R;
        case ParserActionType.reject:
          throw ParserException();
        case ParserActionType.shift:
          index++;
          stack.add(_LRParserState(a.data, peekedSymbol));
        case ParserActionType.reduce:
          var rule = rules[a.data];
          List<dynamic> params = [];
          for (int i = 0; i < rule.consumed; i++) {
            params.insert(0, stack.removeLast().value);
          }
          state = stack.last.state;
          stack.add(_LRParserState(_table[state][rule.nonterminal].data, rule.action(params)));
        case ParserActionType.goto:
          throw ParserException();
      }
    }
    throw ParserException();
  }
  
  
  
  
}


