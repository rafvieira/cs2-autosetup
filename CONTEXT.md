# Contexto de Desenvolvimento - CS2 ACT (Autoconfig Tool)

## 🎯 Objetivo do Projeto
O **CS2 ACT** é uma ferramenta de automação desenvolvida para a **OnlyGoes Informática e Tecnologia**. O objetivo é padronizar e acelerar o processo de configuração do Counter-Strike 2, permitindo extrair, restaurar e preparar o ambiente (instalação de Steam e CS2) com foco em UX e robustez técnica.

## 🛠️ Arquitetura e Decisões Técnicas

### 1. Interface e Experiência do Usuário (UI/UX)
- **Splash Screen:** Banner em arte Braille/ASCII exibido na inicialização para reforçar a identidade visual da OnlyGoes.
- **Navegação Fluida:** Transição de menus com limpeza automática de tela (`Clear-Host`) e captura de teclas instantânea via hardware (previsto para v1.2.0), eliminando a necessidade da tecla "Enter".
- **Feedback Visual:** Codificação por cores (Ciano: Títulos, Amarelo: Alertas, Verde: Sucesso, Vermelho: Erros).

### 2. Módulo de Preparação de Ambiente (`Invoke-Setup`)
- **Instalação Resiliente:** Uso do `winget` com flag `--force`. A detecção de presença do software ignora registros "sujos" do Windows e foca na existência física do executável `steam.exe`.
- **Validação de Login por PID:** O script não dispara o download do jogo apenas por detectar um usuário logado no registro. Ele valida se o `PID` (Process ID) gravado no registro pertence à instância da Steam que está rodando no momento, evitando falsos positivos de sessões antigas.
- **Monitoramento de Pastas:** Detecção em tempo real da estrutura `game/csgo/cfg`. O script libera o próximo passo assim que as pastas são criadas, permitindo o restauro de configs antes mesmo do término do download total do jogo.

### 3. Engenharia de PowerShell
- **Verbos Aprovados:** Funções renomeadas (ex: `Select-Conta`, `Read-VCFG`) para total compatibilidade com os padrões de desenvolvimento da Microsoft e ferramentas de linting (PSScriptAnalyzer).
- **Consolidação de Dados:** Extração inteligente que cruza dados da pasta `userdata` da Steam com os arquivos globais da instalação do jogo.

## 🚀 Automação e CI/CD
- **GitHub Actions:** Workflow (`release.yml`) que monitora Git Tags (`v*`).
- **Auto-Update:** O processo automatiza a alteração da variável `$VERSION` no código-fonte e atualiza o `CHANGELOG.md` sem intervenção manual, garantindo que o link de instalação pública (`irm`) sempre sirva a versão mais recente.

## 📌 Roadmap Curto Prazo
- Implementação de captura de tecla sem "Enter" para o menu principal.
- Refatoração final de variáveis para eliminação de alertas de "assigned but never used" no editor.

---
*Documento gerado para suporte ao desenvolvimento da OnlyGoes Informática e Tecnologia.*