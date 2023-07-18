/// The lexer generators. You shouldn't need to include this, running `dart run build_runner build` calls the builder.
library;


import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:lexer_builder_runtime/lexer_builder_runtime.dart';
import 'package:source_gen/source_gen.dart';

const TypeChecker _ruleChecker = TypeChecker.fromRuntime(Rule);
const _priorityField = "priority";
const _patternField = "pattern";
const _stateField = "state";
const _startStateField = "startState";


String toLiteral(String s) {
  return '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll(r'$', r'\$')}"';
}


String ruleToString(Rule r, String method) {
  return "LexerRule(RegExp(${toLiteral(r.pattern)}), $method, ${r.state})";
}




Builder lexerBuilder(BuilderOptions options) => SharedPartBuilder([LexerGenerator()], "lexer");

class LexerGenerator extends GeneratorForAnnotation<Lexer> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError("Lexer annotation is only valid for classes.");
    }
    int startState = annotation.read(_startStateField).intValue;
    String classname = element.name;
    List<MethodElement> children = element.methods;
    List<(MethodElement, Rule)> rules = [];
    
    for (var child in children) {
      var rule = _ruleChecker.firstAnnotationOfExact(child);
      if (rule != null) {
        rules.add((child, Rule(rule.getField(_patternField)!.toStringValue()!, rule.getField(_priorityField)!.toIntValue()!,
            state: rule.getField(_stateField)!.toIntValue())));
      }
    }
    //print(rules);
    {
      List<int> priorities = [];
      for (var r in rules) {
        if (r.$2.pattern.isEmpty) {
          throw InvalidGenerationSourceError("Rule has empty pattern: ${r.$1.name}");
        }
        int priority = r.$2.priority;
        if (priorities.contains(priority)) {
          throw InvalidGenerationSourceError("2 Rules with priority $priority found.");
        } else {
          priorities.add(priority);
        }
      }
    }
    rules.sort((a, b) => b.$2.priority - a.$2.priority);
    
    String rulesString = "[${rules.map((e) => ruleToString(e.$2, e.$1.name)).reduce((value, element) => "$value, $element")}]";
    
    //print(rules);
    String classCode = "abstract class _$classname<T extends Token> {\n";
    for (var r in rules) {
      classCode += "TokenResponse<T> ${r.$1.name}(String token);\n";
    }
    classCode +=
        "int _state = $startState;"
        "List<T> tokenize(String source) {\n"
        "int max(int a, int b) {if (a > b) {return a;} else {return b;}}\n"
        "_state = $startState;\n"
        "int index = 0;\n"
        "int line = 1;\n"
        "int char = 1;\n"
        "List<T> tokens = [];\n"
        "while (index < source.length) {\n"
        "List<LexerRule<T>> rules = $rulesString;\n"
        "List<int> lengths = rules.map((e)\n"
        "{\n"
        "if (e.state == _state || e.state == null)\n"
        "{return (e.pattern.matchAsPrefix(source, index)?.end ?? index) - index;}\n"
        "else {return 0;}\n"
        "}\n"
        ").toList();\n"
        "while (true) {\n"
        "if (lengths.isEmpty) throw LexerNoMatchException(index, line, char);\n"
        "int maxLength = lengths.reduce(max);\n"
        "if (maxLength == 0) throw LexerNoMatchException(index, line, char);\n"
        "int matched = lengths.indexWhere((element) => element == maxLength);\n"
        "Match m = rules[matched].pattern.matchAsPrefix(source, index)!;\n"
        "TokenResponse<T> resp = rules[matched].action(m.group(0)!);\n"
        "if (resp.type == TokenResponseType.reject) {lengths.removeAt(matched); rules.removeAt(matched); continue;}\n"
        "index = m.end;\n"
        "char += maxLength;\n"
        "int lines = '\\n'.allMatches(m.group(0)!).length;\n"
        "line += lines;\n"
        "if (lines != 0) {char = m.group(0)!.length - m.group(0)!.lastIndexOf('\\n');}\n"
        "if (resp.token != null) {tokens.add(resp.token!);}\n"
        "break;\n"
        "}\n"
        "}\n"
        "return tokens;\n"
        "}\n";
    
    
    classCode += "}";
    return classCode;
  }
}







