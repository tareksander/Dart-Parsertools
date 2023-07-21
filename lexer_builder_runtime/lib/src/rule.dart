/// Base class for all Tokens.
abstract class Token {}

/// The kinds of token responses.
enum TokenResponseType {
  /// The match is accepted, the input is marked as matched.
  accept,

  /// The match is rejected, the lexer will try to match the input to the following rules.
  reject,
}

/// Return type for rule methods.
/// Use the constructors to affect the behaviour of the lexer.
class TokenResponse<T extends Token> {
  /// See [TokenResponseType].
  final TokenResponseType type;

  /// The token returned by the action, if any.
  final T? token;

  /// Accept the match and optionally return a token.
  TokenResponse.accept(T? token) : this._(TokenResponseType.accept, token);

  /// Reject the match and let another rule match.
  TokenResponse.reject() : this._(TokenResponseType.reject, null);

  TokenResponse._(this.type, this.token);
}

/// Rule representation used internally by the generated code.
class LexerRule<T extends Token> {
  /// The pattern to match.
  final RegExp pattern;

  /// The action to call if matched.
  final TokenResponse<T> Function(String match, int line, int char, int index)
      action;

  /// The state in which the rule can be triggered.
  final int? state;

  /// Constructs a lexer rule.
  LexerRule(this.pattern, this.action, this.state);
}
