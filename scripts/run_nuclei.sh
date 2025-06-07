#!/bin/bash
# Executa o nuclei com templates personalizados nos subdomínios enumerados
# Uso: ./run_nuclei.sh [opções adicionais do nuclei]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUTDIR="${OUTPUT_DIR:-$REPO_ROOT/output}"
TEMPLATES_DIR="$REPO_ROOT/templates"
SUBS_FILE="$OUTDIR/subdomains_unique.txt"
RESULTS="$OUTDIR/nuclei_results.txt"

need() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "[ERRO] Comando '$1' não encontrado. Instale-o e tente novamente." >&2
        exit 1
    }
}

need nuclei

if [ ! -f "$SUBS_FILE" ]; then
    echo "Arquivo $SUBS_FILE inexistente. Execute enumerate_subdomains.sh primeiro." >&2
    exit 1
fi

nuclei -l "$SUBS_FILE" -t "$TEMPLATES_DIR" -o "$RESULTS" "$@"

echo "[+] Resultados do nuclei salvos em $RESULTS"
