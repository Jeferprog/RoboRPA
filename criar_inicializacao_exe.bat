@echo off
REM ============================================================
REM  Faz o KeyboardTrigger.exe iniciar automaticamente junto
REM  com o Windows (cria atalho na pasta Inicializar do usuario).
REM  Nao precisa de admin.
REM ============================================================
cd /d "%~dp0"

if not exist "KeyboardTrigger.exe" (
    echo.
    echo O KeyboardTrigger.exe ainda nao existe.
    echo Rode primeiro o compilar_e_iniciar.bat
    echo.
    pause
    exit /b 1
)

set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "ALVO=%~dp0KeyboardTrigger.exe"

powershell -NoProfile -Command ^
  "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%STARTUP%\Keyboard Trigger.lnk'); $s.TargetPath='%ALVO%'; $s.WorkingDirectory='%~dp0'; $s.Save()"

echo.
echo ============================================================
echo  Pronto! O Keyboard Trigger vai iniciar sozinho toda vez
echo  que voce ligar/entrar no Windows.
echo.
echo  (Para desativar depois: apague o atalho "Keyboard Trigger"
echo   da pasta Inicializar - abra com Win+R e digite: shell:startup)
echo ============================================================
echo.
pause
