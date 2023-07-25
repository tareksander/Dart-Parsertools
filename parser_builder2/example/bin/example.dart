import 'package:example/example.dart';

void main(List<String> arguments) {
  
  TestParser p = TestParser();
  
  print(p.parse([TestSymbol("1"), TestSymbol("+"), TestSymbol("1")]));
  
  
}
