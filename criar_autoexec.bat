@echo off
REM Cria atalho para auto-executar keyboard_trigger_monitorv2.vbs na inicializacao

setlocal enabledelayedexpansion

REM Caminho para a pasta Iniciar
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

REM Caminho do script VBScript
set "SCRIPT_PATH=%~dp0keyboard_trigger_monitorv2.vbs"

REM Cria o atalho
if exist "%STARTUP_FOLDER%" (
    powershell -Command ^
        "$WshShell = New-Object -ComObject WScript.Shell; " ^
        "$shortcut = $WshShell.CreateShortcut('%STARTUP_FOLDER%\Keyboard Trigger.lnk'); " ^
        "$shortcut.TargetPath = '%SCRIPT_PATH%'; " ^
        "$shortcut.IconLocation = 'c:\windows\system32\mshta.exe'; " ^
        "$shortcut.Save()"

    echo.
    echo ╔════════════════════════════════════════╗
    echo ║  ✅ ATALHO CRIADO COM SUCESSO!        ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo 🎹 Keyboard Trigger vai iniciar AUTOMATICAMENTE
    echo    quando voce ligar o computador!
    echo.
    echo Local: %STARTUP_FOLDER%
    echo.
    pause
) else (
    echo ❌ Pasta Startup nao encontrada!
    pause
    exit /b 1
)
