# ============================================================
# ONLYGOES INFORMÁTICA E TECNOLOGIA - CS2 ACT (Autoconfig Tool)
# Versão: 1.1.1 | Data: 17/04/2026
# ============================================================
$VERSION = "1.1.1" # [AUTO-UPDATE-VERSION]

# --- CONFIGURAÇÕES ESTÁTICAS ---
$APPID      = 730
$APPNAME    = "cs2"
$INSTALLDIR = "Counter-Strike Global Offensive"
$MOD        = "csgo"
$USER_VCFG  = "${APPNAME}_user_convars_0_slot0.vcfg"
$KEYS_VCFG  = "${APPNAME}_user_keys_0_slot0.vcfg"
$MACH_VCFG  = "${APPNAME}_machine_convars.vcfg"
$VIDEO_TXT  = "${APPNAME}_video.txt"

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
        Write-Host "`n[ ERRO ] Nenhuma conta da Steam com dados locais foi encontrada." -ForegroundColor Red
        Read-Host "Pressione ENTER para voltar ao menu principal..."
        return $null 
    }
    Write-Host "`n=============================================" -ForegroundColor Cyan
    Write-Host " SELECIONE A CONTA" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    for ($i=0; $i -lt $Contas.Count; $i++) { Write-Host " [ $($i+1) ] - $($Contas[$i].Nick) ($($Contas[$i].ID))" }
    $sel = Read-Host "`nDigite o número da conta"
    if ($sel -match '^\d+$' -and $sel -gt 0 -and $sel -le $Contas.Count) { return $Contas[[int]$sel-1] }
    Write-Host "`n[ ERRO ] Opção inválida!" -ForegroundColor Red
    Read-Host "Pressione ENTER para tentar novamente..."
    return $null
}

# --- MÓDULOS PRINCIPAIS ---

function Invoke-Setup {
    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $IsAdmin) { 
        Write-Host "`n[ ERRO ] O CS2 ACT precisa de privilégios de Administrador para esta opção." -ForegroundColor Red
        Read-Host "Pressione ENTER para voltar..."
        return 
    }
    
    $SteamReg = "HKCU:\SOFTWARE\Valve\Steam"
    $PathNoRegistro = (Get-ItemPropertyValue $SteamReg SteamPath -ErrorAction SilentlyContinue)
    $SteamExe = if ($PathNoRegistro) { Join-Path $PathNoRegistro "steam.exe" } else { $null }

    if (-not (Test-Path $SteamReg) -or -not (Test-Path $SteamExe)) {
        Write-Host "`n[ SETUP ] Steam não encontrada ou incompleta. Instalando via Winget..." -ForegroundColor Cyan
        winget install --id Valve.Steam -e --source winget --silent --accept-source-agreements --accept-package-agreements --force
        Write-Host "Aguardando inicialização do sistema..." -NoNewline
        for ($i=0; $i -lt 5; $i++) { Write-Host "." -NoNewline; Start-Sleep -Seconds 1 }
    } else {
        Write-Host "`n[ OK ] Steam detectada em: $PathNoRegistro" -ForegroundColor Green
    }

    try {
        Write-Host "`n[ !!! ] Disparando instalação do CS2 via Steam..." -ForegroundColor Yellow
        Start-Process "steam://install/730" -ErrorAction Stop
        Read-Host "`nPressione ENTER apenas quando o download do CS2 aparecer na Steam"
    } catch {
        Write-Host "`n[ ERRO ] Falha ao iniciar protocolo Steam." -ForegroundColor Red
        Read-Host "Pressione ENTER para voltar..."
        return
    }
    
    Write-Host "Monitorando estrutura de pastas do jogo..." -ForegroundColor Cyan
    $Concluido = $false
    while (-not $Concluido) {
        $CurrentSteamP = (Get-ItemPropertyValue $SteamReg SteamPath -ErrorAction SilentlyContinue)
        if ($CurrentSteamP -and (Test-Path "$CurrentSteamP\steamapps\libraryfolders.vdf")) {
            $Libs = Get-Content "$CurrentSteamP\steamapps\libraryfolders.vdf" | Where-Object {$_ -like '*:\*'} | ForEach-Object { (Resolve-Path ($_ -split '"',5)[3]).Path }
            foreach ($L in $Libs) { 
                if (Test-Path "$L\steamapps\common\$INSTALLDIR\game\$MOD\cfg") { $Concluido = $true; break } 
            }
        }
        if (-not $Concluido) { Write-Host "." -NoNewline; Start-Sleep -Seconds 5 }
    }
    Write-Host "`n[ OK ] Ambiente pronto para receber configurações!" -ForegroundColor Green
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
    Write-Host "`n[OK] Autoexec gerado no Desktop!" -ForegroundColor Green; Start-Sleep -Seconds 3
}

function Invoke-Restore {
    $Autoexec = "$([Environment]::GetFolderPath('Desktop'))\autoexec.cfg"
    if (-not (Test-Path $Autoexec)) { Write-Host "`n[ERRO] autoexec.cfg não encontrado no Desktop!" -ForegroundColor Red; Start-Sleep -Seconds 3; return }
    $Conta = Select-Conta
    if (-not $Conta) { return }
    $Destino = "$($Conta.Path)\$APPID\local\cfg"
    if (-not (Test-Path $Destino)) { New-Item -ItemType Directory -Force -Path $Destino | Out-Null }
    Copy-Item -Path $Autoexec -Destination "$Destino\autoexec.cfg" -Force
    Write-Host "`n[OK] Configurações aplicadas para $($Conta.Nick)!" -ForegroundColor Green; Start-Sleep -Seconds 3
}

# --- MENU PRINCIPAL ---
do {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host " ONLYGOES - CS2 ACT v$VERSION" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host " [ 1 ] Extrair configurações (Salvar na Área de Trabalho)"
    Write-Host " [ 2 ] Restaurar configurações (Aplicar autoexec.cfg na conta Steam)"
    Write-Host " [ 3 ] Preparar ambiente (Instala Steam, inicia instalação do CS2)"
    Write-Host " [ 0 ] Sair"
    Write-Host "=========================================" -ForegroundColor Cyan
    $Op = Read-Host "Opção"
    switch ($Op) {
        '1' { Invoke-Extract }
        '2' { Invoke-Restore }
        '3' { Invoke-Setup }
    }
} until ($Op -eq '0')