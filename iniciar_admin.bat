@echo off
REM Inicia o Keyboard Trigger System com permissões de administrador
REM Se receber "Acesso negado", execute este arquivo!

setlocal enabledelayedexpansion

REM Verifica se é administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo Solicitando permissoes de administrador...
    echo.

    REM Reexecuta como administrador
    powershell -Command "Start-Process cmd -ArgumentList '/c cd /d %cd% && %~f0' -Verb RunAs"
    exit /b
)

echo.
echo ╔════════════════════════════════════════╗
echo ║   🎹 KEYBOARD TRIGGER SYSTEM           ║
echo ║   (Modo Administrador)                 ║
echo ║   Iniciando...                         ║
echo ╚════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM Tenta encontrar Python
for /f "delims=" %%i in ('where python 2^>nul') do set "PYTHON_PATH=%%i"

if not defined PYTHON_PATH (
    REM Se não encontrou com 'where', tenta caminhos comuns
    if exist "C:\Python311\python.exe" set "PYTHON_PATH=C:\Python311\python.exe"
    if exist "C:\Python310\python.exe" set "PYTHON_PATH=C:\Python310\python.exe"
    if exist "C:\Python39\python.exe" set "PYTHON_PATH=C:\Python39\python.exe"
)

if defined PYTHON_PATH (
    echo ✓ Python encontrado: !PYTHON_PATH!
    echo.
    !PYTHON_PATH! keyboard_trigger.py
) else (
    echo.
    echo ❌ Python nao encontrado!
    echo.
    echo Instalacoes comuns tentadas:
    echo - C:\Python311\python.exe
    echo - C:\Python310\python.exe
    echo - C:\Python39\python.exe
    echo.
    echo Solucao:
    echo 1. Instale Python: https://www.python.org/downloads/
    echo 2. Marque "Add Python to PATH"
    echo 3. Reinicie este arquivo como administrador
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Keyboard Trigger foi fechado.
pause
