/// Marker annotation for a lexer class.
class Lexer {
  /// The state the lexer will start in.
  final int startState;

  /// Annotates a lexer class.
  /// [startState] sets the starting state for the lexer, defaulting to 0.
  const Lexer({this.startState = 0});
}

/// Annotation for a lexer rule.
class Rule {
  /// A pattern string for matching the rule. This pattern will be used to create a [RegExp], so uses JavaScript regular expression syntax.
  final String pattern;

  /// The priority for matching this rule, a higher number means higher priority.
  /// The highest priority rule is used that has a match.
  /// For rules with the same priority, the longest match is used.
  final int priority;

  /// The state in which this rule will be matched.
  /// null means the rule will be considered for every state.
  final int? state;

  /// Constructs a lexer rule annotation.
  /// See [pattern], [priority] and [state] for information.
  const Rule(this.pattern, this.priority, {this.state});
}
