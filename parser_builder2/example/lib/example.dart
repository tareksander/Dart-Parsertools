
import 'package:parser_builder2_runtime/parser_builder2_runtime.dart';

// This is needed to include the file with the generated parser.
part 'example.g.dart';

// The terminal symbol is the type that gets passed to the parser.
// Here we just wrap a String.
class TestSymbol implements TerminalSymbol {
  String value;

  TestSymbol(this.value);
  
  // This must return the symbol name, which is used in the parser rules.
  @override
  get name => value;

  @override
  String toString() => value;
}

// The @Parser annotation defines a class as a parser.
// The start symbol is the start of the grammar.
// The parser type is the type of the generated parser, which influences generation time, generated size and language power.
// The root value is the value returned when the start symbol is parsed. Here we also use a string.
// We also have to include the type of the terminal token here.
@Parser(startSymbol: "E", type: ParserType.LALR1, rootValue: String, terminalSymbol: TestSymbol)
// A _classname class is generated for you to extend, which provides the parsing methods.
class TestParser extends _TestParser
{
  // The first value is the non-terminal symbol recognized by the rule, the second argument is the list of symbols it's made up of.
  // 
  @override
  @ParserRule("E", ["B"])
  String eFromB(String b) {
    return b;
  }
  
  @override
  @ParserRule("E", ["E", "+", "B"])
  String ePlusB(String e, TestSymbol plus, String b) {
    return "$e $plus $b";
  }
  
  @override
  @ParserRule("E", ["E", "*", "B"])
  String eTimesB(String e, TestSymbol star, String b) {
    return "$e $star $b";
  }
  
  @override
  @ParserRule("B", ["0"])
  String bFrom0(TestSymbol zero) {
    return "0";
  }
  
  @override
  @ParserRule("B", ["1"])
  String bFrom1(TestSymbol one) {
    return "1";
  }
}









