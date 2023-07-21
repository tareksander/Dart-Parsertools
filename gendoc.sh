#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit


for d in lexer_builder lexer_builder_runtime; do
  dart doc -o docs/"$d" "$d"
done


