@echo off
REM Inicia o Keyboard Trigger System
REM Duplo-clique para executar

cd /d "%~dp0"

echo.
echo ╔════════════════════════════════════════╗
echo ║   🎹 KEYBOARD TRIGGER SYSTEM           ║
echo ║   Iniciando...                         ║
echo ╚════════════════════════════════════════╝
echo.

REM Tenta executar com python
python keyboard_trigger.py
if errorlevel 1 (
    echo.
    echo ❌ Erro ao executar com 'python'
    echo Tentando com 'python3'...
    echo.
    python3 keyboard_trigger.py
    if errorlevel 1 (
        echo.
        echo ❌ Python não encontrado!
        echo.
        echo Solução:
        echo 1. Instale Python em: https://www.python.org/downloads/
        echo 2. Marque "Add Python to PATH" durante a instalação
        echo 3. Reinicie este arquivo
        echo.
        pause
        exit /b 1
    )
)

pause
