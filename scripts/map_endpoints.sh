#!/bin/bash
# Mapeia endpoints históricos da Bykea
# Uso: ./map_endpoints.sh [domínio]
set -euo pipefail

DOMAIN="${1:-bykea.net}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUTDIR="${OUTPUT_DIR:-$REPO_ROOT/output}"
SUBS_FILE="$OUTDIR/subdomains_unique.txt"

need() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "[ERRO] Comando '$1' não encontrado. Instale-o e tente novamente." >&2
        exit 1
    }
}

need gau
need grep

mkdir -p "$OUTDIR"

if [ ! -f "$SUBS_FILE" ]; then
    "$SCRIPT_DIR/enumerate_subdomains.sh" "$DOMAIN"
fi

> "$OUTDIR/hist_endpoints.txt"
while read -r sub; do
    gau "$sub" | grep -Ei '/api|/graphql' >> "$OUTDIR/hist_endpoints.txt"
done < "$SUBS_FILE"

sort -u "$OUTDIR/hist_endpoints.txt" -o "$OUTDIR/hist_endpoints.txt"

echo "[+] Endpoints salvos em $OUTDIR/hist_endpoints.txt"
