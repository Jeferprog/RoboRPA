' ============================================================
' Keyboard Trigger Monitor v2 - VBScript Puro
' Funciona SEM permissoes de administrador!
' ============================================================

Option Explicit

Dim shell, fso, scriptPath, configFile, phrases

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

' Parser JSON simples
Sub ParseJson(jsonText)
    Dim i, char, inString, key, value
    Dim currentKey, currentValue

    inString = False
    currentKey = ""
    currentValue = ""

    ' Remove quebras de linha
    jsonText = Replace(jsonText, vbCrLf, " ")
    jsonText = Replace(jsonText, vbCr, " ")
    jsonText = Replace(jsonText, vbLf, " ")

    ' Parse manual simples
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
        ElseIf char = ":" And currentKey <> "" And currentValue = "" Then
            ' Encontrou separador key:value
        ElseIf char = "," And currentKey <> "" And currentValue <> "" Then
            ' Encontrou separador de pares
            currentValue = Replace(currentValue, "\n", vbCrLf)
            currentValue = Replace(currentValue, "\t", vbTab)
            currentValue = Replace(currentValue, "\\", "\")
            phrases.Add currentKey, currentValue
            currentKey = ""
            currentValue = ""
        End If
    Next

    ' Processa ultimo par
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
' EXIBE MENU E SELECIONA FRASE
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
          "║  🎹 KEYBOARD TRIGGER SYSTEM            ║" & vbCrLf & _
          "║  Selecione uma frase                   ║" & vbCrLf & _
          "╚════════════════════════════════════════╝" & vbCrLf & vbCrLf

    For i = 1 To count
        hotkey = phraseList(CStr(i))
        msg = msg & i & ". " & hotkey & vbCrLf & _
              "   """ & Left(phrases(hotkey), 40) & """" & vbCrLf & vbCrLf
    Next

    msg = msg & vbCrLf & "Digite o numero (1-" & count & "):"

    choice = InputBox(msg, "Keyboard Trigger")

    If choice = "" Then
        SelectPhrase = ""
    ElseIf IsNumeric(choice) Then
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
Function IsNumeric(str)
    Dim i
    IsNumeric = True
    If str = "" Then
        IsNumeric = False
    Else
        For i = 1 To Len(str)
            If Not IsNumeric(Asc(Mid(str, i, 1))) Then
                IsNumeric = False
            End If
        Next
    End If
End Function

' Sobrecarga IsNumeric para caractere
Function IsNumeric(charCode)
    IsNumeric = (charCode >= 48 And charCode <= 57)
End Function

' ============================================================
' MENU PRINCIPAL
' ============================================================
Sub MainMenu()
    Dim msg, hotkey

    LoadConfig()

    If phrases.Count = 0 Then
        MsgBox "❌ Nenhuma frase configurada!" & vbCrLf & vbCrLf & _
               "Use o gerenciador HTML:" & vbCrLf & _
               "keyboard_trigger_manager.html", vbExclamation
        WScript.Quit 1
    End If

    msg = "╔════════════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER                  ║" & vbCrLf & _
          "║  Versao VBScript (Sem Admin)          ║" & vbCrLf & _
          "╚════════════════════════════════════════╝" & vbCrLf & vbCrLf & _
          "📋 Frases carregadas: " & phrases.Count & vbCrLf & vbCrLf & _
          "🎯 Como usar:" & vbCrLf & _
          "1. Clique OK no proximo popup" & vbCrLf & _
          "2. Digite o numero da frase" & vbCrLf & _
          "3. Coloque o cursor no campo de texto" & vbCrLf & _
          "4. Clique OK para digitar a frase" & vbCrLf & vbCrLf & _
          "💡 Deixe este programa aberto e" & vbCrLf & _
          "   use sempre que precisar!"

    MsgBox msg, vbInformation, "Keyboard Trigger"

    RunLoop()
End Sub

' Loop de selecao
Sub RunLoop()
    Dim selectedHotkey, continueLoop

    continueLoop = True

    Do While continueLoop
        selectedHotkey = SelectPhrase()

        If selectedHotkey = "" Then
            continueLoop = False
        Else
            MsgBox "Digitando: " & Left(phrases(selectedHotkey), 50) & vbCrLf & vbCrLf & _
                   "Clique OK e coloque o cursor no campo onde quer digitar.", vbInformation

            TypePhrase phrases(selectedHotkey)

            MsgBox "✅ Frase digitada!" & vbCrLf & vbCrLf & _
                   "Selecione outra ou clique Cancelar para sair.", vbInformation
        End If
    Loop
End Sub

' ============================================================
' EXECUTA
' ============================================================
MainMenu()
