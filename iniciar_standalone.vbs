' Keyboard Trigger - Versao Standalone (sem dependencia de python.exe)
' Use este arquivo se receber "Acesso negado" ao executar Python

Option Explicit
Dim shell, fso, scriptPath, configFile, phrases, isRunning

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)
configFile = scriptPath & "\phrases.json"

' ============================================================
' CARREGA CONFIGURACAO
' ============================================================
Function LoadConfig()
    Dim fileContent

    If Not fso.FileExists(configFile) Then
        MsgBox "❌ Arquivo phrases.json nao encontrado!" & vbCrLf & vbCrLf & _
               "Caminho esperado:" & vbCrLf & configFile & vbCrLf & vbCrLf & _
               "Solucao:" & vbCrLf & _
               "1. Abra keyboard_trigger_manager.html" & vbCrLf & _
               "2. Adicione suas frases" & vbCrLf & _
               "3. Clique em 'Baixar phrases.json'" & vbCrLf & _
               "4. Execute este arquivo novamente", _
               vbCritical, "Keyboard Trigger"
        WScript.Quit 1
    End If

    On Error Resume Next
    fileContent = fso.OpenTextFile(configFile, 1).ReadAll()
    On Error GoTo 0

    Set phrases = CreateObject("Scripting.Dictionary")
    ParseJson fileContent
End Function

' Simples parser JSON
Sub ParseJson(jsonText)
    Dim startPos, endPos, hotkey, phrase

    jsonText = Replace(jsonText, vbCrLf, " ")
    jsonText = Replace(jsonText, vbCr, " ")
    jsonText = Replace(jsonText, vbLf, " ")

    startPos = InStr(1, jsonText, """") + 1

    While startPos > 1
        endPos = InStr(startPos, jsonText, """")
        If endPos = 0 Then Exit While

        hotkey = Mid(jsonText, startPos, endPos - startPos)

        startPos = InStr(endPos + 1, jsonText, """") + 1
        If startPos = 0 Then Exit While

        endPos = InStr(startPos, jsonText, """")
        If endPos = 0 Then Exit While

        phrase = Mid(jsonText, startPos, endPos - startPos)

        phrase = Replace(phrase, "\n", vbCrLf)
        phrase = Replace(phrase, "\t", vbTab)
        phrase = Replace(phrase, "\\", "\")

        If Len(hotkey) > 0 Then
            phrases(hotkey) = phrase
        End If

        startPos = InStr(endPos + 1, jsonText, """") + 1
    Wend
End Sub

' ============================================================
' SIMULA DIGITACAO
' ============================================================
Sub TypeText(text)
    Dim lines, i, escapedLine

    lines = Split(text, vbCrLf)

    For i = LBound(lines) To UBound(lines)
        escapedLine = lines(i)
        escapedLine = Replace(escapedLine, "{", "{{")
        escapedLine = Replace(escapedLine, "}", "}}")
        escapedLine = Replace(escapedLine, "+", "{+}")

        If i > LBound(lines) Then
            shell.SendKeys "{ENTER}"
            WScript.Sleep 100
        End If

        shell.SendKeys escapedLine
        WScript.Sleep 50
    Next
End Sub

' ============================================================
' INTERFACE PRINCIPAL
' ============================================================
Sub Main()
    Dim msg, hotkey

    LoadConfig()

    msg = "╔═══════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER              ║" & vbCrLf & _
          "║  (Versao Standalone)              ║" & vbCrLf & _
          "╚═══════════════════════════════════╝" & vbCrLf & vbCrLf & _
          "📋 Frases carregadas: " & phrases.Count & vbCrLf & vbCrLf

    If phrases.Count > 0 Then
        For Each hotkey In phrases.Keys
            msg = msg & "  " & hotkey & vbCrLf & _
                        "    └─ " & Left(phrases(hotkey), 40) & "..." & vbCrLf
        Next
        msg = msg & vbCrLf & _
              "✅ Sistema pronto!" & vbCrLf & vbCrLf & _
              "⚠️  LIMITACAO:" & vbCrLf & _
              "VBScript nao consegue monitorar hotkeys em background." & vbCrLf & vbCrLf & _
              "SOLUCAO:" & vbCrLf & _
              "1. Tente: iniciar_admin.bat" & vbCrLf & _
              "2. Ou instale 'keyboard': pip install keyboard" & vbCrLf & _
              "3. Depois use: python keyboard_trigger.py"
    Else
        msg = msg & "❌ Nenhuma frase configurada!" & vbCrLf & _
              "Use o gerenciador HTML para adicionar frases."
    End If

    WScript.Echo msg

    If phrases.Count > 0 Then
        MsgBox msg, vbInformation, "Keyboard Trigger"
    Else
        MsgBox msg, vbExclamation, "Keyboard Trigger"
    End If
End Sub

' Executa
Main
