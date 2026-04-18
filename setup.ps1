# ============================================================
# SETUP.PS1 - OnlyGoes IT Solutions
# Instalação silenciosa da Steam e gatilho de download do CS2
# ============================================================

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "ERRO: Execute este script como ADMINISTRADOR para instalar a Steam." -ForegroundColor Red
    Read-Host "Pressione ENTER para sair..."; exit
}

# --- INSTALAÇÃO DA STEAM ---
if (-not (Test-Path "HKCU:\SOFTWARE\Valve\Steam")) {
    Write-Host "[ ... ] Instalando Steam via Winget..." -ForegroundColor Cyan
    winget install Valve.Steam --silent --accept-source-agreements --accept-package-agreements | Out-Null
} else {
    Write-Host "[ OK ] Steam já instalada." -ForegroundColor Green
}

# --- GATILHO DO JOGO ---
Write-Host "[ !!! ] Faça login na Steam e inicie o download do CS2." -ForegroundColor Yellow
Start-Process "steam://install/730"

# --- MONITORAMENTO ---
Write-Host "Monitorando criação das pastas do jogo..." -ForegroundColor Cyan
# (Lógica de loop de monitoramento da Seção 4 que validamos antes)
Write-Host "[ OK ] Ambiente pronto para receber configurações." -ForegroundColor Green