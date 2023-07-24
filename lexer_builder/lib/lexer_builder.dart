/// The lexer generators. You shouldn't need to include this, running `dart run build_runner build` calls the builder.
library;


import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:lexer_builder_runtime/lexer_builder_runtime.dart';
import 'package:source_gen/source_gen.dart';

const TypeChecker _ruleChecker = TypeChecker.fromRuntime(Rule);
const _priorityField = "priority";
const _patternField = "pattern";
const _stateField = "state";
const _startStateField = "startState";


String _toLiteral(String s) {
  return '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll(r'$', r'\$').replaceAll("\n", "\\n")}"';
}


String _ruleToString(Rule r, String method) {
  return "LexerRule(RegExp(${_toLiteral(r.pattern)}), $method, ${r.state})";
}



/// Creates a SharedPartBuilder for the lexer generator.
Builder lexerBuilder(BuilderOptions options) => SharedPartBuilder([LexerGenerator()], "lexer");


/// Generates lexer classes for classes with the Lexer annotation.
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
    
    {
      for (var r in rules) {
        if (r.$2.pattern.isEmpty) {
          throw InvalidGenerationSourceError("Rule has empty pattern: ${r.$1.name}");
        }
      }
    }
    var ruleLists = rules.groupListsBy((e) => e.$2.priority);
    List<int> priorities = ruleLists.keys.sorted((a, b) => b - a).toList();
    
    String rulesString = "";
    
    
    for (int k in priorities) {
      rulesString +=
      "[${ruleLists[k]!.map((e) => _ruleToString(e.$2, e.$1.name)).reduce((value,
          element) => "$value, $element")}],";
    }
    rulesString = "[$rulesString]";
    
    
    String classCode = "abstract class _$classname<T extends Token> extends LexerBase<T> {\n";
    for (var r in rules) {
      classCode += "TokenResponse<T> ${r.$1.name}(String token, int line, int char, int index);\n";
    }
    
    classCode += "_$classname() : super($startState) {rules = $rulesString;}\n";
    
    
    classCode += "}";
    return classCode;
  }
}







