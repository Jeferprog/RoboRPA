'============================================================
' Keyboard Trigger - digita frases prontas (VBScript puro)
' Nao precisa de admin nem instalar nada.
' Le as frases de phrases.json (na MESMA pasta deste arquivo).
'============================================================
Option Explicit

Dim objShell, objFSO, strPath, strConfig, dicFrases
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strConfig = strPath & "\phrases.json"

CarregarFrases
Menu

'------------------------------------------------------------
Sub CarregarFrases()
    Dim strTexto
    If Not objFSO.FileExists(strConfig) Then
        MsgBox "Nao encontrei o arquivo phrases.json nesta pasta:" & vbCrLf & vbCrLf & _
               strPath & vbCrLf & vbCrLf & _
               "Gere o phrases.json no keyboard_trigger_manager.html" & vbCrLf & _
               "e salve na MESMA pasta deste arquivo.", _
               16, "Keyboard Trigger"
        WScript.Quit
    End If
    Set dicFrases = CreateObject("Scripting.Dictionary")
    strTexto = objFSO.OpenTextFile(strConfig, 1).ReadAll()
    Parsear strTexto
End Sub

'------------------------------------------------------------
' Parser simples: pega todos os textos entre aspas, em ordem.
' 1o = chave, 2o = valor, 3o = chave, 4o = valor, e assim por diante.
Sub Parsear(strJSON)
    Dim pos, p1, p2, item, idx, chaveTmp
    strJSON = Replace(strJSON, vbCrLf, " ")
    strJSON = Replace(strJSON, vbCr, " ")
    strJSON = Replace(strJSON, vbLf, " ")
    pos = 1
    idx = 0
    chaveTmp = ""
    Do
        p1 = InStr(pos, strJSON, """")
        If p1 = 0 Then Exit Do
        p2 = InStr(p1 + 1, strJSON, """")
        If p2 = 0 Then Exit Do
        item = Mid(strJSON, p1 + 1, p2 - p1 - 1)
        idx = idx + 1
        If (idx Mod 2) = 1 Then
            chaveTmp = item
        Else
            item = Replace(item, "\n", vbCrLf)
            item = Replace(item, "\t", vbTab)
            item = Replace(item, "\\", "\")
            If Not dicFrases.Exists(chaveTmp) Then dicFrases.Add chaveTmp, item
        End If
        pos = p2 + 1
    Loop
End Sub

'------------------------------------------------------------
Sub Menu()
    Dim strMsg, strEsc, i, chaves
    If dicFrases.Count = 0 Then
        MsgBox "Nenhuma frase encontrada em phrases.json.", 48, "Keyboard Trigger"
        WScript.Quit
    End If
    chaves = dicFrases.Keys
    Do
        strMsg = "KEYBOARD TRIGGER" & vbCrLf & vbCrLf & _
                 "Digite o numero da frase e clique OK:" & vbCrLf & vbCrLf
        For i = 0 To dicFrases.Count - 1
            strMsg = strMsg & (i + 1) & ") " & chaves(i) & vbCrLf
        Next
        strMsg = strMsg & vbCrLf & "(Deixe em branco e clique OK para sair)"
        strEsc = InputBox(strMsg, "Keyboard Trigger")
        If strEsc = "" Then Exit Do
        If IsNumeric(strEsc) Then
            i = CLng(strEsc)
            If i >= 1 And i <= dicFrases.Count Then
                Digitar dicFrases(chaves(i - 1))
            Else
                MsgBox "Numero fora do intervalo.", 48, "Keyboard Trigger"
            End If
        Else
            MsgBox "Digite apenas o numero da frase.", 48, "Keyboard Trigger"
        End If
    Loop
End Sub

'------------------------------------------------------------
Sub Digitar(strTexto)
    Dim arr, i
    MsgBox "Clique OK e depois clique no campo onde quer escrever." & vbCrLf & vbCrLf & _
           "Voce tem 3 segundos ate a digitacao comecar.", 64, "Keyboard Trigger"
    WScript.Sleep 3000
    arr = Split(strTexto, vbCrLf)
    For i = 0 To UBound(arr)
        If i > 0 Then
            objShell.SendKeys "{ENTER}"
            WScript.Sleep 120
        End If
        objShell.SendKeys Escapar(arr(i))
        WScript.Sleep 60
    Next
End Sub

'------------------------------------------------------------
' Escapa caracteres especiais do SendKeys.
Function Escapar(s)
    s = Replace(s, "{", Chr(1))
    s = Replace(s, "}", "{}}")
    s = Replace(s, Chr(1), "{{}")
    s = Replace(s, "+", "{+}")
    s = Replace(s, "^", "{^}")
    s = Replace(s, "%", "{%}")
    s = Replace(s, "~", "{~}")
    s = Replace(s, "(", "{(}")
    s = Replace(s, ")", "{)}")
    Escapar = s
End Function
