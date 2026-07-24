@echo off
REM ============================================================
REM  Diagnostico - descobre qual caminho de atalho global
REM  funciona nesta maquina (sem admin, sem instalar nada).
REM  Gera um arquivo no Desktop e abre no Bloco de Notas.
REM ============================================================
setlocal enabledelayedexpansion
set "OUT=%USERPROFILE%\Desktop\diagnostico_keyboard.txt"
break > "%OUT%"

>>"%OUT%" echo ================================================
>>"%OUT%" echo   DIAGNOSTICO - Keyboard Trigger (atalho global)
>>"%OUT%" echo ================================================
>>"%OUT%" echo Data: %date% %time%
>>"%OUT%" echo.

>>"%OUT%" echo [1] PYTHON - onde o Windows encontra:
where python  >>"%OUT%" 2>&1
where python3 >>"%OUT%" 2>&1
where py      >>"%OUT%" 2>&1
>>"%OUT%" echo.
>>"%OUT%" echo [1b] Versoes instaladas pelo launcher (py -0):
py -0 >>"%OUT%" 2>&1
>>"%OUT%" echo.
>>"%OUT%" echo [1c] Teste "py --version":
py --version >>"%OUT%" 2>&1
>>"%OUT%" echo [1d] Teste "python --version":
python --version >>"%OUT%" 2>&1
>>"%OUT%" echo.

>>"%OUT%" echo [2] COMPILADOR C# (csc.exe) que ja vem no Windows:
set "CSC="
if exist "%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not defined CSC if exist "%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if defined CSC ( >>"%OUT%" echo   Encontrado: !CSC! ) else ( >>"%OUT%" echo   csc.exe NAO encontrado )
>>"%OUT%" echo.

>>"%OUT%" echo [2b] Teste de COMPILAR e RODAR um programa C#:
if not defined CSC goto :skipcs
>"%TEMP%\kt_test.cs" echo public class T{ public static void Main(){ System.Console.WriteLine("compilou-e-rodou-ok"); } }
"%CSC%" /nologo /out:"%TEMP%\kt_test.exe" "%TEMP%\kt_test.cs" >>"%OUT%" 2>&1
if exist "%TEMP%\kt_test.exe" "%TEMP%\kt_test.exe" >>"%OUT%" 2>&1
if not exist "%TEMP%\kt_test.exe" >>"%OUT%" echo   FALHOU ao compilar/rodar (pode ser bloqueio de politica)
del "%TEMP%\kt_test.cs" >nul 2>&1
del "%TEMP%\kt_test.exe" >nul 2>&1
goto :aftercs
:skipcs
>>"%OUT%" echo   Pulado (sem csc.exe)
:aftercs
>>"%OUT%" echo.

>>"%OUT%" echo [3] AUTOHOTKEY (se ja existir na maquina):
where autohotkey >>"%OUT%" 2>&1
where AutoHotkey64 >>"%OUT%" 2>&1
if exist "%ProgramFiles%\AutoHotkey" ( >>"%OUT%" echo   Existe pasta em Program Files ) else ( >>"%OUT%" echo   Sem pasta em Program Files )
>>"%OUT%" echo.

>>"%OUT%" echo [4] POWERSHELL - versao e modo de linguagem:
powershell -NoProfile -Command "$PSVersionTable.PSVersion.ToString(); 'LanguageMode=' + $ExecutionContext.SessionState.LanguageMode" >>"%OUT%" 2>&1
>>"%OUT%" echo.

>>"%OUT%" echo [5] Alias de execucao (a causa provavel do "Acesso negado"):
>>"%OUT%" echo   Se o item [1] acima mostrar um caminho terminando em
>>"%OUT%" echo   \Microsoft\WindowsApps\python.exe , entao o "Acesso negado"
>>"%OUT%" echo   vem do alias da Microsoft Store e da pra desligar sem admin.
>>"%OUT%" echo.
>>"%OUT%" echo ===================== FIM =====================

echo.
echo Diagnostico concluido. Resultado salvo em:
echo   %OUT%
echo.
type "%OUT%"
echo.
echo Abrindo no Bloco de Notas...
notepad "%OUT%"
