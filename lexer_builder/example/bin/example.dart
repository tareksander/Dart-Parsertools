import 'package:example/example.dart';

void main(List<String> arguments) {
  
  // tokenize a String and print the words matched in the tokens
  print(StringLexer().tokenize('word "words in string literal" word2').map((e) => e.value));
  // "(word, words in string literal, word2)" is printed out.
  // The first and last word are matched as tokens, and everything in the double quotes is a single token.
  
  
}
