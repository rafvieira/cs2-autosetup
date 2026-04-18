# ============================================================
# ONLYGOES INFORMÁTICA E TECNOLOGIA - CS2 ACT (Autoconfig Tool)
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$VERSION = "1.2.2" # [AUTO-UPDATE-VERSION]

# --- CONFIGURAÇÕES ESTÁTICAS ---
$APPID      = 730
$APPNAME    = "cs2"
$INSTALLDIR = "Counter-Strike Global Offensive"
$MOD        = "csgo"
$USER_VCFG  = "${APPNAME}_user_convars_0_slot0.vcfg"
$KEYS_VCFG  = "${APPNAME}_user_keys_0_slot0.vcfg"
$MACH_VCFG  = "${APPNAME}_machine_convars.vcfg"
$VIDEO_TXT  = "${APPNAME}_video.txt"

# --- FUNÇÃO DE INTRODUÇÃO (SPLASH SCREEN) ---
function Show-Intro {
    Clear-Host
    $Art = @"
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⣶⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣸⣿⣿⡟⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⡿⣿⡿⠛⠛⠋⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣸⣿⣿⣿⣿⣿⣿⣿⣷⣿⠃⠀⠀⠀⠀⠀⠀⠀
⢠⣶⣶⣶⣶⣶⣶⡄⠀⢸⣿⣿⣿⣿⣿⣿⣧⠙⠛⠉ ⢠⣶⣶⣶⣶⣶⣶⡄
⢸⣿⣿⠛⠛⠛⠛⠃⠀⠐⣿⣿⣿⣿⣿⣿⡟⠀⠀  ⢸⣿⡿⠛⠛⠛⠛⠃
⢸⣿⣿⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀ ⢸⣿⣿⣶⣶⣶⣶⡆
⢸⣿⣿⠀⠀⠀⠀⠀⠀⢸⣿⣿⡿⢿⣿⣿⣿⡀⠀⠀ ⠈⠛⠛⠛⠛⣿⣿⡇
⢸⣿⣿⣿⣿⣿⣿⡇⠀⢸⣿⣿⠁⠀⠘⢿⣿⣷⠀⠀⢸⣿⣿⣿⣿⣿⣿⡇
⠈⠉⠉⠉⠉⠉⠉⠁⢠⣿⡟⠁⠀⠀⠀⢠⣿⣿⠀⠀⠈⠉⠉⠉⠉⠉⠉⠁
⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⠃⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⣿⠉⠀⠀⠀⠀⠀⠀⣹⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠸⠿⠀⠀⠀⠀⠀⠀⠀⠛⠛⠛⠃
"@
    Write-Host "`n$Art" -ForegroundColor Yellow
    Write-Host "`nINICIALIZANDO CS2 AutoConfig Tool v$VERSION..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
}

function Show-MenuHeader {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "      ONLYGOES - CS2 ACT v$VERSION" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
}

# --- FUNÇÕES DE SUPORTE ---

function Get-ContasSteam {
    $SteamRegPath = "HKCU:\SOFTWARE\Valve\Steam"
    if (-not (Test-Path $SteamRegPath)) { return $null }
    $SteamPath = (Get-ItemPropertyValue $SteamRegPath SteamPath)
    $Contas = @()
    if (Test-Path "$SteamPath\userdata") {
        Push-Location "$SteamPath\userdata"
        Get-ChildItem -Directory | Where-Object { $_.Name -match '^\d+$' } | ForEach-Object {
            $conf = "$($_.FullName)\config\localconfig.vdf"
            $nick = "Desconhecido"
            if (Test-Path $conf) {
                $match = Get-Content $conf -ErrorAction SilentlyContinue | Select-String -Pattern '"PersonaName"\s+"([^"]+)"'
                if ($match) { $nick = $match.Matches.Groups[1].Value }
            }
            $Contas += [PSCustomObject]@{ ID = $_.Name; Nick = $nick; Path = $_.FullName }
        }
        Pop-Location
    }
    return $Contas
}

function Select-Conta {
    $Contas = Get-ContasSteam
    if (-not $Contas -or $Contas.Count -eq 0) { 
        Write-Host "`n[ ERRO ] Nenhuma conta encontrada. Retornando em 3s..." -ForegroundColor Red
        Start-Sleep -Seconds 3
        return $null 
    }
    Write-Host "`n=============================================" -ForegroundColor Cyan
    Write-Host " SELECIONE A CONTA" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    for ($i=0; $i -lt $Contas.Count; $i++) { 
        Write-Host " [ $($i+1) ] - $($Contas[$i].Nick) ($($Contas[$i].ID))" 
    }
    
    $sel = Read-Host "`nDigite o número da conta"
    if ($sel -match '^\d+$' -and $sel -gt 0 -and $sel -le $Contas.Count) { 
        return $Contas[[int]$sel-1] 
    }
    
    Write-Host "`n[ ERRO ] Opção inválida! Voltando ao menu..." -ForegroundColor Red
    Start-Sleep -Seconds 3
    return $null
}

# --- MÓDULOS PRINCIPAIS ---

function Invoke-Setup {
    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin) { 
        Write-Host "`n[ ERRO ] Requer privilégios de Administrador." -ForegroundColor Red
        Start-Sleep -Seconds 3
        return 
    }
    
    $SteamReg  = "HKCU:\SOFTWARE\Valve\Steam"
    $ActiveReg = "HKCU:\Software\Valve\Steam\ActiveProcess"
    $PathNoRegistro = (Get-ItemPropertyValue $SteamReg SteamPath -ErrorAction SilentlyContinue)
    $SteamExe = if ($PathNoRegistro) { Join-Path $PathNoRegistro "steam.exe" } else { $null }

    if (-not (Test-Path $SteamReg) -or -not (Test-Path $SteamExe)) {
        Write-Host "`n[ SETUP ] Steam não encontrada. Instalando..." -ForegroundColor Cyan
        winget install --id Valve.Steam -e --source winget --silent --accept-source-agreements --accept-package-agreements --force
        $PathNoRegistro = (Get-ItemPropertyValue $SteamReg SteamPath -ErrorAction SilentlyContinue)
        $SteamExe = Join-Path $PathNoRegistro "steam.exe"
    }

    Write-Host "`n[ !!! ] Aguardando login na Steam..." -ForegroundColor Yellow
    if (-not (Get-Process "steam" -ErrorAction SilentlyContinue)) { Start-Process $SteamExe }

    Write-Host "Status: Sincronizando" -NoNewline
    while ($true) {
        $RegPID     = (Get-ItemPropertyValue $ActiveReg pid -ErrorAction SilentlyContinue)
        $ActiveUser = (Get-ItemPropertyValue $ActiveReg ActiveUser -ErrorAction SilentlyContinue)
        $ActualPIDs = (Get-Process "steam" -ErrorAction SilentlyContinue).Id

        if ($ActualPIDs -contains $RegPID -and $ActiveUser -and $ActiveUser -ne 0) { 
            Write-Host " [ CONECTADO ]" -ForegroundColor Green
            break 
        }
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 2
    }

    try {
        Write-Host "`n[ !!! ] Disparando comando de instalação..." -ForegroundColor Yellow
        Start-Process "steam://install/730" -ErrorAction Stop
    } catch {
        Write-Host "`n[ ERRO ] Falha no protocolo. Retornando..." -ForegroundColor Red
        Start-Sleep -Seconds 3
        return
    }
    
    Write-Host "`nMonitorando criação das pastas..." -ForegroundColor Cyan
    $Concluido = $false
    while (-not $Concluido) {
        $CurrentSteamP = (Get-ItemPropertyValue $SteamReg SteamPath -ErrorAction SilentlyContinue)
        $Libs = @($CurrentSteamP) # Começa com a pasta padrão
        
        # Busca bibliotecas extras de forma robusta
        $VdfPath = Join-Path $CurrentSteamP "steamapps\libraryfolders.vdf"
        if (Test-Path $VdfPath) {
            $VdfContent = Get-Content $VdfPath
            foreach ($line in $VdfContent) {
                if ($line -match '"path"\s+"([^"]+)"') {
                    $CleanPath = $matches[1] -replace '\\\\', '\'
                    if ($CleanPath -ne $CurrentSteamP) { $Libs += $CleanPath }
                }
            }
        }

        foreach ($L in $Libs) { 
            $PathCommon = Join-Path $L "steamapps\common\$INSTALLDIR\game\$MOD\cfg"
            $PathDown   = Join-Path $L "steamapps\downloading\$APPID\game\$MOD\cfg"

            # DEBUG: Remova o '#' abaixo se quiser ver exatamente onde ele procura
            # Write-Host "`n[ DEBUG ] Tentando: $PathDown" -ForegroundColor Gray

            if ((Test-Path $PathCommon) -or (Test-Path $PathDown)) { 
    $Concluido = $true
    break 
} 
        }
        
        if (-not $Concluido) { Write-Host "." -NoNewline; Start-Sleep -Seconds 3 }
    }
    Write-Host "`n[ OK ] Estrutura detectada!" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

function Invoke-Extract {
    $Conta = Select-Conta
    if (-not $Conta) { return }
    $SteamPath = (Get-ItemPropertyValue "HKCU:\SOFTWARE\Valve\Steam" SteamPath)
    $USRLOCAL = "$($Conta.Path)\$APPID\local"
    $autoexec = "$([Environment]::GetFolderPath('Desktop'))\autoexec.cfg"
    $GamePath = $null
    $Libs = Get-Content "$SteamPath\steamapps\libraryfolders.vdf" -ErrorAction SilentlyContinue | Where-Object {$_ -like '*:\*'} | ForEach-Object { (Resolve-Path ($_ -split '"',5)[3]).Path }
    foreach ($L in $Libs) { if (Test-Path "$L\steamapps\common\$INSTALLDIR\game\$MOD") { $GamePath = "$L\steamapps\common\$INSTALLDIR\game\$MOD"; break } }

    $tempDir = "$env:temp\cs2_extract"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    if ($GamePath) { robocopy "$GamePath\cfg/" "$tempDir/" $USER_VCFG $KEYS_VCFG $MACH_VCFG $VIDEO_TXT /XO | Out-Null }
    if (Test-Path "$USRLOCAL\cfg") { robocopy "$USRLOCAL\cfg/" "$tempDir/" $USER_VCFG $KEYS_VCFG $MACH_VCFG $VIDEO_TXT /XO | Out-Null }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("// OnlyGoes Autoexec - Conta: $($Conta.Nick)")
    
    function Read-VCFG($file, $header, $prefix = "") {
        if (Test-Path $file) {
            [void]$sb.AppendLine("`n// $header")
            Get-Content $file | ForEach-Object {
                $parts = $_ -split '"'
                if ($parts.Count -eq 5) {
                    $key = $parts[1]; $val = $parts[3]
                    if ($prefix -eq "bind") { [void]$sb.AppendLine("bind `"$key`" `"$val`";") }
                    else { [void]$sb.AppendLine("`"$($key.Split('$')[0])`" `"$val`";") }
                }
            }
        }
    }
    Read-VCFG "$tempDir\$KEYS_VCFG" "BINDS" "bind"
    Read-VCFG "$tempDir\$USER_VCFG" "USER CONVARS"
    Read-VCFG "$tempDir\$MACH_VCFG" "MACHINE SETTINGS"
    $sb.ToString() | Set-Content $autoexec -Force
    Write-Host "`n[ OK ] Autoexec gerado no Desktop!" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Invoke-Restore {
    $Autoexec = "$([Environment]::GetFolderPath('Desktop'))\autoexec.cfg"
    if (-not (Test-Path $Autoexec)) { 
        Write-Host "`n[ ERRO ] autoexec.cfg não encontrado no Desktop!" -ForegroundColor Red
        Start-Sleep -Seconds 3
        return 
    }
    $Conta = Select-Conta
    if (-not $Conta) { return }

    $SteamReg = "HKCU:\SOFTWARE\Valve\Steam"
    $SteamPath = (Get-ItemPropertyValue $SteamReg SteamPath)
    $DestinoConta = "$($Conta.Path)\$APPID\local\cfg"
    
    # Lista de bibliotecas para o Restore
    $Libs = @($SteamPath)
    $VdfPath = Join-Path $SteamPath "steamapps\libraryfolders.vdf"
    if (Test-Path $VdfPath) {
        $VdfContent = Get-Content $VdfPath
        foreach ($line in $VdfContent) {
            if ($line -match '"path"\s+"([^"]+)"') {
                $CleanPath = $matches[1] -replace '\\\\', '\'
                if ($CleanPath -ne $SteamPath) { $Libs += $CleanPath }
            }
        }
    }
    
    $GlobalCfg = $null
    foreach ($L in $Libs) {
        $PathCommon = Join-Path $L "steamapps\common\$INSTALLDIR\game\$MOD\cfg"
        $PathDown   = Join-Path $L "steamapps\downloading\$APPID\game\$MOD\cfg"
        
        if (Test-Path $PathCommon) { $GlobalCfg = $PathCommon; break }
        if (Test-Path $PathDown)   { $GlobalCfg = $PathDown; break }
    }

    # 1. Aplica na pasta da conta (Safe)
    if (-not (Test-Path $DestinoConta)) { New-Item -ItemType Directory -Force -Path $DestinoConta | Out-Null }
    Copy-Item -Path $Autoexec -Destination "$DestinoConta\autoexec.cfg" -Force
    
    # 2. Aplica na pasta do jogo (Ninja Mode)
    if ($GlobalCfg) {
        if (-not (Test-Path $GlobalCfg)) { New-Item -ItemType Directory -Force -Path $GlobalCfg | Out-Null }
        Copy-Item -Path $Autoexec -Destination "$GlobalCfg\autoexec.cfg" -Force
        Write-Host "`n[ OK ] Aplicado em: $GlobalCfg" -ForegroundColor Gray
    }

    Write-Host "`n[ OK ] Configurações aplicadas para $($Conta.Nick)!" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# --- INÍCIO DA EXECUÇÃO ---
Show-Intro

do {
    Show-MenuHeader
    Write-Host " [ 1 ] Extrair configurações (Desktop)"
    Write-Host " [ 2 ] Restaurar configurações (Steam)"
    Write-Host " [ 3 ] Preparar ambiente (Instalação)"
    Write-Host " [ 0 ] Sair"
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Escolha uma opção: " -NoNewline

    $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $Op = $Key.Character
    Write-Host $Op

    switch ($Op) {
        '1' { Invoke-Extract }
        '2' { Invoke-Restore }
        '3' { Invoke-Setup }
        '0' { 
            Clear-Host
            Write-Host "`nObrigado por usar as ferramentas OnlyGoes!" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            Stop-Process -Id $PID 
        }
        default { 
            if ($Op -ne "`r" -and $Op -ne "`n") { 
                Write-Host "`n`n[ ! ] Opção '$Op' inválida." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    }
} until ($Op -eq '0')