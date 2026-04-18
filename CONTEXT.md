# OnlyGoes CS2 AutoConfig Tool - Contexto Técnico

## Visão Geral
Ferramenta de automação para backup, restauração e preparação de ambiente do Counter-Strike 2. O foco principal é a portabilidade de configurações entre máquinas e contas.

## Estado Atual (v1.2.7.1)
- **Container .og**: Implementação de um formato de arquivo proprietário (`.og`) que serializa dados de `autoexec.cfg` e `cs2_video.txt` em um único volume.
- **Lógica de Backend (SteamID)**: Os arquivos físicos de backup são nomeados via SteamID numérico para garantir compatibilidade com o sistema de arquivos do Windows (evitando caracteres proibidos em nicknames).
- **Lógica de Frontend (Nicknames)**: O script realiza um "pre-flight check" nos arquivos `.og` para extrair e exibir nomes amigáveis no menu de restauração.

## Decisões de Arquitetura
1. **Ataque Rápido**: Restauração focada no diretório `userdata` da Steam, garantindo que as configurações de perfil (soberanas) sejam aplicadas mesmo antes do término do download dos arquivos globais do jogo.
2. **Sanitização**: Uso de `LiteralPath` e `UTF8` em todas as operações de I/O para preservar a integridade dos arquivos originais da Valve.
3. **Persistência**: Inclusão mandatória do comando `host_writeconfig` no fim do fluxo de extração para forçar a sincronização local.

## Próximos Passos
- Monitoramento de feedback de usuários reais sobre a restauração de vídeo em hardwares diferentes.
- Refinamento do pipeline de CI/CD (Bot Zed) para maior silêncio no histórico de commits.