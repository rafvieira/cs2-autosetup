# ============================================================
# EXTRATOR DE CONFIGURAÇÕES CS2 (AUTOEXEC GENERATOR)
# Objetivo: Coletar arquivos de configuração locais e da nuvem
# da Steam para gerar um 'autoexec.cfg' unificado na Área de Trabalho.
# Não altera arquivos do jogo, atua apenas em modo leitura.
# ============================================================

# ------------------------------------------------------------
# SEÇÃO 1: VARIÁVEIS ESTÁTICAS E CAMINHOS BASE
# Define as constantes do jogo. Centralizar isso aqui facilita 
# a manutenção caso a Valve mude o nome de alguma pasta no futuro.
# ------------------------------------------------------------
$APPID      = 730                                      # ID do CS2 na Steam
$APPNAME    = "cs2"                                    # Nome interno usado nos arquivos
$INSTALLDIR = "Counter-Strike Global Offensive"        # Nome da pasta raiz do jogo
$MOD        = "csgo"                                   # Subdiretório específico do mod
$GAMEBIN    = "bin\win64"                              # (Não utilizado no momento)
$USER_VCFG  = "${APPNAME}_user_convars_0_slot0.vcfg"   # Arquivo: Configurações de console do usuário
$KEYS_VCFG  = "${APPNAME}_user_keys_0_slot0.vcfg"      # Arquivo: Binds e teclas do usuário
$MACH_VCFG  = "${APPNAME}_machine_convars.vcfg"        # Arquivo: Configurações de vídeo/hardware da máquina
$VIDEO_TXT  = "${APPNAME}_video.txt"                   # Arquivo: Configurações gráficas avançadas (Source 2)

# ------------------------------------------------------------
# SEÇÃO 2: DETECÇÃO DA INSTALAÇÃO DA STEAM E DO JOGO
# Busca no Registro do Windows onde a Steam está instalada.
# Depois, lê o arquivo libraryfolders.vdf para encontrar em qual
# disco/biblioteca o CS2 está instalado (útil para quem tem jogos em discos diferentes, como C: e D:).
# ------------------------------------------------------------
$STEAM = Resolve-Path (Get-ItemPropertyValue "HKCU:\SOFTWARE\Valve\Steam" SteamPath)

# Filtra o arquivo de bibliotecas da Steam buscando caminhos de disco (ex: D:\SteamLibrary)
Get-Content "$STEAM\steamapps\libraryfolders.vdf" | ForEach-Object {$_ -split '"',5} | Where-Object {$_ -like '*:\*'} | ForEach-Object {
  $libPath = Resolve-Path $_
  $installPath = "$libPath\steamapps\common\$INSTALLDIR"
  
  # Se o arquivo steam.inf existir nessa pasta, confirmamos que o CS2 está aqui
  if (Test-Path "$installPath\game\$MOD\steam.inf") {
    $STEAMAPPS = "$libPath\steamapps"       # Caminho da pasta steamapps
    $GAMEROOT  = "$installPath\game"        # Raiz do executável do jogo
    $GAME      = "$installPath\game\$MOD"   # Pasta principal de dados (/game/csgo)
  }
}

# ------------------------------------------------------------
# SEÇÃO 3: IDENTIFICAÇÃO DO USUÁRIO (MENU INTERATIVO)
# Varre a pasta userdata da Steam, extrai o Nickname (PersonaName) 
# de cada conta encontrada e cria um menu para o usuário escolher.
# ------------------------------------------------------------
Push-Location "$STEAM\userdata"
$accountFolders = Get-ChildItem -Directory | Where-Object { $_.Name -match '^\d+$' } # Pega apenas pastas com números (SteamID)
$accountsList = @()
$contador = 1

# Monta a lista de contas lendo os arquivos locais da Steam
foreach ($folder in $accountFolders) {
    $configFile = "$($folder.FullName)\config\localconfig.vdf"
    $nickName = "Desconhecido"

    if (Test-Path $configFile) {
        # Busca a linha do arquivo VDF que contém o "PersonaName"
        $linhaNick = Get-Content $configFile -ErrorAction SilentlyContinue | Select-String -Pattern '"PersonaName"\s+"([^"]+)"'
        if ($linhaNick) {
            $nickName = $linhaNick.Matches.Groups[1].Value
        }
        
        # Adiciona a conta encontrada na nossa lista
        $accountsList += [PSCustomObject]@{
            Opcao   = $contador
            SteamID = $folder.Name
            Nick    = $nickName
            Caminho = $folder.FullName
        }
        $contador++
    }
}
Pop-Location

# Verifica se encontrou alguma conta antes de continuar
if ($accountsList.Count -eq 0) {
    Write-Host "ERRO: Nenhuma conta da Steam foi encontrada nesta maquina." -ForegroundColor Red
    Read-Host "Pressione ENTER para sair..."
    exit
}

# Cria o Loop do Menu Interativo
$contaEscolhida = $null
do {
    Clear-Host
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "   CONTAS STEAM DETECTADAS NESTA MAQUINA" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    
    foreach ($acc in $accountsList) {
        Write-Host " [ $($acc.Opcao) ] - Conta: $($acc.Nick) (ID: $($acc.SteamID))"
    }
    Write-Host "=============================================" -ForegroundColor Cyan
    
    [int]$escolha = Read-Host "Digite o numero da conta que deseja usar para o Autoexec"

    # Valida se a escolha existe na lista
    $contaEscolhida = $accountsList | Where-Object { $_.Opcao -eq $escolha }

    if (-not $contaEscolhida) {
        Write-Host "`nOpção invalida! Digite um numero listado acima." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
} until ($contaEscolhida)

Write-Host "`nConta selecionada: $($contaEscolhida.Nick)" -ForegroundColor Green
Start-Sleep -Seconds 1

# Alimenta as variáveis que o restante do script precisa
$USRCLOUD = $contaEscolhida.Caminho
$USRLOCAL = "$USRCLOUD\$APPID\local"
# ------------------------------------------------------------

# ------------------------------------------------------------
# SEÇÃO 4: OVERRIDE POR VARIÁVEL DE AMBIENTE (OPCIONAL)
# Permite forçar um caminho de configuração customizado caso a variável
# de ambiente do Windows 'USRLOCALCSGO' esteja definida.
# ------------------------------------------------------------
if ($env:USRLOCALCSGO -and (Test-Path "$env:USRLOCALCSGO\cfg\$MACH_VCFG")) {
  $USRLOCAL = "$env:USRLOCALCSGO"
}

# ------------------------------------------------------------
# SEÇÃO 5: PREPARAÇÃO DA PASTA TEMPORÁRIA (MERGE DE CONFIGS)
# O CS2 salva configs tanto na pasta do jogo quanto na pasta 'userdata'.
# O script cria uma pasta em %TEMP% e copia os arquivos de ambos os locais.
# A flag /XO (eXclude Older) do robocopy garante que, em caso de conflito, 
# apenas a versão mais recente do arquivo seja mantida.
# ------------------------------------------------------------
New-Item -ItemType Directory -Force -Path "$env:temp\cs2" -ErrorAction SilentlyContinue | Out-Null
robocopy "$GAME\cfg/" "$env:temp\cs2/" $USER_VCFG $KEYS_VCFG $MACH_VCFG $VIDEO_TXT /XO | Out-Null
robocopy "$USRLOCAL\cfg/" "$env:temp\cs2/" $USER_VCFG $KEYS_VCFG $MACH_VCFG $VIDEO_TXT /XO | Out-Null

# ------------------------------------------------------------
# SEÇÃO 6: GERAÇÃO DO AUTOEXEC - CONFIGURAÇÕES DE VÍDEO
# Lê o arquivo video.txt. Como configs de vídeo não podem ser
# aplicadas via console no CS2, o script apenas extrai os valores
# e os insere no autoexec como comentários (//) para referência do usuário.
# ------------------------------------------------------------
$autoexec = "$([Environment]::GetFolderPath('Desktop'))\autoexec.cfg"
Set-Content "$autoexec" "// Configurações extraidas de $VIDEO_TXT (Apenas para referência visual)" -Force

$video_txt = "$env:temp\cs2\$VIDEO_TXT"
$cfgBuffer = New-Object System.Text.StringBuilder(10000)
$videoFilter = 'default|screen|border|sync|quality|msaa|cmaa|videocfg|r_low'

if (Test-Path $video_txt) {
  Get-Content $video_txt | ForEach-Object {
    $lineTokens = $_ -split '"'
    # Se a linha tiver 5 partes ("chave" "valor") e bater com o filtro
    if ($lineTokens.count -eq 5 -and $_ -match $videoFilter) {
      $cleanKey = ($lineTokens[1] -replace 'setting.' -replace 'videocfg_').ToUpper()
      [void]$cfgBuffer.AppendLine('// ' + $cleanKey + ' ' + $lineTokens[3])
    }
  }
  if ($cfgBuffer.length -gt 0) { Add-Content -LiteralPath "$autoexec" -Value $cfgBuffer.ToString() }
}

# ------------------------------------------------------------
# SEÇÃO 7: GERAÇÃO DO AUTOEXEC - BINDS E TECLAS
# Extrai as binds do usuário. Converte o formato VDF ("tecla" "ação")
# para o comando de console padrão: bind "tecla" "ação";
# ------------------------------------------------------------
Add-Content "$autoexec" "`n// Configurações extraidas de $KEYS_VCFG" -Force
$keys_vcfg = "$env:temp\cs2\$KEYS_VCFG"
$cfgBuffer.Clear()

if (Test-Path $keys_vcfg) {
  Get-Content $keys_vcfg | ForEach-Object {
    $lineTokens = $_ -split '"'
    if ($lineTokens.count -eq 5) {
      [void]$cfgBuffer.AppendLine('bind "' + $lineTokens[1] + '" "' + $lineTokens[3] + '";')
    }
  }
  if ($cfgBuffer.length -gt 0) { Add-Content -LiteralPath "$autoexec" -Value $cfgBuffer.ToString() }
}

# ------------------------------------------------------------
# SEÇÃO 8: GERAÇÃO DO AUTOEXEC - CONFIGURAÇÕES DO USUÁRIO (CONVARS)
# Converte variáveis de jogo do jogador (como sensibilidade, mira, HUD)
# para o formato do autoexec: "comando" "valor";
# ------------------------------------------------------------
Add-Content "$autoexec" "`n// Configurações extraidas de $USER_VCFG" -Force
$user_vcfg = "$env:temp\cs2\$USER_VCFG"
$cfgBuffer.Clear()

if (Test-Path $user_vcfg) {
  Get-Content $user_vcfg | ForEach-Object {
    $lineTokens = $_ -split '"'
    if ($lineTokens.count -eq 5) {
      [void]$cfgBuffer.AppendLine('"' + $lineTokens[1] + '" "' + $lineTokens[3] + '";')
    }
  }
  if ($cfgBuffer.length -gt 0) { Add-Content -LiteralPath "$autoexec" -Value $cfgBuffer.ToString() }
}

# ------------------------------------------------------------
# SEÇÃO 9: GERAÇÃO DO AUTOEXEC - CONFIGURAÇÕES DA MÁQUINA
# Extrai configurações de hardware (resolução, áudio, etc.).
# Remove os sufixos (ex: convar$id) deixando apenas o comando limpo.
# ------------------------------------------------------------
Add-Content "$autoexec" "`n// Configurações extraidas de $MACH_VCFG" -Force
$machine_vcfg = "$env:temp\cs2\$MACH_VCFG"
$cfgBuffer.Clear()

if (Test-Path $machine_vcfg) {
  Get-Content $machine_vcfg | ForEach-Object {
    $lineTokens = $_ -split '"'
    if ($lineTokens.count -eq 5) {
      [void]$cfgBuffer.AppendLine('"' + $lineTokens[1].Split('$')[0] + '" "' + $lineTokens[3] + '";')
    }
  }
  if ($cfgBuffer.length -gt 0) { Add-Content -LiteralPath "$autoexec" -Value $cfgBuffer.ToString() }
}

# ------------------------------------------------------------
# SEÇÃO 10: FEEDBACK VISUAL E FINALIZAÇÃO
# Imprime os caminhos encontrados no console para validação e
# pausa a tela antes de fechar o PowerShell.
# ------------------------------------------------------------
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " DADOS DA NUVEM (USER)   = $USRLOCAL" -ForegroundColor Cyan
Write-Host " DADOS DA STEAM (GLOBAL) = $USRCLOUD" -ForegroundColor Cyan
Write-Host " DADOS DO JOGO (LOCAL)   = $GAME\cfg" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Sucesso: O arquivo autoexec.cfg foi gerado na sua Area de Trabalho. " -ForegroundColor Green
Write-Host ""
Read-Host "Pressione ENTER para sair..."