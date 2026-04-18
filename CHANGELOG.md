# Changelog - CS2 ACT (Autoconfig Tool)

## [1.2.7.1] - 2026-04-18
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- ux: hotfix nas mensagens de extração e atualização do contexto v1.2.7.1
- chore: v1.2.7 liberada pelo Bot Zed [skip ci]


## [1.2.7] - 2026-04-18
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- feat: suporte a nicknames com caracteres especiais e menu de restore amigável v1.2.7
- chore: v1.2.6.1 liberada pelo Bot Zed [skip ci]


## [1.2.6.1] - 2026-04-18
- hotfix: correção de encoding no transporte de dados v1.2.6.1
- chore: v1.2.6 liberada pelo Bot Zed [skip ci]


## [1.2.6] - 2026-04-18
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- feat: container .og e restauração completa de vídeo v1.2.6
- chore: v1.2.5 liberada pelo Bot Zed [skip ci]


## [1.2.5] - 2026-04-18
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- ux: ajustes nos textos das funções, melhorias diversas na interface v1.2.5
- chore: v1.2.4 liberada pelo Bot Zed [skip ci]


## [1.2.4] - 2026-04-18
- ux: aumenta tempo de exibição da confirmação de restore v1.2.4
- chore: v1.2.3 liberada pelo Bot Zed [skip ci]


## [1.2.3] - 2026-04-18
- feat: implementação da lógica de Ataque Rápido v1.2.3
- chore: v1.2.2 liberada pelo Bot Zed [skip ci]


## [1.2.2] - 2026-04-18
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- fix: corrige erro de sintaxe no Test-Path (parênteses faltando)
- chore: v1.2.2 liberada pelo Bot Zed [skip ci]
- fix: monitoramento e restauro hibrido  (common/downloading)
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- chore: v1.2.1 liberada pelo Bot Zed [skip ci]


## [1.2.2] - 2026-04-18
- fix: monitoramento e restauro hibrido  (common/downloading)
- Merge branch 'main' of https://github.com/rafvieira/cs2-autosetup
- chore: v1.2.1 liberada pelo Bot Zed [skip ci]


## [1.2.1] - 2026-04-18
- chore: v1.2.0 liberada pelo Bot Zed [skip ci]


## [1.2.0] - 2026-04-18
- ci: permissões de escrita e batismo do Bot Zed
- feat: v1.2.0 - Menu instantâneo, correção de variáveis e workflow inteligente
- fix: consolida script v1.2.0 e resolve erro de sintaxe
- ci: corrige erro de detached HEAD no push do robo
- ui: menu instantâneo com ReadKey
- docs: limpeza e organização manual do changelog
- chore: bump version to 1.2.0 [skip ci]
- feat: v1.2.0 - Menu instantâneo, correção de variáveis e CONTEXT.md
- chore: bump version to 1.1.9 [skip ci]


Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [1.2.0] - 2026-04-18
### Adicionado
- **Menu Instantâneo:** Implementação de captura de tecla via hardware (`ReadKey`), eliminando a necessidade de apertar "Enter" no menu principal.
- **Documentação de Contexto:** Adicionado o arquivo `CONTEXT.md` para guiar futuros desenvolvimentos e explicar decisões de engenharia.
- **Refatoração de Variáveis:** Limpeza de avisos de linter e otimização do uso da variável `$ActiveReg`.

## [1.1.9] - 2026-04-18
### Modificado
- **Monitoramento Eager:** O script agora libera o restauro de configurações assim que a pasta `cfg` é detectada, sem esperar o fim do download de 30GB+.
- **UX Flow:** Remoção de pausas manuais desnecessárias para um fluxo mais contínuo.

## [1.1.7] - 2026-04-18
### Adicionado
- **Splash Screen:** Tela de introdução (Intro) de 3 segundos com a identidade visual OnlyGoes.
- **Limpeza de Tela:** Implementação de `Clear-Host` sistemático para manter o menu sempre limpo após cada ação.

## [1.1.6] - 2026-04-18
### Adicionado
- **Identidade Visual:** Inclusão do banner em arte Braille/ASCII alinhado.
- **Auto-Close:** Comando `Stop-Process` para encerrar o terminal completamente ao sair da ferramenta.

## [1.1.3] - 2026-04-18
### Corrigido
- **Deteção de Login:** Implementação de validação por PID (Process ID) para evitar falsos positivos de sessões antigas da Steam no registro do Windows.

## [1.1.1] - 2026-04-17
### Corrigido
- **Lógica de Setup:** Adicionada verificação física do executável `steam.exe` para forçar a reinstalação via Winget mesmo com registros corrompidos.

## [1.1.0] - 2026-04-17
### Adicionado
- **Menu Unificado:** Consolidação dos scripts de Extração, Restauração e Setup em um único executável.
- **Tratamento de Erros:** Implementação de blocos `try/catch` para o protocolo `steam://`.

## [1.0.0] - 2026-04-17
### Adicionado
- Versão inicial com scripts modulares separados.
