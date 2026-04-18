# Changelog - CS2 ACT (Autoconfig Tool)

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

## [1.1.0] - 2026-04-17
### Adicionado
- **Menu Unificado:** Consolidação dos scripts de Extração, Restauração e Setup em um único executável (`og_cs2_tool.ps1`).
- **Logica de Reinstalação:** Adicionada verificação física de `steam.exe` e flag `--force` no Winget para garantir a instalação em ambientes com registros corrompidos.
- **Tratamento de Erros:** Implementação de blocos `try/catch` para o protocolo `steam://` e validação de permissões de Administrador.

### Modificado
- **Reordenação de UX:** O menu agora prioriza o fluxo de jogo (Extrair/Restaurar) antes do Setup técnico.
- **Refatoração de Código:** Renomeação de funções para seguir os verbos aprovados do PowerShell (`Select-Conta`, `Read-VCFG`).
- **Estilo Visual:** Padronização de cores (Ciano, Amarelo, Verde e Vermelho) para melhor feedback visual no terminal.

## [1.0.0] - 2026-04-15
### Adicionado
- Versão inicial com scripts modulares separados para extração de configurações de vídeo e binds.