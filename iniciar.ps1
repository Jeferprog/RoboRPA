# Inicia o Keyboard Trigger System (PowerShell)
# Clique direito > Executar com PowerShell

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🎹 KEYBOARD TRIGGER SYSTEM" -ForegroundColor Green
Write-Host "   Iniciando..." -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Tenta executar
try {
    python keyboard_trigger.py
} catch {
    Write-Host "❌ Erro ao executar com 'python'" -ForegroundColor Red
    Write-Host "Tentando com 'python3'..." -ForegroundColor Yellow
    Write-Host ""

    try {
        python3 keyboard_trigger.py
    } catch {
        Write-Host "❌ Python não encontrado!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solução:" -ForegroundColor Yellow
        Write-Host "1. Instale Python em: https://www.python.org/downloads/" -ForegroundColor White
        Write-Host "2. Marque 'Add Python to PATH' durante a instalação" -ForegroundColor White
        Write-Host "3. Reinicie PowerShell e este script" -ForegroundColor White
        Write-Host ""
        Read-Host "Pressione ENTER para fechar"
        exit 1
    }
}

Read-Host "Pressione ENTER para fechar"
