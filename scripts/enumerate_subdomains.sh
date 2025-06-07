#!/bin/bash
# Enumera subdomínios da Bykea de forma profissional
# Uso: ./enumerate_subdomains.sh [domínio]
set -euo pipefail

DOMAIN="${1:-bykea.net}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUTDIR="${OUTPUT_DIR:-$REPO_ROOT/output}"

need() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "[ERRO] Comando '$1' não encontrado. Instale-o e tente novamente." >&2
        exit 1
    }
}

need amass
need subfinder

mkdir -p "$OUTDIR"

echo "[*] Enumerando subdomínios de $DOMAIN ..."
amass enum -d "$DOMAIN" -o "$OUTDIR/subdomains_amass.txt" >/dev/null
subfinder -d "$DOMAIN" -o "$OUTDIR/subdomains_subfinder.txt" >/dev/null

sort -u "$OUTDIR"/subdomains_{amass,subfinder}.txt > "$OUTDIR/subdomains_unique.txt"

echo "[+] Subdomínios salvos em $OUTDIR/subdomains_unique.txt"
