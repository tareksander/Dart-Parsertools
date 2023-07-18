
/// Base class for Lexer exceptions.
/// If you throw exceptions in the rules, you should use a subclass of this.
abstract class LexerException implements Exception {}


/// No rule matched for the string starting at [index].
class LexerNoMatchException extends LexerException {
  /// The index in the input where no match could be found.
  final int index;
  /// The line of [index].
  final int line;
  /// The character in the [line] of [index].
  final int char;
  LexerNoMatchException(this.index, this.line, this.char);
  
  @override
  String toString() {
    return "Lexer found no match at: index $index; line $line, char $char";
  }
  
}

