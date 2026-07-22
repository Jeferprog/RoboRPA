' Inicia o Keyboard Trigger System (VBScript)
' Duplo-clique para executar (sem aparecer janela de terminal)

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Pega o diretório do script
scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)

' Muda para o diretório
shell.CurrentFolder = scriptPath

' Cria comando para executar Python
Dim pythonCmd, result

' Tenta com "python"
pythonCmd = "python keyboard_trigger.py"

' Executa (oculto - sem mostrar janela)
On Error Resume Next
result = shell.Run(pythonCmd, 0, True)
On Error GoTo 0

' Se falhou (código de erro), tenta com python3
If result <> 0 Then
    pythonCmd = "python3 keyboard_trigger.py"
    On Error Resume Next
    result = shell.Run(pythonCmd, 0, True)
    On Error GoTo 0
End If

' Se ainda falhou, mostra mensagem
If result <> 0 Then
    MsgBox "❌ Python não encontrado!" & vbCrLf & vbCrLf & _
           "Solução:" & vbCrLf & _
           "1. Instale Python em: https://www.python.org/downloads/" & vbCrLf & _
           "2. Marque 'Add Python to PATH' durante a instalação" & vbCrLf & _
           "3. Reinicie este arquivo", _
           vbCritical, "Keyboard Trigger"
Else
    MsgBox "✅ Keyboard Trigger iniciado!" & vbCrLf & _
           "Verifique a janela do Python.", _
           vbInformation, "Keyboard Trigger"
End If
