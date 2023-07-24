import 'dart:io';

import 'package:lexer_builder/lexer_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:source_gen_test/source_gen_test.dart';

void main() {
  test("Build compiles", () async {
    expect(
        await generateForElement(
            LexerGenerator(),
            await initializeLibraryReaderForDirectory(
                "example/lib", "example.dart"),
            "StringLexer"),
        (await File("example/.dart_tool/build/generated/example/lib/example.lexer.g.part")
                .readAsString())
            .split("\n")
            .skip(4)
            .join("\n"));
  });
}
