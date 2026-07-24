@echo off
REM Cria atalho na area de trabalho para rapido acesso

setlocal enabledelayedexpansion

REM Caminho para a area de trabalho
set "DESKTOP=%USERPROFILE%\Desktop"

REM Caminho do script VBScript (versao simples sem erros)
set "SCRIPT_PATH=%~dp0keyboard_trigger_simples.vbs"

REM Cria o atalho
powershell -Command ^
    "$WshShell = New-Object -ComObject WScript.Shell; " ^
    "$shortcut = $WshShell.CreateShortcut('%DESKTOP%\🎹 Keyboard Trigger.lnk'); " ^
    "$shortcut.TargetPath = '%SCRIPT_PATH%'; " ^
    "$shortcut.Save()"

echo.
echo ╔════════════════════════════════════════╗
echo ║  ✅ ATALHO CRIADO NA AREA DE TRABALHO! ║
echo ╚════════════════════════════════════════╝
echo.
echo 🎹 Agora voce pode clicar rapidamente
echo    no atalho '🎹 Keyboard Trigger'
echo.
pause
