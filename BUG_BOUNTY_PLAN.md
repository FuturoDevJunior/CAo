# Plano Avançado de Bug Bounty para Bykea

Este plano avançado eleva ao máximo sua estratégia de Bug Bounty para a Bykea, incorporando as técnicas mais modernas de segurança móvel, APIs e automação, apoiado por referências de autoridade da OWASP, HackerOne, CyCognito e outros. A estrutura em seis sprints de duas semanas mantém o foco em entregáveis claros, medição de performance e melhoria contínua, enquanto adota práticas como engenharia reversa, fuzzing contextual, testes de confiança zero em APIs e desenvolvimento de extensões personalizadas para o Burp Suite. O resultado é um processo ágil e robusto, pronto para superar quaisquer desafios técnicos e entregar PoCs de alto impacto, com tempos de resposta e recompensa alinhados às metas da Bykea.

### Recursos do Repositório

Este projeto traz utilitários de automação em `scripts/`, templates Nuclei em `templates/` e armazena saídas em `output/`.

---

## ## Sprint 1 (Semanas 1–2): Superfície de Ataque e Emulação Móvel

### 1.1. Revisão e Documentação

* Baixar e ler completamente a política da Bykea no HackerOne, anotando requisitos de *Safe Harbor Gold Standard* e resposta em 1 h ([hackerone.com][1]).
* Mapear ativos **in scope** (`*.bykea.net`, `com.bykea.pk`, `com.bykea.pk.partner`, `1351179184`) e **out of scope** (CSRF sem impacto, clickjacking, etc.) ([cycognito.com][2]).

### 1.2. Emuladores e Localização

* Configurar emulador Android e iOS com localização fixa em **Sibi, Pakistan**, essencial para geofencing ([cycognito.com][2]).
* Obter credenciais via aba *Credentials* (Signal 3+) ou solicitando a **[h1@bykea.com](mailto:h1@bykea.com)** ([hackerone.com][1]).

### 1.3. Ferramentas e Integrações

* **Proxy interceptação** (Burp Suite/ZAP) com header `X-Bug-Bounty: h1-username` e limitação < 8 req/s ([cycognito.com][2]).
* **Enumeração de subdomínios**: Amass/Subfinder para `bykea.net` ([hackerone.com][3]).
* **Fuzzing de parâmetros**: FFUF com wordlists customizadas (e.g., `ride_id`, `wallet_id`) .

### 1.4. Mapear Endpoints

* Passivo e ativo:

  ```bash
  amass enum -d bykea.net -o subs1.txt  
  subfinder -d bykea.net -o subs2.txt  
  gau bykea.net | egrep -i '/api|/graphql' > hist_endpoints.txt  
  ``` :contentReference[oaicite:7]{index=7}.  
  ```
* Consolidar em planilha “Surface Map v1.0” com domínio, endpoint e HTTP status.

---

## ## Sprint 2 (Semanas 3–4): Autenticação, Sessão e Controle de Acesso

### 2.1. Autenticação e Sessões Seguras

* Testar fluxo de OTP (4 dígitos fixo) interceptando JWT/session token via Burp; verificar flags `Secure`, `HttpOnly`, `SameSite` nos cookies ([testdevlab.com][4]).
* Brute-force controlado com Hydra, implementando delays progressivos para respeitar rate-limit e evitar bloqueios ([testdevlab.com][4]).

### 2.2. Detecção Avançada de IDOR

* Pegar parâmetros como `ride_id`, `wallet_id` em endpoints e usar Burp Intruder para varredura sequencial e JSON globbing ([intigriti.com][5]).
* Explorar *content-type*-based IDOR e versões de API depreciadas, conforme guia Intigriti ([intigriti.com][5]).

### 2.3. Bypass de Autorização

* Testar tokens de usuário padrão para acessar rotas administrativas (`/admin/`, `/partner/`); documentar qualquer sucesso como IDOR de alta severidade ([linkedin.com][6]).

### 2.4. Entregável Sprint 2

* PoCs escritas no template Shopify, com payloads cURL, capturas de tela, **X-Bug-Bounty-IDs** e recomendações de mitigação.

---

## ## Sprint 3 (Semanas 5–6): Injeções e Lógica de Negócio

### 3.1. SQLi / NoSQLi Profundo

* **SAST/DAST combinado**: usar ferramentas como CyCognito recomenda SAST para análise de código e DAST para endpoints ativos ([cycognito.com][2]).
* Injetar payloads em REST e GraphQL:

  ```json
  { "query": "query { user(id: \"1' OR 1=1--\") { email } }" }
  ``` :contentReference[oaicite:14]{index=14}.
  ```

### 3.2. SSRF Não-Blind e Blind

* Identificar parâmetros `?url=`, `?webhook=` e enviar para `http://169.254.169.254/latest/meta-data/` ([owasp.org][7]).
* Usar Interact.sh para detectar *blind SSRF* e correlacionar callbacks ([theindiannetwork.medium.com][8]).

### 3.3. Falhas de Lógica de Negócio

* Abusar de promo codes e manipular JSON de transação para subverter saldo de carteira com Burp Repeater; validar rollbacks incorretos ([cobalt.io][9]).

### 3.4. Entregável Sprint 3

* Planilha “Injection & Logic v2.0” com endpoints, payloads, respostas e severidade CVSS estimada.

---

## ## Sprint 4 (Semanas 7–8): Segurança Móvel Profunda (OWASP MASTG)

### 4.1. Compliance MASVS & MASTG

* Seguir OWASP MASVS para controles de armazenamento seguro, criptografia e pinagem de certificados ([mas.owasp.org][10]).
* Realizar **Static Analysis** via MobSF e **Dynamic Analysis** conforme MASTG-TECH-0049 ([mas.owasp.org][11]).

### 4.2. Engenharia Reversa e Detecção Anti-Debug

* Decompilar APK (APKTool) e binário iOS (class-dump) para identificar endpoints hardcoded e controles de segurança ausentes .
* Bypass de certificate pinning com Frida scripting (SSLVerify hook) e testar anti-debugging via patching de runtime .

### 4.3. Entregável Sprint 4

* Documento “Mobile Deep Dive v1.0” com mapeamento MASVS, PoCs de bypass e recomendações de hardening.

---

## ## Sprint 5 (Semanas 9–10): Automação e Extensões Personalizadas

### 5.1. Templates Nuclei & FFUF Contextual

* Criar template **Bykea-SSRF** e **Bykea-IDOR** baseado nos padrões Nuclei .
* Os scripts de automação estão no diretório `scripts/` e os templates no diretório `templates/`.
* Gerar **wordlists** de parâmetros extraídos via script Python que parseia JSON de respostas de APIs .

### 5.2. Extensões Burp Suite Customizadas

* Desenvolver extensão em Java usando Montoya API para automatizar identificação de `X-Bug-Bounty` e tagueamento de respostas vulneráveis ([portswigger.net][12]).
* Incluir módulos de evasão de WAF (encoding, chunked payloads) para variações de XSS/SQLi ([cirius.medium.com][13]).

### 5.3. Template Mestre de Relatório

* Consolidar estrutura com: título padrão, sumário, PoC, **X-Bug-Bounty-IDs**, impacto de negócio e CVSS multiplicador (1.5× para high/critical) ([owasp.org][14], [cycognito.com][2]).

### 5.4. Entregável Sprint 5

* Repositórios Git “bykea-nuclei-templates” e “bykea-burp-extensions” com README e exemplos de uso.

---

## ## Sprint 6 (Semanas 11–12): Métricas, Retrospectiva e Evolução Contínua

### 6.1. Dashboard de Métricas

* Consolidar KPIs: taxa de aceitação (> 50%), tempo médio até bounty (≤ 8 h), volume de duplicados ([hackerone.com][3]).
* Gerar dashboard em planilha com gráficos de linhas para evolução sprint-a-sprint.

### 6.2. Retrospectiva Ágil

* Reunião “Start-Stop-Continue” para avaliar sucessos, obstáculos (e.g., OTP fixo) e definir ações (atualizar wordlists, treinar equipe em Frida) ([hackerone.com][15]).

### 6.3. Planejamento Next Cycle

* Repriorizar backlog:

  * **APIs Wallet** → foco em lógica financeira se yields forem maiores.
  * **OAuth & GraphQL** → dedicar sprint exclusivo para rotas de autorização e introspecção de schema.

---

> **Conclusão:**
> Com este plano aprimorado, sua equipe aplica as **melhores práticas do mercado** — de OWASP MASTG e MASVS até automação avançada e extensões customizadas — para entregar resultados de segurança de nível enterprise, **superando todas as expectativas** em velocidade, cobertura e impacto.

[1]: https://hackerone.com/bykea?utm_source=chatgpt.com "Bykea | Bug Bounty Program Policy - HackerOne"
[2]: https://www.cycognito.com/learn/api-security/api-security-testing.php?utm_source=chatgpt.com "8 API Security Testing Methods and How to Choose | CyCognito"
[3]: https://www.hackerone.com/blog/level-your-bug-bounty-effectiveness-3-keys-launch-successful-program?utm_source=chatgpt.com "Level Up Your Bug Bounty Effectiveness: 3 Keys to Launch a ..."
[4]: https://www.testdevlab.com/blog/mobile-app-security-testing-best-practices?utm_source=chatgpt.com "The Best Practices for Mobile App Security Testing - TestDevLab"
[5]: https://www.intigriti.com/blog/news/idor-a-complete-guide-to-exploiting-advanced-idor-vulnerabilities?utm_source=chatgpt.com "A complete guide to exploiting advanced IDOR vulnerabilities - Intigriti"
[6]: https://www.linkedin.com/pulse/mastering-idor-vulnerability-identification-advanced-guide-samit-hota?utm_source=chatgpt.com "Mastering IDOR Vulnerability Identification: An Advanced Guide for ..."
[7]: https://owasp.org/www-project-web-security-testing-guide/stable/4-Web_Application_Security_Testing/07-Input_Validation_Testing/19-Testing_for_Server-Side_Request_Forgery?utm_source=chatgpt.com "Testing for Server-Side Request Forgery - OWASP Foundation"
[8]: https://theindiannetwork.medium.com/the-ultimate-ssrf-testing-guide-unleash-the-hidden-web-secrets-2025-8c151068cedf?utm_source=chatgpt.com "The Ultimate SSRF Testing Guide: Unleash the Hidden Web Secrets ..."
[9]: https://www.cobalt.io/blog/top-10-api-security-validation-techniques?utm_source=chatgpt.com "Top 10 API Security Validation Techniques - Cobalt"
[10]: https://mas.owasp.org/MASTG/?utm_source=chatgpt.com "OWASP MASTG - OWASP Mobile Application Security"
[11]: https://mas.owasp.org/MASTG/techniques/generic/MASTG-TECH-0049/?utm_source=chatgpt.com "MASTG-TECH-0049: Dynamic Analysis"
[12]: https://portswigger.net/burp/documentation/desktop/extend-burp/extensions/creating?utm_source=chatgpt.com "Creating Burp extensions - PortSwigger"
[13]: https://cirius.medium.com/writing-your-own-burpsuite-extensions-complete-guide-cb7aba4dbceb?utm_source=chatgpt.com "Writing your own Burpsuite Extensions: Complete Guide"
[14]: https://owasp.org/www-project-mobile-app-security/?utm_source=chatgpt.com "OWASP Mobile Application Security"
[15]: https://www.hackerone.com/blog/ten-rules-be-successful-your-bug-bounty-career?utm_source=chatgpt.com "Ten Rules to be Successful in Your Bug Bounty Career - HackerOne"
