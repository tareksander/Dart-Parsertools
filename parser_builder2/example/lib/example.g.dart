// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// ParserGenerator
// **************************************************************************

abstract class _TestParser extends LRParser<String, TestSymbol> {
  String eFromB(String b);
  String _eFromB(List<dynamic> args) {
    return eFromB(args[0] as String);
  }

  String ePlusB(String e, TestSymbol plus, String b);
  String _ePlusB(List<dynamic> args) {
    return ePlusB(args[0] as String, args[1] as TestSymbol, args[2] as String);
  }

  String eTimesB(String e, TestSymbol star, String b);
  String _eTimesB(List<dynamic> args) {
    return eTimesB(args[0] as String, args[1] as TestSymbol, args[2] as String);
  }

  String bFrom0(TestSymbol zero);
  String _bFrom0(List<dynamic> args) {
    return bFrom0(args[0] as TestSymbol);
  }

  String bFrom1(TestSymbol one);
  String _bFrom1(List<dynamic> args) {
    return bFrom1(args[0] as TestSymbol);
  }

  String _startRule(List<dynamic> args) {
    return args[0] as String;
  }

  _TestParser()
      : super([
          [
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.shift, 3),
            ParserAction(ParserActionType.shift, 4),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.goto, 1),
            ParserAction(ParserActionType.goto, 2),
          ],
          [
            ParserAction(ParserActionType.accept, 0),
            ParserAction(ParserActionType.shift, 6),
            ParserAction(ParserActionType.shift, 7),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
          [
            ParserAction(ParserActionType.reduce, 1),
            ParserAction(ParserActionType.reduce, 1),
            ParserAction(ParserActionType.reduce, 1),
            ParserAction(ParserActionType.reduce, 1),
            ParserAction(ParserActionType.reduce, 1),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
          [
            ParserAction(ParserActionType.reduce, 4),
            ParserAction(ParserActionType.reduce, 4),
            ParserAction(ParserActionType.reduce, 4),
            ParserAction(ParserActionType.reduce, 4),
            ParserAction(ParserActionType.reduce, 4),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
          [
            ParserAction(ParserActionType.reduce, 5),
            ParserAction(ParserActionType.reduce, 5),
            ParserAction(ParserActionType.reduce, 5),
            ParserAction(ParserActionType.reduce, 5),
            ParserAction(ParserActionType.reduce, 5),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
          [
            ParserAction(ParserActionType.reduce, 0),
            ParserAction(ParserActionType.reduce, 0),
            ParserAction(ParserActionType.reduce, 0),
            ParserAction(ParserActionType.reduce, 0),
            ParserAction(ParserActionType.reduce, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
          [
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.shift, 3),
            ParserAction(ParserActionType.shift, 4),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.goto, 8),
          ],
          [
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.shift, 3),
            ParserAction(ParserActionType.shift, 4),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.goto, 9),
          ],
          [
            ParserAction(ParserActionType.reduce, 2),
            ParserAction(ParserActionType.reduce, 2),
            ParserAction(ParserActionType.reduce, 2),
            ParserAction(ParserActionType.reduce, 2),
            ParserAction(ParserActionType.reduce, 2),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
          [
            ParserAction(ParserActionType.reduce, 3),
            ParserAction(ParserActionType.reduce, 3),
            ParserAction(ParserActionType.reduce, 3),
            ParserAction(ParserActionType.reduce, 3),
            ParserAction(ParserActionType.reduce, 3),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
            ParserAction(ParserActionType.reject, 0),
          ],
        ], {
          '__end': 0,
          '+': 1,
          '*': 2,
          '0': 3,
          '1': 4,
          '__start': 5,
          'E': 6,
          'B': 7,
        }) {
    rules = [
      LRParserRule(_startRule, 5, 2),
      LRParserRule(_eFromB, 6, 1),
      LRParserRule(_ePlusB, 6, 3),
      LRParserRule(_eTimesB, 6, 3),
      LRParserRule(_bFrom0, 7, 1),
      LRParserRule(_bFrom1, 7, 1),
    ];
  }
}
