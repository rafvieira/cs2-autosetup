# ============================================================
# ONLYGOES INFORMÁTICA E TECNOLOGIA - CS2 ACT (Autoconfig Tool)
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$VERSION = "1.2.7" # [AUTO-UPDATE-VERSION]

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
    
    Write-Host "`nDigite o número da conta: " -NoNewline
    $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $sel = $Key.Character
    Write-Host $sel

    if ($sel -match '^[1-9]$') {
        $idx = [int][string]$sel - 1
        if ($idx -lt $Contas.Count) { return $Contas[$idx] }
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
        Write-Host "`n[ OK ] Instalação iniciada! O Bot Zed já preparou o terreno." -ForegroundColor Green
        Write-Host "[ INFO ] Você já pode usar a Opção 2 para restaurar as configs." -ForegroundColor Cyan
        Start-Sleep -Seconds 5
    } catch {
        Write-Host "`n[ ERRO ] Falha no protocolo. Retornando..." -ForegroundColor Red
        Start-Sleep -Seconds 3
    }
}

function Invoke-Extract {
    $Conta = Select-Conta
    if (-not $Conta) { return }
    $SteamPath = (Get-ItemPropertyValue "HKCU:\SOFTWARE\Valve\Steam" SteamPath)
    $USRLOCAL = "$($Conta.Path)\$APPID\local"
    $DesktopPath = [Environment]::GetFolderPath('Desktop')
    
    # v1.2.7: Nome do arquivo agora usa o SteamID para evitar erro com colchetes []
    $OutputFile = Join-Path $DesktopPath "BKP_CFG_$($Conta.ID).og"
    
    $GamePath = $null
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
    foreach ($L in $Libs) { 
        $CheckPath = Join-Path $L "steamapps\common\$INSTALLDIR\game\$MOD"
        if (Test-Path $CheckPath) { $GamePath = $CheckPath; break } 
    }

    $tempDir = "$env:temp\cs2_extract"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    if ($GamePath) { robocopy "$GamePath\cfg/" "$tempDir/" $USER_VCFG $KEYS_VCFG $MACH_VCFG $VIDEO_TXT /XO | Out-Null }
    if (Test-Path "$USRLOCAL\cfg") { robocopy "$USRLOCAL\cfg/" "$tempDir/" $USER_VCFG $KEYS_VCFG $MACH_VCFG $VIDEO_TXT /XO | Out-Null }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("// OG_BACKUP_VERSION: $VERSION")
    [void]$sb.AppendLine("// OnlyGoes Autoexec - Conta: $($Conta.Nick)") # Mantemos o Nick aqui para o menu de Restore
    
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
    [void]$sb.AppendLine("`nhost_writeconfig")
    [void]$sb.AppendLine("---ONLYGOES-AUTOEXEC-END---")

    [void]$sb.AppendLine("---ONLYGOES-VIDEO-START---")
    $VideoFile = "$tempDir\$VIDEO_TXT"
    if (Test-Path $VideoFile) {
        $VideoContent = Get-Content -Path $VideoFile -Raw -Encoding UTF8
        [void]$sb.Append($VideoContent)
    }
    [void]$sb.AppendLine("`n---ONLYGOES-VIDEO-END---")

    # Gravando com LiteralPath para máxima segurança contra caracteres especiais
    $sb.ToString() | Out-File -LiteralPath $OutputFile -Encoding UTF8 -Force
    
    Write-Host "`n[ OK ] Extraído de: $($Conta.Nick)" -ForegroundColor Cyan
    Write-Host "autoexec.cfg gerado com sucesso, salvo na área de trabalho." -ForegroundColor Green
    Start-Sleep -Seconds 4
}

function Invoke-Restore {
    $DesktopPath = [Environment]::GetFolderPath('Desktop')
    $Backups = Get-ChildItem -Path $DesktopPath -Filter "*.og"
    
    if (-not $Backups) {
        Write-Host "`n[ ERRO ] Nenhum arquivo .og encontrado na área de trabalho!" -ForegroundColor Red
        Start-Sleep -Seconds 3
        return 
    }

    $SelectedBkp = $null
    
    # v1.2.7: Mapeamento de backups para exibir Nicks amigáveis em vez de IDs numéricos
    $BackupMap = @()
    foreach ($file in $Backups) {
        # Lê a segunda linha para pegar o nickname que salvamos na extração
        $HeaderLine = Get-Content -LiteralPath $file.FullName -TotalCount 2 | Select-Object -Last 1
        $NickInFile = "Desconhecido"
        if ($HeaderLine -match 'Conta: (.*)') { $NickInFile = $matches[1] }
        
        $BackupMap += [PSCustomObject]@{
            File = $file
            Nick = $NickInFile
        }
    }

    if ($BackupMap.Count -eq 1) {
        $SelectedBkp = $BackupMap[0].File
    } else {
        Write-Host "`n=============================================" -ForegroundColor Cyan
        Write-Host " SELECIONE O BACKUP (.og)" -ForegroundColor Yellow
        Write-Host "=============================================" -ForegroundColor Cyan
        for ($i=0; $i -lt $BackupMap.Count; $i++) { 
            Write-Host " [ $($i+1) ] - $($BackupMap[$i].Nick) ($($BackupMap[$i].File.Name))" 
        }
        Write-Host "`nEscolha o backup: " -NoNewline
        $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $selB = $Key.Character
        Write-Host $selB
        if ($selB -match '^[1-9]$') {
            $idxB = [int][string]$selB - 1
            if ($idxB -lt $BackupMap.Count) { $SelectedBkp = $BackupMap[$idxB].File }
        }
    }

    if (-not $SelectedBkp) { return }

    $ActiveReg = "HKCU:\Software\Valve\Steam\ActiveProcess"
    $SteamID = (Get-ItemPropertyValue $ActiveReg ActiveUser -ErrorAction SilentlyContinue)
    if (-not $SteamID -or $SteamID -eq 0) {
        $Conta = Select-Conta
        if (-not $Conta) { return }; $SteamID = $Conta.ID
    }

    $SteamReg = "HKCU:\SOFTWARE\Valve\Steam"
    $SteamPath = (Get-ItemPropertyValue $SteamReg SteamPath)
    $Destino = Join-Path $SteamPath "userdata\$SteamID\$APPID\local\cfg"
    if (-not (Test-Path $Destino)) { New-Item -ItemType Directory -Force -Path $Destino | Out-Null }

    Write-Host "`n[ ATAQUE RÁPIDO ] Plantando configs no perfil do usuário $SteamID..." -ForegroundColor Cyan
    $RawData = Get-Content -LiteralPath $SelectedBkp.FullName -Raw -Encoding UTF8
    
    $AutoContent = ($RawData -split "---ONLYGOES-AUTOEXEC-END---")[0]
    $AutoContent | Out-File -LiteralPath (Join-Path $Destino "autoexec.cfg") -Encoding UTF8 -Force
    
    if ($RawData -match "---ONLYGOES-VIDEO-START---") {
        $VideoPart = ($RawData -split "---ONLYGOES-VIDEO-START---")[1]
        $VideoContent = ($VideoPart -split "---ONLYGOES-VIDEO-END---")[0].Trim()
        $VideoContent | Out-File -LiteralPath (Join-Path $Destino $VIDEO_TXT) -Encoding UTF8 -Force
        Write-Host "[ OK ] Configurações de vídeo restauradas!" -ForegroundColor Green
    }

    Write-Host "[ OK ] Configuração plantada no perfil!" -ForegroundColor Green
    Write-Host "`n[ SUCESSO ] “Configs aplicadas. Go, go, go!”" -ForegroundColor Green
    Start-Sleep -Seconds 5
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
            Write-Host "`nEasy Peasy Lemon Squeezy 🍋" -ForegroundColor Green
            Start-Sleep -Seconds 2
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