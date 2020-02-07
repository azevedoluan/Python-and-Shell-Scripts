Private Sub CommandButton1_Click()
    Dim myFile As String
    Dim myWB As Workbook
    Dim r As Range
    Dim fNum, PosVer, PosHu, PosKwh, inicio, fim As Integer
    Dim linha, fixo, centro, data, Nome, ver, hu, kwh, ult, response As String
    Dim Dec As Long

    'Seta planilha e nome que serão usados para extrair os dados
    Set myWB = ThisWorkbook
    Nome = "Apontamento"
    ActiveSheet.Name = Nome
    
    'Seta centro e data
    centro = Worksheets(Nome).Range("B2").Value
    data = VBA.Format(Worksheets(Nome).Range("B1").Value, "dd.mm.yyyy")
    
    'Nome do arquivo txt
    myFile = "C:\Logs\" & "PRD" & centro & VBA.Format(VBA.Now, "ddMMyyyyhhmmss") & ".txt"

    'Posição inicial da Versão; da Hora; da Potencia; do inicil e fim do loop
    PosVer = 4
    PosHu = 5
    PosKwh = 6
    inicio = 27
    fim = inicio + 49
    
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
                    kwh = ";"
                Else
                    kwh = CStr(Round(r(PosKwh, j).Value, Dec)) & ";"
                End If
                ver = r(PosVer, j).Value
                If r(PosHu, j).Value = "" Then
                    hu = ";"
                Else
                    hu = CStr(Round(r(PosHu, j).Value, Dec))
                End If
                'Seta linha fixa
                fixo = data & ";" & data & ";" & CStr(r(i + 6, 1).Value) & ";" & CStr(Round(r(i + 6, j).Value, Dec)) & ";" & ver & ";" & centro & ";" & centro & ";" & CStr(r(i + 6, 3).Value) & ";" & CStr(r(i + 6, 2).Value) & ";"

                'Verifica qual é o ultimo material utilizado com valor
                For k = inicio To fim
                    If r(k, j).Value = 0 Or r(k, j).Value = "" Then
                        GoTo ProxLin
                    Else
                        utl = r(k, 4).Value
                    End If
ProxLin:
                Next k
                
                'Percorre linha dos utilizados e insere as informações no arquivo
                For k = inicio To fim
                    If r(k, j).Value = 0 Or r(k, j).Value = "" Then
                        GoTo ProxLin2
                    Else
                        If r(k, 4).Value = utl Then
                            linha = fixo & CStr(r(k, 1).Value) & ";" & CStr(Round(r(k, j).Value, Dec)) & ";" & CStr(r(k, 3).Value) & ";" & CStr(r(k, 2).Value) & ";" & CStr(Round(r(i + 6, j).Value, Dec)) & ";" & hu & ";" & kwh
                            Print #fNum, linha
                        Else
                            linha = fixo & CStr(r(k, 1).Value) & ";" & CStr(Round(r(k, j).Value, Dec)) & ";" & CStr(r(k, 3).Value) & ";" & CStr(r(k, 2).Value) & ";"
                            Print #fNum, linha
                        End If
                    End If
ProxLin2:
                Next k
            End If
ProxCol:
        Next j
        If C = 20 Then
            i = i + 57
            C = 0
            PosVer = i + 4
            PosHu = i + 5
            PosKwh = i + 6
            inicio = i + 27
            fim = inicio + 49
        End If
    Next i

    'Fecha arquivo
    Close #fNum
    
    'Botão de "OK" para fim da execução
    response = MsgBox("Processamento Concluído", vbOKOnly)
    
End Sub