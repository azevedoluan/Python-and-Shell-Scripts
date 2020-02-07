Private Sub CommandButton1_Click()
    Dim myFile As String
    Dim myWB As Workbook
    Dim r As Range
    Dim fNum, PosEqp, PosHu, PosKwh  As Integer
    Dim linha, centro, data, Nome, Eqp, hu, kwh, response As String
    Dim Dec As Long

    'Seta planilha e nome que serão usados para extrair os dados
    Set myWB = ThisWorkbook
    Nome = "Apontamento KPI"
    ActiveSheet.Name = Nome
    
    'Seta centro e data
    centro = Worksheets(Nome).Range("B2").Value
    data = VBA.Format(Worksheets(Nome).Range("B1").Value, "dd.mm.yyyy")
    
    'Nome do arquivo txt
    myFile = "C:\Logs\" & "KPI" & centro & VBA.Format(VBA.Now, "ddMMyyyyhhmmss") & ".txt"

    'Posição inicial do Equipamento; da Hora; da Potencia; do inicio e fim do loop
    PosEqp = 2
    PosHu = 5
    PosKwh = 6
 
    
    'Contador de linhas para controlar os saltos de cada bloco
    C = 0
    'Seta casas decimais
    Dec = 2
    'Linha que sera inserida no arquivo
    linha = ""
    'Id do Arquivo
    fNum = FreeFile
    'Range de busca dos dados
    Set r = Range("A3:P617")
    'Abre o arquivo para salvar as informações
    Open myFile For Output As #fNum
    
    'Percorre linhas
    For i = 1 To r.Rows.Count - 6
        'Incrementa o contador que controla as linhas
        C = C + 1
        'Percorre colunas
        For j = 7 To r.Columns.Count
            'Se não tem valor vai para a próxima coluna
            If r(i + 6, j).Value = 0 Or r(i + 6, j).Value = "" Then
                GoTo ProxCol
            Else
                'Seta valores de potência e hora
                If r(PosKwh, j).Value = "" Then
                    kwh = " ;"
                Else
                    kwh = CStr(Round(r(PosKwh, j).Value, Dec))
                End If
                Eqp = r(PosEqp, j).Value
                If r(PosHu, j).Value = "" Then
                    hu = " "
                Else
                    hu = CStr(Round(r(PosHu, j).Value, Dec))
                End If
                'Seta linha fixa
                linha = data & ";" & CStr(r(i + 6, 1).Value) & ";" & centro & ";" & Eqp & ";" & hu & ";" & CStr(Round(r(i + 6, j).Value, Dec)) & ";" & CStr(r(i + 6, 3).Value) & ";" & kwh
                Print #fNum, linha
            End If
ProxCol:
        Next j
        If C = 20 Then
            i = i + 7
            C = 0
            PosEqp = i + 2
            PosHu = i + 5
            PosKwh = i + 6
        End If
    Next i

    'Fecha arquivo
    Close #fNum
    
    'Botão de "OK" para fim da execução
    response = MsgBox("Processamento Concluído", vbOKOnly)
    
End Sub