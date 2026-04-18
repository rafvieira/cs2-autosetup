# ============================================================
# RESTORE_CFG.PS1 - OnlyGoes IT Solutions
# Aplica o autoexec.cfg do Desktop à conta Steam selecionada
# ============================================================

$AutoexecOrigem = "$([Environment]::GetFolderPath('Desktop'))\autoexec.cfg"

if (-not (Test-Path $AutoexecOrigem)) {
    Write-Host "ERRO: autoexec.cfg não encontrado no Desktop!" -ForegroundColor Red; exit
}

$SteamPath = (Get-ItemPropertyValue "HKCU:\SOFTWARE\Valve\Steam" SteamPath)

# --- MENU DE SELEÇÃO DE CONTA ---
# (Mesma lógica de menu do extract_cfg.ps1 para garantir que vai para a conta certa)

# --- INJEÇÃO ---
$PastaDestino = "$($selectedAcc.Path)\730\local\cfg"
if (-not (Test-Path $PastaDestino)) { New-Item -Path $PastaDestino -ItemType Directory -Force }

Copy-Item -Path $AutoexecOrigem -Destination "$PastaDestino\autoexec.cfg" -Force
Write-Host "Configurações aplicadas com sucesso para $($selectedAcc.Nick)!" -ForegroundColor Green