#!/usr/bin/env python3
"""Gera wordlists de chaves JSON a partir de respostas de APIs.

Uso:
  ./generate_wordlist.py arquivo1.json arquivo2.json > wordlist.txt
  cat respostas.json | ./generate_wordlist.py > wordlist.txt
"""
import argparse
import json
import sys
from typing import Any, Set

def extract_keys(obj: Any, acc: Set[str]) -> None:
    if isinstance(obj, dict):
        for k, v in obj.items():
            acc.add(k)
            extract_keys(v, acc)
    elif isinstance(obj, list):
        for item in obj:
            extract_keys(item, acc)

def process_stream(stream, acc: Set[str]) -> None:
    for line in stream:
        line = line.strip()
        if not line:
            continue
        try:
            data = json.loads(line)
        except json.JSONDecodeError:
            continue
        extract_keys(data, acc)

def main() -> None:
    parser = argparse.ArgumentParser(description="Extrai chaves únicas de arquivos JSON")
    parser.add_argument('files', nargs='*', help='arquivos JSON (padrão: stdin)')
    args = parser.parse_args()

    keys: Set[str] = set()
    if args.files:
        for fname in args.files:
            with open(fname, 'r', encoding='utf-8') as fh:
                process_stream(fh, keys)
    else:
        process_stream(sys.stdin, keys)

    for key in sorted(keys):
        print(key)

if __name__ == '__main__':
    main()
