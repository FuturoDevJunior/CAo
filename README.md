# CAo

Repositório dedicado ao plano de Bug Bounty para a Bykea, totalmente em português.
Consulte o arquivo [BUG_BOUNTY_PLAN.md](BUG_BOUNTY_PLAN.md) para a descrição
completa do programa e das sprints.

## Estrutura

- `scripts/` &mdash; scripts de automação para coleta de
  subdomínios, mapeamento de endpoints, geração de wordlists e
  execução do nuclei.
- `templates/` &mdash; templates do nuclei prontos para serem usados.
- `output/` &mdash; diretório gerado com os resultados dos scripts.

## Uso Rápido

1. `./scripts/enumerate_subdomains.sh` &mdash; gera `output/subdomains_unique.txt`.
2. `./scripts/map_endpoints.sh` &mdash; cria `output/hist_endpoints.txt`.
3. `./scripts/generate_wordlist.py < respostas.json > wordlist.txt` &mdash; produz wordlist customizada.
4. `./scripts/run_nuclei.sh` &mdash; roda o nuclei sobre os subdomínios encontrados.

Todos os comandos devem ser executados a partir do diretório raiz do repositório.
As saídas são gravadas em `output/` (definível via variável `OUTPUT_DIR`).
Verifique se as dependências `amass`, `subfinder`, `gau` e `nuclei` estão instaladas.
