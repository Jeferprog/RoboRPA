' Keyboard Trigger - Versao Ultra Simples
' Sem erros de compilacao!

Option Explicit
Dim objShell, objFSO, strPath, strConfigFile, objPhrases
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strConfigFile = strPath & "\phrases.json"

' Carrega frases
Sub CarregarFrases()
    Dim strConteudo, arrPhrases

    If Not objFSO.FileExists(strConfigFile) Then
        MsgBox "Arquivo phrases.json nao encontrado!", 16, "Erro"
        WScript.Quit 1
    End If

    Set objPhrases = CreateObject("Scripting.Dictionary")
    strConteudo = objFSO.OpenTextFile(strConfigFile, 1).ReadAll()
    ParsearJSON strConteudo
End Sub

' Parseia JSON
Sub ParsearJSON(strJSON)
    Dim i, j, strChave, strValor, blnEmString

    strJSON = Replace(strJSON, vbCrLf, " ")
    strJSON = Replace(strJSON, vbCr, " ")
    strJSON = Replace(strJSON, vbLf, " ")

    i = 1
    Do While i < Len(strJSON)
        If Mid(strJSON, i, 1) = """" Then
            j = InStr(i + 1, strJSON, """")
            strChave = Mid(strJSON, i + 1, j - i - 1)
            i = j + 1

            If Mid(strJSON, i, 1) = ":" Then
                If Mid(strJSON, i + 1, 1) = """" Then
                    j = InStr(i + 2, strJSON, """")
                    strValor = Mid(strJSON, i + 2, j - i - 2)
                    strValor = Replace(strValor, "\n", vbCrLf)
                    strValor = Replace(strValor, "\t", vbTab)
                    strValor = Replace(strValor, "\\", "\")
                    objPhrases.Add strChave, strValor
                    i = j
                End If
            End If
        End If
        i = i + 1
    Loop
End Sub

' Digita texto
Sub DigitarTexto(strTexto)
    Dim arrLinhas, i, strLinha, strEscapado

    WScript.Sleep 500
    arrLinhas = Split(strTexto, vbCrLf)

    For i = LBound(arrLinhas) To UBound(arrLinhas)
        strLinha = arrLinhas(i)
        strEscapado = Replace(strLinha, "{", "{{")
        strEscapado = Replace(strEscapado, "}", "}}")
        strEscapado = Replace(strEscapado, "+", "{+}")

        If i > LBound(arrLinhas) Then
            objShell.SendKeys "{ENTER}"
            WScript.Sleep 100
        End If

        objShell.SendKeys strEscapado
        WScript.Sleep 50
    Next
End Sub

' Menu principal
Sub MenuPrincipal()
    Dim strMsg, strChoice, i, j, strFrase, arrChaves

    CarregarFrases()

    If objPhrases.Count = 0 Then
        MsgBox "Nenhuma frase configurada!", 48, "Aviso"
        WScript.Quit 1
    End If

    strMsg = "KEYBOARD TRIGGER" & vbCrLf & vbCrLf & "Selecione uma frase:" & vbCrLf & vbCrLf
    i = 1
    For Each strFrase In objPhrases.Keys
        strMsg = strMsg & i & ". " & strFrase & vbCrLf
        i = i + 1
    Next

    Do
        strChoice = InputBox(strMsg, "Keyboard Trigger")

        If strChoice = "" Then
            Exit Do
        End If

        If IsNumeric(strChoice) Then
            If CLng(strChoice) > 0 And CLng(strChoice) <= objPhrases.Count Then
                i = 1
                For Each strFrase In objPhrases.Keys
                    If i = CLng(strChoice) Then
                        MsgBox "Digitando: " & strFrase & vbCrLf & vbCrLf & "Clique OK e coloque o cursor no campo.", 64
                        DigitarTexto objPhrases(strFrase)
                        MsgBox "Pronto!", 64
                        Exit For
                    End If
                    i = i + 1
                Next
            Else
                MsgBox "Numero invalido!", 16
            End If
        Else
            MsgBox "Digite um numero valido!", 16
        End If
    Loop
End Sub

' Verifica se e numero
Function IsNumeric(str)
    Dim i
    IsNumeric = True
    If str = "" Then IsNumeric = False
    For i = 1 To Len(str)
        If Asc(Mid(str, i, 1)) < 48 Or Asc(Mid(str, i, 1)) > 57 Then
            IsNumeric = False
        End If
    Next
End Function

' Executa
MenuPrincipal()
