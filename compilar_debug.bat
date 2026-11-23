@echo off
REM ============================================================
REM  Versao DIAGNOSTICO: compila mostrando TUDO, detecta se o
REM  antivirus removeu o .exe e abre os logs no Bloco de Notas.
REM ============================================================
cd /d "%~dp0"
set "LOG=%~dp0compilar_log.txt"
break > "%LOG%"

call :both ==== DIAGNOSTICO DE COMPILACAO ====
call :both Pasta: %~dp0
call :both Data: %date% %time%
call :both.

set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
call :both Compilador: %CSC%

if not exist "KeyboardTrigger.cs" call :both ATENCAO: KeyboardTrigger.cs NAO esta nesta pasta!
if not exist "phrases.json"       call :both ATENCAO: phrases.json NAO esta nesta pasta!

call :both.
call :both Fechando instancia anterior (se houver)...
taskkill /im KeyboardTrigger.exe /f >nul 2>&1
del KeyboardTrigger.exe >nul 2>&1

call :both Compilando... (saida do compilador abaixo)
"%CSC%" /nologo /target:winexe /out:KeyboardTrigger.exe /r:System.Windows.Forms.dll /r:System.Drawing.dll KeyboardTrigger.cs >> "%LOG%" 2>&1
call :both ExitCode do compilador: %errorlevel%

if exist "KeyboardTrigger.exe" (
    call :both RESULTADO: KeyboardTrigger.exe FOI criado com sucesso.
) else (
    call :both RESULTADO: KeyboardTrigger.exe NAO foi criado.
    call :both   -^> Ou houve erro de compilacao acima, ou o antivirus removeu.
    goto :fim
)

call :both.
call :both Iniciando o programa...
start "" "KeyboardTrigger.exe"

call :both Aguardando 4 segundos para ver se o antivirus remove o exe...
ping -n 5 127.0.0.1 >nul

if exist "KeyboardTrigger.exe" (
    call :both APOS 4s: o exe AINDA existe (bom sinal).
) else (
    call :both APOS 4s: o exe SUMIU. Provavel Windows Defender/antivirus.
    call :both   -^> Veja em: Seguranca do Windows ^> Protecao contra virus ^> Historico.
)

:fim
call :both.
call :both ==== FIM ====
echo.
echo Abrindo os logs...
notepad "%LOG%"
if exist "%~dp0keyboardtrigger_log.txt" notepad "%~dp0keyboardtrigger_log.txt"
echo.
pause
exit /b

:both
>>"%LOG%" echo %*
echo %*
exit /b
