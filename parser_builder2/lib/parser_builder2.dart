/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:parser_builder2_runtime/parser_builder2_runtime.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';
import 'package:collection/collection.dart';
import 'src/constants.dart';

import 'src/lalr.dart' as lalr;

const _startSymbolField = "startSymbol";
const _typeField = "type";
const _rootValueField = "rootValue";
const _terminalSymbolField = "terminalSymbol";


const _nonterminalField = "nonterminal";
const _symbolsField = "symbols";



String _parserActionToString(ParserAction a) {
  return "ParserAction(ParserActionType.${a.type.name}, ${a.data})";
}


String _lrTableToLiteral(LRParserTable t) {
  String res = "[";
  for (var state in t) {
    res += "[";
    for (var action in state) {
      res += _parserActionToString(action);
      res += ",";
    }
    res += "],";
  }
  res += "]";
  return res;
}


String _symbolMapToString(Map<String, int> symbolMap) {
  String res = "{";
  for (var e in symbolMap.entries) {
    res += "${escapeDartString(e.key)}: ${e.value}, ";
  }
  res += "}";
  return res;
}


String _lrParserRules(List<lalr.Rule<String>> rules, List<MethodElement> methods, Map<String, int> symbolMap) {
  String res = "[";
  for (var (i, r) in rules.indexed) {
    if (i == 0) {
      res += "LRParserRule(_startRule, ${symbolMap[r.lhs]}, ${r.rhs.length}), ";
      continue;
    }
    res += "LRParserRule(_${methods[i-1].name}, ${symbolMap[r.lhs]}, ${r.rhs.length}), ";
  }
  res += "]";
  return res;
}


Builder parserBuilder(BuilderOptions options) =>
    SharedPartBuilder([ParserGenerator()], "parser");

TypeChecker _ruleChecker = TypeChecker.fromRuntime(ParserRule);

class ParserGenerator extends GeneratorForAnnotation<Parser> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          "Parser annotation is only valid for classes.", element: element, todo: "Apply the @Parser() annotation to a class.");
    }
    ParserType type = ParserType.values.firstWhereOrNull((element) => element.name == annotation.read(_typeField).read("_name").stringValue)!;
    if (type != ParserType.LALR1) {
      throw InvalidGenerationSourceError("Only LALR1 parsers are currently supported", element: element, todo: "Use the LALR1 parser type.");
    }

    String classname = element.name;
    String originalStartSymbol = annotation.read(_startSymbolField).stringValue;
    List<ParserRule> rules = [];
    List<MethodElement> methods = [];
    //Map<ParserRule, MethodElement> rulesToMethods = {};

    for (var child in element.methods) {
      var rule = _ruleChecker.firstAnnotationOfExact(child);
      if (rule != null) {
        var reader = ConstantReader(rule);
        var r = ParserRule(
            reader.read(_nonterminalField).stringValue,
            reader
                .read(_symbolsField)
                .listValue
                .map((e) => ConstantReader(e).stringValue)
                .toList());
        if (r.nonterminal.startsWith("__") || r.symbols.firstWhereOrNull((element) => element.startsWith("__")) != null) {
          throw InvalidGenerationSourceError("Symbols starting with '__' are reserved for internal use by the parser generator.", element: child, todo: "Rename the offending symbol.");
        }
        rules.add(r);
        methods.add(child);
        //rulesToMethods[r] = child;
      }
    }
    {
      var count = rules.map((e) => e.nonterminal == originalStartSymbol ? 1 : 0).sum;
      if (count == 0) {
        throw InvalidGenerationSourceError("Start symbol not present in rules.", element: element, todo: "Use the specified start symbol in the rules.");
      }
    }
    
    // TODO check return and parameter types of
    
    List<lalr.Rule<String>> parserRules = rules.map((e) => lalr.Rule(e.nonterminal, e.symbols)).toList();
    parserRules.insert(0, lalr.Rule(startSymbol, [originalStartSymbol, endSymbol]));
    
    
    var (table, symbolMap) = lalr.lalrTable(lalr.stateMachine(parserRules), parserRules);
    
    // TODO construct ParserRules array string
    String generatedTable = _lrTableToLiteral(table);
    String generatedRules = _lrParserRules(parserRules, methods, symbolMap);
    String generatedTerminalMap = _symbolMapToString(symbolMap);
    
    
    String rootValue = annotation
        .read(_rootValueField)
        .typeValue.getDisplayString(withNullability: false);
    
    String classContent = "abstract class _$classname extends LRParser<$rootValue, ${annotation.read(_terminalSymbolField).typeValue.getDisplayString(withNullability: false)}> {\n";
    
    for (var i in rules.indexed.map((e) => e.$1)) {
      var m = methods[i];
      classContent += "${m.returnType} ${m.name}(${m.parameters.join(", ")});\n";
      classContent += "${m.returnType} _${m.name}(List<dynamic> args) {\n";
      classContent += "return ${m.name}(${m.parameters.mapIndexed((i, e) => "args[$i] as ${e.type}").join(", ")});\n";
      classContent += "}\n";
    }
    
    classContent += "$rootValue _startRule(List<dynamic> args) {\n"
        "return args[0] as $rootValue;\n"
        "}\n";
    
    classContent +=
        "_$classname() : super($generatedTable, $generatedTerminalMap) {\n"
        "rules = $generatedRules;\n"
        "}\n";
    
    
    
    
    classContent += "}";
    

    return classContent;
  }
}
