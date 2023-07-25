

/// Base class for exceptions thrown in parsers.
/// If you throw exceptions in your actions, you should subclass this.
class ParserException implements Exception {
  
  
  
}



/// The root semantic value (that of the start symbol) is always a subclass of this.
abstract class RootValue {}


/// Interface for terminal symbols inputted into the parser.
abstract class TerminalSymbol {

  /// Returns the terminal symbol name, which will be compared to the
  /// strings of terminal symbols specified in the rules for equality.
  get name;
}


/// Special end-of-input symbol.
/// Library users don't need to use this, it's added at the end of the parser input automatically.
class EndSymbol extends TerminalSymbol {
  @override
  get name => "__end";
}


/// Actions for parsing table entries.
/// Library users don't need to use this.
enum ParserActionType {
  /// Shift the peeked token onto the stack.
  shift,
  /// Reduce tokens according to a rule.
  reduce,
  /// Accept the input.
  accept,
  /// Reject the input.
  reject,
  /// Go to a specified state.
  goto
}

/// An entry in a parsing table.
/// Library users don't need to use this.
class ParserAction {
  /// The action the parser should perform.
  final ParserActionType type;
  /// For shift, this is the index of the next state.
  /// For reduce, the amount of symbols to pop off the stack.
  /// For goto, this is the next state to enter.
  final int data;
  
  
  const ParserAction.shift(int data) : this(ParserActionType.shift, data);
  const ParserAction.reduce(int data) : this(ParserActionType.reduce, data);
  const ParserAction.accept() : this(ParserActionType.accept, 0);
  const ParserAction.reject() : this(ParserActionType.reject, 0);
  const ParserAction.goto(int data) : this(ParserActionType.goto, data);
  
  const ParserAction(this.type, this.data);
}

/// The parser table type for an LR(1) parser.
/// The first index is the parser state, the second the token index.
/// Library users don't need to use this.
typedef LRParserTable = List<List<ParserAction>>;

/// A rule for an LR parser. [ParserAction.data] is an index into a table of [LRParserRule]s.
/// Library users don't need to use this.
class LRParserRule {
  /// The rule action to call.
  dynamic Function(List<dynamic>) action;
  /// The generated nonterminal symbol index.
  int nonterminal;
  /// The number of consumed tokens from the stack.
  int consumed;

  LRParserRule(this.action, this.nonterminal, this.consumed);
}

/// Base class for all parsers.
abstract class BaseParser<R, T extends TerminalSymbol> {
  
  /// Parses a list of terminal symbols into the semantic value of the start symbol.
  R parse(List<T> input);
  
  /// The same as [parse], but can work with a [Stream] of terminal tokens.
  /// Not yet implemented.
  Future<R> parseAsync(Stream<T> input) async {
    throw UnimplementedError("Async parsing not yet implemented");
  }
  
}



