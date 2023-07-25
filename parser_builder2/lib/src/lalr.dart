
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:parser_builder2/src/constants.dart';
import 'package:parser_builder2_runtime/parser_builder2_runtime.dart';
import 'package:source_gen/source_gen.dart';


const String emptySymbol = "__empty";


class Rule<T> {
  T lhs;
  List<T> rhs;

  Rule(this.lhs, this.rhs);

  @override
  String toString() {
    return 'Rule{lhs: $lhs, rhs: $rhs}';
  }
}


class State {
  Set<Item> itemset;
  Set<Item> kernels;
  Map<String, int> transitionsOutgoing = {};
  Map<String, Set<int>> transitionsIngoing = {};

  State(this.kernels, List<Rule> rules) : itemset = itemSetClosure(kernels, rules);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is State && runtimeType == other.runtimeType &&
              SetEquality<Item>().equals(itemset, other.itemset);

  @override
  int get hashCode => Object.hashAllUnordered(itemset);

  @override
  String toString() {
    return 'State{itemset: $itemset, kernels: $kernels, transitionsOutgoing: $transitionsOutgoing}';
  }
}



class Item<T> {
  final T nonterminal;
  final List<T> symbols;
  // index to the next expected token
  final int dot;

  Item(this.nonterminal, this.symbols, this.dot);
  Item.advance(Item<T> i) : this(i.nonterminal, i.symbols, i.dot+1);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          nonterminal == other.nonterminal &&
          ListEquality().equals(symbols, other.symbols) &&
          dot == other.dot;

  @override
  int get hashCode => nonterminal.hashCode ^ Object.hashAll(symbols) ^ dot.hashCode;

  @override
  String toString() {
    return 'Item{nonterminal: $nonterminal, symbols: $symbols, dot: $dot}';
  }
}


Set<Item<T>> itemSetClosure<T>(Set<Item<T>> init, List<Rule<T>> rules) {
  Set<Item<T>> set = Set.of(init);
  int lastSize;
  do {
    lastSize = set.length;
    for (Item i in Set.of(set)) {
      if (i.dot < i.symbols.length) {
        for (Rule<T> r in rules.where((r) => r.lhs == i.symbols[i.dot])) {
          set.add(Item(r.lhs, r.rhs, 0));
        }
      }
    }
  } while (lastSize != set.length);
  return set;
}




List<State> stateMachine<T>(List<Rule<T>> rules) {
  List<State> states = [State({Item(startSymbol, rules.firstWhere((r) => r.lhs == startSymbol).rhs, 0)}, rules)];
  int index = 0;
  while (index < states.length) {
    for (var e in states[index].itemset.groupListsBy((e) {
      if (e.dot < e.symbols.length) {
        return e.symbols[e.dot];
      } else {
        return null;
      }
    }).entries) {
      if (e.key == null) continue;
      State next = State(e.value.toSet().map((e) => Item.advance(e)).toSet(), rules);
      int i = states.indexOf(next);
      if (i == -1) {
        i = states.length;
        states.add(next);
      } else {
        next = states[i];
      }
      next.transitionsIngoing[e.key!] ??= {};
      next.transitionsIngoing[e.key!]!.add(index);
      states[index].transitionsOutgoing[e.key!] = i;
    }
    index++;
  }
  return states;
}


Map<T, Set<T>> first<T>(List<Rule<T>> rules, T empty) {
  Map<T, Set<T>> firsts = {};
  Set<T> symbols = {};
  Set<T> nonterminals = {};
  for (var r in rules) {
    nonterminals.add(r.lhs);
    symbols.add(r.lhs);
    for (var s in r.rhs) {
      symbols.add(s);
    }
  }
  Set<T> terminals = symbols.difference(nonterminals);
  for (var t in terminals) {
    firsts[t] = {t};
  }
  for (var n in nonterminals) {
    Set<T> f = {};
    if (rules.any((r) => r.lhs == n && r.rhs.isEmpty)) {
      f.add(empty);
    }
    firsts[n] = f;
  }
  
  for (var n in nonterminals) {
    for (var r in rules.where((e) => e.lhs == n && e.rhs.isNotEmpty)) {
      bool allEmpty = true;
      for (var s in r.rhs) {
        firsts[n]!.addAll(firsts[s]!.difference({empty}));
        if (! firsts[s]!.contains(empty)) {
          allEmpty = false;
          break;
        }
      }
      if (allEmpty) {
        firsts[n]!.add(empty);
      }
    }
  }
  return firsts;
}




bool canBeEmpty<T>(Set<T> nonterminals, List<Rule<T>> rules, T s, {T? start}) {
  start ??= s;
  for (var r in rules.where((e) => e.lhs == s)) {
    if (! nonterminals.containsAll(r.rhs)) {
      return false;
    }
    for (var n in r.rhs) {
      // prevent loops
      if (n == start) {
        continue;
      }
      if (! canBeEmpty(nonterminals, rules, n, start: start)) {
        return false;
      }
    }
  }
  return true;
}


Map<T, Set<T>> follow<T>(Map<T, Set<T>> first, Set<T> nonterminals, List<Rule<T>> rules, T start, T end, T empty) {
  Map<T, Set<T>> follows = {};
  for (var n in nonterminals) {
    follows[n] = {};
  }
  //print(nonterminals);
  //follows[start]!.add(end);
  //print("start");
  for (var r in rules) {
    for (int i = 0; i < r.rhs.length-1; i++) {
      if (nonterminals.contains(r.rhs[i])) {
        follows[r.rhs[i]]!.addAll(first[r.rhs[i+1]]!.difference({empty}));
      }
    }
  }
  Map<T, bool> maybeEmpty = {};
  for (var n in nonterminals) {
    maybeEmpty[n] = canBeEmpty(nonterminals, rules, n);
  }
  Map<T, Set<T>> old;
  do {
    old = Map.of(follows);
    for (var r in rules.where((e) => e.rhs.isNotEmpty)) {
      for (var n in r.rhs.sublist(0, r.rhs.length-1).where((s) => nonterminals.contains(s) && maybeEmpty[s]!)) {
        follows[n]!.addAll(follows[r.lhs]!);
      }
      if (nonterminals.contains(r.rhs.last)) {
        follows[r.rhs.last]!.addAll(follows[r.lhs]!);
      }
    }
  } while (! MapEquality(values: SetEquality<T>()).equals(old, follows));
  return follows;
}


typedef Transition = ({int state, String symbol});

(LRParserTable, Map<String, int>) lalrTable(List<State> states, List<Rule<String>> rulesOriginal) {
  //print(states.join("\n"));
  LRParserTable t = [];
  final Transition empty = (state: -1, symbol: "");
  final Transition start = (state: 0, symbol: startSymbol);
  final Transition end = (state: -2, symbol: "");
  Set<String> nonterminalsOriginal = {};
  Set<String> symbolsOriginal = {};
  {
    for (var r in rulesOriginal) {
      nonterminalsOriginal.add(r.lhs);
      symbolsOriginal.add(r.lhs);
      symbolsOriginal.addAll(r.rhs);
    }
  }
  Set<String> terminalsOriginal = symbolsOriginal.difference(nonterminalsOriginal);
  
  Set<Transition> nonterminals = {};
  for (var (i, s) in states.indexed) {
    for (var sym in s.transitionsOutgoing.keys) {
      if (nonterminalsOriginal.contains(sym)) {
        nonterminals.add((state: i, symbol: sym));
      }
    }
  }
  
  
  List<Rule<Transition>> rules = [];
  for (var n in nonterminals) {
    for (var r in rulesOriginal.where((e) => e.lhs == n.symbol)) {
      bool viable = true;
      List<Transition> path = [];
      var state = states[n.state];
      for (var s in r.rhs) {
        int? next = state.transitionsOutgoing[s];
        if (next == null) {
          viable = false;
          break;
        }
        path.add((state: next, symbol: s));
        state = states[next];
      }
      if (viable) {
        rules.add(Rule(n, path));
      }
    }
  }

  int? go(int state, List<String> word) {
    int st = state;
    for (var s in word) {
      int? i = states[st].transitionsOutgoing[s];
      if (i == null) {
        return null;
      }
      st = i;
    }
    return st;
  }
  //print("here");
  Map<Transition, Set<Transition>> fi = first(rules, empty);
  //print("first");
  Map<Transition, Set<Transition>> fo = follow(fi, nonterminals, rules, start, end, empty);
  //print("follow");
  Set<String> lalrla(int q, Rule<String> r) {
    Set<String> la = {};
    for (var tr in nonterminals.where((e) => e.symbol == r.lhs)) {
      if (go(tr.state, r.rhs) == q) {
        la.addAll(fo[tr]!.map((e) => e.symbol));
      }
    }
    return la;
  }
  //print("here2");
  
  LinkedHashSet<String> symbolsSet = LinkedHashSet();
  symbolsSet.addAll(symbolsOriginal.difference(nonterminalsOriginal));
  symbolsSet.addAll(nonterminalsOriginal);
  List<String> symbols = symbolsSet.toList();
  
  int endIndex = symbols.indexOf(endSymbol);
  
  for (var (q, s) in states.indexed) {
    List<ParserAction> row = [];
    for (var sym in symbols) {
      if (s.transitionsOutgoing.containsKey(sym)) {
        if (terminalsOriginal.contains(sym)) {
          row.add(ParserAction.shift(s.transitionsOutgoing[sym]!));
        } else if (nonterminalsOriginal.contains(sym)) {
          row.add(ParserAction.goto(s.transitionsOutgoing[sym]!));
        }
      } else {
        row.add(ParserAction.reject());
      }
    }
    List<Rule<String>> reducables = [];
    for (var i in s.itemset) {
      if (i.dot == i.symbols.length - 1 && i.symbols.last == endSymbol) {
        row[endIndex] = ParserAction.accept();
      }
      if (i.dot == i.symbols.length) {
        var r = rulesOriginal.firstWhereOrNull((e) => ListEquality().equals(e.rhs, i.symbols));
        if (r != null) {
          reducables.add(r);
        }
      }
    }
    if (reducables.length == 1) {
      // shift/reduce conflict
      if (row.where((e) => e.type == ParserActionType.shift).isNotEmpty) {
        Set<String> la = lalrla(q, reducables.first);
        for (var t in terminalsOriginal.where((e) => la.contains(e)).map((e) => symbols.indexOf(e))) {
          if (row[t].type != ParserActionType.reject) {
            throw InvalidGenerationSourceError("shift/reduce conflivt");
          }
          row[t] = ParserAction.reduce(rulesOriginal.indexOf(reducables.first));
        }
      } else {
        for (var t in terminalsOriginal.map((e) => symbols.indexOf(e))) {
          row[t] = ParserAction.reduce(rulesOriginal.indexOf(reducables.first));
        }
      }
    }
    // reduce/reduce conflicts
    if (reducables.length > 1) {
      for (var r in reducables) {
        Set<String> la = lalrla(q, r);
        for (var t in terminalsOriginal.where((e) => la.contains(e)).map((e) => symbols.indexOf(e))) {
          if (row[t].type != ParserActionType.reject) {
            if (row[t].type == ParserActionType.shift) {
              throw InvalidGenerationSourceError("shift/reduce conflivt");
            } else {
              throw InvalidGenerationSourceError("reduce/reduce conflict");
            }
          }
          row[t] = ParserAction.reduce(rulesOriginal.indexOf(r));
        }
      }
    }
    t.add(row);
  }
  
  
  return (t, Map.fromIterables(symbols, symbols.indexed.map((e) => e.$1)));
}










