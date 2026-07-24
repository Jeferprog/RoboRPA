' ============================================================
' Keyboard Trigger - Versao Background/Loop
' Roda continuamente esperando voce usar
' ============================================================

Option Explicit

Dim shell, fso, scriptPath, configFile, phrases, continueRunning

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)
configFile = scriptPath & "\phrases.json"
continueRunning = True

' ============================================================
' CARREGA CONFIGURACAO
' ============================================================
Sub LoadConfig()
    Dim fileContent

    If Not fso.FileExists(configFile) Then
        MsgBox "❌ Arquivo phrases.json nao encontrado!" & vbCrLf & vbCrLf & _
               "Solucao:" & vbCrLf & _
               "1. Abra keyboard_trigger_manager.html" & vbCrLf & _
               "2. Adicione suas frases" & vbCrLf & _
               "3. Clique em 'Baixar phrases.json'", _
               vbCritical, "Keyboard Trigger"
        WScript.Quit 1
    End If

    On Error Resume Next
    fileContent = fso.OpenTextFile(configFile, 1).ReadAll()
    On Error GoTo 0

    Set phrases = CreateObject("Scripting.Dictionary")
    ParseJson fileContent
End Sub

' Parser JSON simples
Sub ParseJson(jsonText)
    Dim i, char, currentKey, currentValue
    Dim inString

    inString = False
    currentKey = ""
    currentValue = ""

    jsonText = Replace(jsonText, vbCrLf, " ")
    jsonText = Replace(jsonText, vbCr, " ")
    jsonText = Replace(jsonText, vbLf, " ")

    For i = 1 To Len(jsonText)
        char = Mid(jsonText, i, 1)

        If char = """" Then
            inString = Not inString
        ElseIf inString Then
            If currentKey = "" Then
                currentKey = currentKey & char
            Else
                currentValue = currentValue & char
            End If
        ElseIf char = "," And currentKey <> "" And currentValue <> "" Then
            currentValue = Replace(currentValue, "\n", vbCrLf)
            currentValue = Replace(currentValue, "\t", vbTab)
            currentValue = Replace(currentValue, "\\", "\")
            phrases.Add currentKey, currentValue
            currentKey = ""
            currentValue = ""
        End If
    Next

    If currentKey <> "" And currentValue <> "" Then
        currentValue = Replace(currentValue, "\n", vbCrLf)
        currentValue = Replace(currentValue, "\t", vbTab)
        currentValue = Replace(currentValue, "\\", "\")
        phrases.Add currentKey, currentValue
    End If
End Sub

' ============================================================
' SIMULA DIGITACAO
' ============================================================
Sub TypePhrase(text)
    Dim lines, i, line, escapedLine

    WScript.Sleep 300

    lines = Split(text, vbCrLf)

    For i = LBound(lines) To UBound(lines)
        line = lines(i)
        escapedLine = Replace(line, "{", "{{")
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
' SELECIONA FRASE
' ============================================================
Function SelectPhrase()
    Dim msg, hotkey, choice, phraseList, i, count

    Set phraseList = CreateObject("Scripting.Dictionary")

    count = 0
    For Each hotkey In phrases.Keys
        count = count + 1
        phraseList.Add CStr(count), hotkey
    Next

    msg = "╔════════════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER                  ║" & vbCrLf & _
          "║  Selecione uma frase                  ║" & vbCrLf & _
          "╚════════════════════════════════════════╝" & vbCrLf & vbCrLf

    For i = 1 To count
        hotkey = phraseList(CStr(i))
        msg = msg & i & ". " & hotkey & vbCrLf & _
              "   """ & Left(phrases(hotkey), 40) & """" & vbCrLf & vbCrLf
    Next

    msg = msg & "Digite o numero (1-" & count & ") ou deixe em branco para sair:"

    choice = InputBox(msg, "Keyboard Trigger")

    If choice = "" Then
        SelectPhrase = ""
    ElseIf IsNumericStr(choice) Then
        If CLng(choice) >= 1 And CLng(choice) <= count Then
            SelectPhrase = phraseList(CStr(CLng(choice)))
        Else
            MsgBox "❌ Numero invalido!", vbCritical
            SelectPhrase = ""
        End If
    Else
        MsgBox "❌ Digite um numero valido!", vbCritical
        SelectPhrase = ""
    End If
End Function

' Verifica se e numero
Function IsNumericStr(str)
    Dim i
    IsNumericStr = True
    If str = "" Then
        IsNumericStr = False
    Else
        For i = 1 To Len(str)
            If Asc(Mid(str, i, 1)) < 48 Or Asc(Mid(str, i, 1)) > 57 Then
                IsNumericStr = False
            End If
        Next
    End If
End Function

' ============================================================
' LOOP PRINCIPAL
' ============================================================
Sub MainLoop()
    Dim msg, selectedHotkey

    msg = "╔════════════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER RODANDO!         ║" & vbCrLf & _
          "║  (Versao Background/Loop)             ║" & vbCrLf & _
          "╚════════════════════════════════════════╝" & vbCrLf & vbCrLf & _
          "📋 Frases carregadas: " & phrases.Count & vbCrLf & vbCrLf & _
          "🎯 Como usar:" & vbCrLf & _
          "Este programa vai ficar rodando." & vbCrLf & _
          "Toda vez que quiser usar:" & vbCrLf & _
          "1. Procure pela janela deste programa" & vbCrLf & _
          "2. Clique nela ou na bandeja de tarefas" & vbCrLf & _
          "3. Selecione a frase" & vbCrLf & _
          "4. Pronto!" & vbCrLf & vbCrLf & _
          "💡 Deixe sempre aberto em background!"

    MsgBox msg, vbInformation, "Keyboard Trigger"

    Do While continueRunning
        selectedHotkey = SelectPhrase()

        If selectedHotkey = "" Then
            continueRunning = (MsgBox("Deseja sair do Keyboard Trigger?", vbYesNo) = vbYes)
        Else
            MsgBox "Digitando: " & Left(phrases(selectedHotkey), 50) & vbCrLf & vbCrLf & _
                   "Clique OK e coloque o cursor no campo.", vbInformation

            TypePhrase phrases(selectedHotkey)

            MsgBox "✅ Frase digitada!" & vbCrLf & vbCrLf & _
                   "Selecione outra ou deixe em branco para sair.", vbInformation
        End If
    Loop
End Sub

' ============================================================
' EXECUTA
' ============================================================
LoadConfig()

If phrases.Count = 0 Then
    MsgBox "❌ Nenhuma frase configurada!", vbExclamation
    WScript.Quit 1
End If

MainLoop()
