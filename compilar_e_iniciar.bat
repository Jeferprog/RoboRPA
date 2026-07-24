@echo off
REM ============================================================
REM  Compila o KeyboardTrigger.cs usando o csc.exe que ja vem
REM  no Windows, e inicia o programa (atalhos globais).
REM  Nao precisa de admin nem instalar nada.
REM ============================================================
cd /d "%~dp0"

REM Localiza o compilador C# embutido no Windows
set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" (
    echo.
    echo Compilador C# (csc.exe) nao encontrado nesta maquina.
    echo.
    pause
    exit /b 1
)

REM Fecha instancia anterior para poder regravar o .exe
taskkill /im KeyboardTrigger.exe /f >nul 2>&1

echo.
echo Compilando KeyboardTrigger.exe ...
"%CSC%" /nologo /target:winexe /out:KeyboardTrigger.exe /r:System.Windows.Forms.dll /r:System.Drawing.dll KeyboardTrigger.cs

if not exist KeyboardTrigger.exe (
    echo.
    echo FALHA ao compilar. Veja as mensagens acima.
    echo.
    pause
    exit /b 1
)

echo OK! Iniciando o programa...
start "" KeyboardTrigger.exe

echo.
echo ============================================================
echo  Pronto! O Keyboard Trigger esta rodando na bandeja do
echo  sistema (perto do relogio, canto inferior direito).
echo.
echo  - Aperte seu atalho (ex: Ctrl+Alt+1) em qualquer lugar
echo    para digitar a frase.
echo  - Botao direito no icone da bandeja: Recarregar / Sair.
echo.
echo  Pode fechar esta janela.
echo ============================================================
timeout /t 6 >nul
