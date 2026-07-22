' ============================================================
' Keyboard Trigger - VBScript Puro (sem dependências)
' Monitora hotkeys e simula digitacao
' ============================================================

Option Explicit

Dim shell, fso, currentPath, configFile, phrases, hotkeys
Dim isRunning, debugMode

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

currentPath = fso.GetParentFolderName(WScript.ScriptFullName)
configFile = currentPath & "\phrases.json"
debugMode = False

' ============================================================
' CARREGA CONFIGURACAO
' ============================================================
Function LoadConfig()
    Dim fileContent, jsonLines, i, pair

    If Not fso.FileExists(configFile) Then
        MsgBox "Arquivo phrases.json nao encontrado em:" & vbCrLf & _
               currentPath & vbCrLf & vbCrLf & _
               "Criando arquivo padrao...", vbExclamation, "Keyboard Trigger"
        CreateDefaultConfig()
    End If

    ' Simples parser JSON (compativel com frases.json)
    On Error Resume Next
    fileContent = fso.OpenTextFile(configFile, 1).ReadAll()
    On Error GoTo 0

    Set phrases = CreateObject("Scripting.Dictionary")
    ParseJson fileContent
End Function

Sub CreateDefaultConfig()
    Dim defaultConfig
    defaultConfig = "{" & vbCrLf & _
        "  ""Ctrl+Alt+1"": ""Jeferson Demarchi Deimling\nCresol Cooperar""," & vbCrLf & _
        "  ""Ctrl+Alt+2"": ""Sua frase aqui""" & vbCrLf & _
        "}"

    With fso.CreateTextFile(configFile, True)
        .Write defaultConfig
        .Close()
    End With

    MsgBox "Arquivo phrases.json criado!" & vbCrLf & _
           "Edite-o com bloco de notas e execute novamente.", vbInformation, "Keyboard Trigger"
    WScript.Quit
End Sub

' Simples parser JSON
Sub ParseJson(jsonText)
    Dim lines, i, line, hotkey, phrase, startQuote, endQuote, colonPos

    ' Remove espacos e quebras
    jsonText = Replace(jsonText, vbCrLf, " ")
    jsonText = Replace(jsonText, vbCr, " ")
    jsonText = Replace(jsonText, vbLf, " ")

    ' Procura por pares "hotkey": "phrase"
    Dim startPos, endPos
    startPos = InStr(1, jsonText, """") + 1

    While startPos > 1
        ' Encontra proximo hotkey
        endPos = InStr(startPos, jsonText, """")
        If endPos = 0 Then Exit While

        hotkey = Mid(jsonText, startPos, endPos - startPos)

        ' Encontra valor (phrase)
        startPos = InStr(endPos + 1, jsonText, """") + 1
        If startPos = 0 Then Exit While

        endPos = InStr(startPos, jsonText, """")
        If endPos = 0 Then Exit While

        phrase = Mid(jsonText, startPos, endPos - startPos)

        ' Converte escape sequences
        phrase = Replace(phrase, "\n", vbCrLf)
        phrase = Replace(phrase, "\t", vbTab)
        phrase = Replace(phrase, "\\", "\")

        ' Adiciona ao dicionario
        If Len(hotkey) > 0 Then
            phrases(hotkey) = phrase
        End If

        startPos = InStr(endPos + 1, jsonText, """") + 1
    Wend
End Sub

' ============================================================
' EXIBIR STATUS
' ============================================================
Sub DisplayStatus()
    Dim msg, key, count

    count = phrases.Count
    msg = "╔═══════════════════════════════════╗" & vbCrLf & _
          "║  🎹 KEYBOARD TRIGGER              ║" & vbCrLf & _
          "║  Simulador de Digitacao            ║" & vbCrLf & _
          "╚═══════════════════════════════════╝" & vbCrLf & vbCrLf & _
          "📋 Frases carregadas: " & count & vbCrLf & vbCrLf

    If count > 0 Then
        For Each key In phrases.Keys
            msg = msg & "  " & key & vbCrLf & _
                        "    └─ " & Left(phrases(key), 40) & "..." & vbCrLf
        Next
        msg = msg & vbCrLf & vbCrLf & _
              "✅ Sistema pronto!" & vbCrLf & _
              "⏳ Escutando hotkeys..." & vbCrLf & vbCrLf & _
              "💡 IMPORTANTE:" & vbCrLf & _
              "VBScript nao consegue monitorar hotkeys em background" & vbCrLf & _
              "sem uma biblioteca externa (keyboard)." & vbCrLf & vbCrLf & _
              "SOLUCAO:" & vbCrLf & _
              "  Use 'keyboard_trigger.py' (Python)" & vbCrLf & _
              "  ou instale: pip install keyboard"
    Else
        msg = msg & "❌ Nenhuma frase configurada!" & vbCrLf & _
              "Verifique " & configFile
    End If

    WScript.Echo msg
End Sub

' ============================================================
' SIMULA DIGITACAO
' ============================================================
Sub TypeText(text)
    ' Tira quebras de linha para processamento em partes
    Dim lines, i
    lines = Split(text, vbCrLf)

    For i = LBound(lines) To UBound(lines)
        ' Escapa caracteres especiais para SendKeys
        Dim escapedLine
        escapedLine = lines(i)
        escapedLine = Replace(escapedLine, "{", "{{")
        escapedLine = Replace(escapedLine, "}", "}}")
        escapedLine = Replace(escapedLine, "+", "{+}")

        If i > LBound(lines) Then
            ' Quebra de linha (Enter)
            shell.SendKeys "{ENTER}"
            WScript.Sleep 100
        End If

        shell.SendKeys escapedLine
        WScript.Sleep 50
    Next

    WScript.Echo "✍️  Digitado com sucesso!"
End Sub

' ============================================================
' PONTO DE ENTRADA
' ============================================================
Sub Main()
    DisplayStatus()
    MsgBox "Nota: Este e um exemplo!" & vbCrLf & vbCrLf & _
           "Para monitorar hotkeys automaticamente, " & _
           "use a versao Python:" & vbCrLf & _
           "  python keyboard_trigger.py" & vbCrLf & vbCrLf & _
           "Ou instale 'keyboard':" & vbCrLf & _
           "  pip install keyboard", vbInformation, "Keyboard Trigger"
End Sub

' Carrega config e inicia
LoadConfig
Main
