' ============================================================
' Keyboard Trigger Monitor v2 - VBScript Puro
' Funciona SEM permissoes de administrador!
' Monitora hotkeys e simula digitacao
' ============================================================

Option Explicit

Dim shell, fso, scriptPath, configFile
Dim phrases, keyStates, runningLoop

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)
configFile = scriptPath & "\phrases.json"

' ============================================================
' CARREGA CONFIGURACAO
' ============================================================
Sub LoadConfig()
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
End Sub

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
Sub TypePhrase(text)
    Dim lines, i, escapedLine

    WScript.Sleep 300

    lines = Split(text, vbCrLf)

    For i = LBound(lines) To UBound(lines)
        escapedLine = lines(i)
        escapedLine = Replace(escapedLine, "{", "{{")
        escapedLine = Replace(escapedLine, "}", "}}")
        escapedLine = Replace(escapedLine, "+", "{+}")

        If i > LBound(lines) Then
            shell.SendKeys "{ENTER}"
            WScript.Sleep 150
        End If

        shell.SendKeys escapedLine
        WScript.Sleep 80
    Next
End Sub

' ============================================================
' MONITORAMENTO DE HOTKEYS (COM POPUP)
' ============================================================
Sub ShowHotkeysMenu()
    Dim msg, hotkey, choice, phraseList, i

    ' Cria lista de hotkeys
    Set phraseList = CreateObject("Scripting.Dictionary")

    i = 1
    For Each hotkey In phrases.Keys
        phraseList.Add CStr(i), hotkey
        i = i + 1
    Next

    ' Constroi mensagem do menu
    msg = "╔════════════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER SYSTEM            ║" & vbCrLf & _
          "║  Selecione uma frase para digitar      ║" & vbCrLf & _
          "╚════════════════════════════════════════╝" & vbCrLf & vbCrLf

    For i = 1 To phraseList.Count
        msg = msg & i & ". " & phraseList(CStr(i)) & vbCrLf & _
              "   > " & Left(phrases(phraseList(CStr(i))), 50) & "..." & vbCrLf & vbCrLf
    Next

    msg = msg & vbCrLf & "Digite o numero (1-" & phraseList.Count & ") e clique OK" & vbCrLf & _
              "ou clique Cancelar para fechar."

    choice = InputBox(msg, "Keyboard Trigger - Selecione Frase")

    If choice = "" Then
        Exit Sub
    End If

    If IsNumeric(choice) Then
        If CLng(choice) >= 1 And CLng(choice) <= phraseList.Count Then
            hotkey = phraseList(CStr(CLng(choice)))
            MsgBox "Digitando: " & Left(phrases(hotkey), 50) & "..." & vbCrLf & vbCrLf & _
                   "Clique OK e coloque o cursor no campo onde quer digitar.", vbInformation
            TypePhrase phrases(hotkey)
            MsgBox "✅ Frase digitada!", vbInformation
            Exit Sub
        End If
    End If

    MsgBox "❌ Escolha invalida!", vbCritical
End Sub

' ============================================================
' MENU PRINCIPAL
' ============================================================
Sub ShowMainMenu()
    Dim msg, result

    msg = "╔════════════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER SYSTEM            ║" & vbCrLf & _
          "║  Monitor de Frases                     ║" & vbCrLf & _
          "╚════════════════════════════════════════╝" & vbCrLf & vbCrLf & _
          "📋 Frases carregadas: " & phrases.Count & vbCrLf & vbCrLf & _
          "🎯 Como usar:" & vbCrLf & _
          "1. Clique 'OK' no proximo popup" & vbCrLf & _
          "2. Selecione a frase que quer digitar" & vbCrLf & _
          "3. Coloque o cursor no campo de texto" & vbCrLf & _
          "4. Clique 'OK' para digitar" & vbCrLf & vbCrLf & _
          "💡 Dica: Deixe este programa aberto e" & vbCrLf & _
          "   chame-o sempre que precisar!" & vbCrLf & vbCrLf & _
          "❌ Para sair, feche esta janela."

    MsgBox msg, vbInformation, "Keyboard Trigger"
    ShowHotkeysMenu()
End Sub

' Verifica se e numero
Function IsNumeric(strValue)
    Dim i
    IsNumeric = True
    For i = 1 To Len(strValue)
        If Not IsNumeric(Mid(strValue, i, 1)) Then
            IsNumeric = False
            Exit Function
        End If
    Next
End Function

' ============================================================
' PONTO DE ENTRADA
' ============================================================
LoadConfig()

If phrases.Count = 0 Then
    MsgBox "❌ Nenhuma frase configurada!" & vbCrLf & vbCrLf & _
           "Use o gerenciador HTML:" & vbCrLf & _
           "keyboard_trigger_manager.html", vbExclamation
    WScript.Quit 1
End If

' Loop principal
Do While True
    ShowMainMenu()
Loop
