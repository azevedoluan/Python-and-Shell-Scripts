Private Sub CommandButton1_Click()
    Dim gCon As ADODB.Connection
    Dim gRS As ADODB.Recordset
    Dim SqlTotal As String
    Dim SqlPend As String
    Dim SqlNmig As String
    Dim SqlLib As String
    Dim SqlEand As String
    Dim i As Long
    Dim j As Long
    Dim k As Long
    Dim Arr As Variant
    Dim Tc As String
    Dim Valor1 As Long
    Dim Valor2 As Long
    Dim DataAux As String
    Dim Nome As String
    Dim Aba As Long
    Dim Titulo1 As String
    Dim Titulo2 As String
    Dim Resposta As String
    
    DataAux = Format(Date, "dd mm yy")
    Nome = DataAux
    Arr = Array("C", "V", "MT", "T", "E")
    
    'Adiciona nova aba
    Sheets.Add After:=Sheets(Sheets.Count)
    ActiveSheet.Name = Nome
    
    'Cabeçalho
    Worksheets(Nome).Range("A1").Value = "Tipo de Dado"
    Worksheets(Nome).Range("B1").Value = "Total"
    Worksheets(Nome).Range("C1").Value = "Pendente"
    Worksheets(Nome).Range("D1").Value = "Liberado"
    Worksheets(Nome).Range("E1").Value = "Não Migrar"
    Worksheets(Nome).Range("F1").Value = "Em andamento"
    Worksheets(Nome).Range("G1").Value = "Carga de teste gerada"
    Worksheets(Nome).Range("H1").Value = "Carga de teste validada"
    Worksheets(Nome).Range("I1").Value = "%Concluído"
    Worksheets(Nome).Range("A1:I1").Interior.Color = RGB(68, 84, 106)
    Worksheets(Nome).Range("A1:I1").Font.Color = RGB(255, 255, 255)
    Worksheets(Nome).Range("A1:I1").Font.Bold = True
    
    'Dados
    Worksheets(Nome).Range("A2").Value = "Cliente/Obra"
    Worksheets(Nome).Range("A3").Value = "Fornecedor"
    Worksheets(Nome).Range("A4").Value = "Motorista"
    Worksheets(Nome).Range("A5").Value = "Transportador"
    Worksheets(Nome).Range("A6").Value = "Funcionário"
    Worksheets(Nome).Range("A7").Value = "Material - Saneado Astrein"
    Worksheets(Nome).Range("A8").Value = "Material - Saneado CRH"
    Worksheets(Nome).Range("A9").Value = "Infrações"
    Worksheets(Nome).Range("A10").Value = "Veículo"
    Worksheets(Nome).Range("A11").Value = "Itinerário"
    Worksheets(Nome).Range("A12").Value = "Limite de crédito"
    Worksheets(Nome).Range("A13").Value = "Preço"
    Worksheets(Nome).Range("A14").Value = "Ativo fixo"
    Worksheets(Nome).Range("A15").Value = "Saldo Estoque"
    Worksheets(Nome).Range("A16").Value = "CAP em aberto"
    Worksheets(Nome).Range("A17").Value = "CAR em aberto"
    Worksheets(Nome).Range("A18").Value = "Função Parceiro (Cliente x Obra)"
    Worksheets(Nome).Range("A19").Value = "Relações de Crédito"
    
    
    'Conecta no banco de dados
    Set gCon = New ADODB.Connection
    gCon.Open "Provider=OraOLEDB.Oracle;Data Source=BRTRFPD1;User Id=<user>;Password=<user>;"
    
    'Select BP
    For i = 0 To 4
        Tc = Arr(i)
        If Tc = "C" Then
            SqlTotal = "Select count(*) as TOTAL from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('C','CE')"
            SqlPend = "Select count(*) as PEND from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('C','CE') and STATUS = 'P'"
            SqlLib = "Select count(*) as LIB from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('C','CE') and STATUS = 'L'"
            SqlNmig = "Select count(*) as NMIG from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('C','CE') and STATUS IN ('N','O')"
            SqlEand = "Select count(*) as EAND from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('C','CE') and STATUS = 'E'"
            
            Set gRS = gCon.Execute(SqlTotal)
            If Not gRS.EOF Then
                ActiveSheet.Range("B" & i + 2) = gRS!Total
            Else
                ActiveSheet.Range("B" & i + 2) = 0
            End If
            gRS.Close
            
            Set gRS = gCon.Execute(SqlPend)
            If Not gRS.EOF Then
                ActiveSheet.Range("C" & i + 2) = gRS!PEND
            Else
                ActiveSheet.Range("C" & i + 2) = 0
            End If
            gRS.Close
            
            Set gRS = gCon.Execute(SqlLib)
            If Not gRS.EOF Then
                ActiveSheet.Range("D" & i + 2) = gRS!LIB
            Else
                ActiveSheet.Range("D" & i + 2) = 0
            End If
            gRS.Close
            
            Set gRS = gCon.Execute(SqlNmig)
            If Not gRS.EOF Then
                ActiveSheet.Range("E" & i + 2) = gRS!NMIG
            Else
                ActiveSheet.Range("E" & i + 2) = 0
            End If
            gRS.Close
            
            Set gRS = gCon.Execute(SqlEand)
            If Not gRS.EOF Then
                ActiveSheet.Range("F" & i + 2) = gRS!EAND
            Else
                ActiveSheet.Range("F" & i + 2) = 0
            End If
            gRS.Close
            
        Else
            If Tc = "T" Then
                SqlTotal = "Select count(*) as TOTAL from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('T','TB')"
                SqlPend = "Select count(*) as PEND from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('T','TB') and STATUS = 'P'"
                SqlLib = "Select count(*) as LIB from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('T','TB') and STATUS = 'L'"
                SqlNmig = "Select count(*) as NMIG from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('T','TB') and STATUS IN ('N','O')"
                SqlEand = "Select count(*) as EAND from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO in ('T','TB') and STATUS = 'E'"
                
                Set gRS = gCon.Execute(SqlTotal)
                If Not gRS.EOF Then
                    ActiveSheet.Range("B" & i + 2) = gRS!Total
                Else
                    ActiveSheet.Range("B" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlPend)
                If Not gRS.EOF Then
                    ActiveSheet.Range("C" & i + 2) = gRS!PEND
                Else
                    ActiveSheet.Range("C" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlLib)
                If Not gRS.EOF Then
                    ActiveSheet.Range("D" & i + 2) = gRS!LIB
                Else
                    ActiveSheet.Range("D" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlNmig)
                If Not gRS.EOF Then
                    ActiveSheet.Range("E" & i + 2) = gRS!NMIG
                Else
                    ActiveSheet.Range("E" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlEand)
                If Not gRS.EOF Then
                    ActiveSheet.Range("F" & i + 2) = gRS!EAND
                Else
                    ActiveSheet.Range("F" & i + 2) = 0
                End If
                gRS.Close
            
            Else
                SqlTotal = "Select count(*) as TOTAL from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO = '" & Tc & "' "
                SqlPend = "Select count(*) as PEND from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO = '" & Tc & "'  and STATUS = 'P'"
                SqlLib = "Select count(*) as LIB from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO = '" & Tc & "'  and STATUS = 'L'"
                SqlNmig = "Select count(*) as NMIG from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO = '" & Tc & "'  and STATUS IN ('N','O')"
                SqlEand = "Select count(*) as EAND from STAGING_FORNECEDOR_CLIENTE where TIPO_CADASTRO = '" & Tc & "'  and STATUS = 'E'"
                
                Set gRS = gCon.Execute(SqlTotal)
                If Not gRS.EOF Then
                    ActiveSheet.Range("B" & i + 2) = gRS!Total
                Else
                    ActiveSheet.Range("B" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlPend)
                If Not gRS.EOF Then
                    ActiveSheet.Range("C" & i + 2) = gRS!PEND
                Else
                    ActiveSheet.Range("C" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlLib)
                If Not gRS.EOF Then
                    ActiveSheet.Range("D" & i + 2) = gRS!LIB
                Else
                    ActiveSheet.Range("D" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlNmig)
                If Not gRS.EOF Then
                    ActiveSheet.Range("E" & i + 2) = gRS!NMIG
                Else
                    ActiveSheet.Range("E" & i + 2) = 0
                End If
                gRS.Close
                
                Set gRS = gCon.Execute(SqlEand)
                If Not gRS.EOF Then
                    ActiveSheet.Range("F" & i + 2) = gRS!EAND
                Else
                    ActiveSheet.Range("F" & i + 2) = 0
                End If
                gRS.Close
            End If
        End If
    Next i
    
    'Select Material - Saneado CRH
    SqlTotal = "Select count(*) as TOTAL from STAGING_MATERIAL"
    SqlPend = "Select count(*) as PEND from STAGING_MATERIAL where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_MATERIAL where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_MATERIAL where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_MATERIAL where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
            ActiveSheet.Range("B8") = gRS!Total
    Else
        ActiveSheet.Range("B8") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C8") = gRS!PEND
    Else
        ActiveSheet.Range("C8") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D8") = gRS!LIB
    Else
        ActiveSheet.Range("D8") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E8") = gRS!NMIG
    Else
        ActiveSheet.Range("E8") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F8") = gRS!EAND
    Else
        ActiveSheet.Range("F8") = 0
    End If
    gRS.Close

    'Select Material - Saneado Astrein
    SqlTotal = "Select count(*) as TOTAL from STAGING_ITEMMESTRE"
    SqlPend = "Select count(*) as TOTAL from STAGING_ITEMMESTRE"
    SqlLib = "Select count(*) as TOTAL from STAGING_ITEMMESTRE"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        If gRS!Total > 26000 Then
            ActiveSheet.Range("B7") = gRS!Total
        Else
            ActiveSheet.Range("B7") = 26000
        End If
    Else
        ActiveSheet.Range("B7") = 26000
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C7") = 26000 - gRS!Total
    Else
        ActiveSheet.Range("C7") = 26000
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D7") = gRS!Total
    Else
        ActiveSheet.Range("D7") = 0
    End If
    gRS.Close

    'Select Infrações
    SqlTotal = "Select count(*) as TOTAL from STAGING_INFRACOES"
    SqlPend = "Select count(*) as PEND from STAGING_INFRACOES where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_INFRACOES where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_INFRACOES where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_INFRACOES where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
            ActiveSheet.Range("B9") = gRS!Total
    Else
        ActiveSheet.Range("B9") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C9") = gRS!PEND
    Else
        ActiveSheet.Range("C9") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D9") = gRS!LIB
    Else
        ActiveSheet.Range("D9") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E9") = gRS!NMIG
    Else
        ActiveSheet.Range("E9") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F9") = gRS!EAND
    Else
        ActiveSheet.Range("F9") = 0
    End If
    gRS.Close
    
    'Select Veículo
    SqlTotal = "Select count(*) as TOTAL from STAGING_VEICULO"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        If gRS!Total > 2000 Then
            ActiveSheet.Range("B10") = gRS!Total
        Else
            ActiveSheet.Range("B10") = 2000
        End If
        ActiveSheet.Range("C10") = 0
        ActiveSheet.Range("D10") = gRS!Total
        ActiveSheet.Range("E10") = 0
        ActiveSheet.Range("F10") = 0
    Else
        ActiveSheet.Range("B10") = 2000
        ActiveSheet.Range("C10") = 0
        ActiveSheet.Range("D10") = 0
        ActiveSheet.Range("E10") = 0
        ActiveSheet.Range("F10") = 0
    End If
    gRS.Close
    
    'Select Itinerário
    SqlTotal = "Select count(*) as TOTAL from STAGING_ITINERARIO"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        If gRS!Total > 1400 Then
            ActiveSheet.Range("B11") = gRS!Total
        Else
            ActiveSheet.Range("B11") = 1400
        End If
        ActiveSheet.Range("C11") = 0
        ActiveSheet.Range("D11") = gRS!Total
        ActiveSheet.Range("E11") = 0
        ActiveSheet.Range("F11") = 0
    Else
        ActiveSheet.Range("B11") = 1400
        ActiveSheet.Range("C11") = 0
        ActiveSheet.Range("D11") = 0
        ActiveSheet.Range("E11") = 0
        ActiveSheet.Range("F11") = 0
    End If
    gRS.Close
    
    
    'Select Limite de Crédito
    SqlTotal = "Select count(*) as TOTAL from STAGING_LIMITE_CREDITO"
    SqlPend = "Select count(*) as PEND from STAGING_LIMITE_CREDITO where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_LIMITE_CREDITO where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_LIMITE_CREDITO where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_LIMITE_CREDITO where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        ActiveSheet.Range("B12") = gRS!Total
    Else
        ActiveSheet.Range("B12") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C12") = gRS!PEND
    Else
        ActiveSheet.Range("C12") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D12") = gRS!LIB
    Else
        ActiveSheet.Range("D12") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E12") = gRS!NMIG
    Else
        ActiveSheet.Range("E12") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F12") = gRS!EAND
    Else
        ActiveSheet.Range("F12") = 0
    End If
    gRS.Close
    
    'Select Preço
    SqlTotal = "Select count(*) as TOTAL from STAGING_PRECO"
    SqlPend = "Select count(*) as PEND from STAGING_PRECO where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_PRECO where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_PRECO where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_PRECO where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        ActiveSheet.Range("B13") = gRS!Total
    Else
        ActiveSheet.Range("B13") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C13") = gRS!PEND
    Else
        ActiveSheet.Range("C13") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D13") = gRS!LIB
    Else
        ActiveSheet.Range("D13") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E13") = gRS!NMIG
    Else
        ActiveSheet.Range("E13") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F13") = gRS!EAND
    Else
        ActiveSheet.Range("F13") = 0
    End If
    gRS.Close
    
    Select Ativo Fixo
    SqlTotal = "Select count(*) as TOTAL from STAGING_ATIVOFIXO"
    SqlPend = "Select count(*) as PEND from STAGING_ATIVOFIXO where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_ATIVOFIXO where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_ATIVOFIXO where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_ATIVOFIXO where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        ActiveSheet.Range("B14") = gRS!TOTAL
    Else
        ActiveSheet.Range("B14") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C14") = gRS!PEND
    Else
        ActiveSheet.Range("C14") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D14") = gRS!LIB
    Else
        ActiveSheet.Range("D14") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E14") = gRS!NMIG
    Else
        ActiveSheet.Range("E14") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F14") = gRS!EAND
    Else
        ActiveSheet.Range("F14") = 0
    End If
    gRS.Close
    
    Select Saldo de Estoque
    SqlTotal = "Select count(*) as TOTAL from STAGING_SALDOESTOQUE"
    SqlPend = "Select count(*) as PEND from STAGING_SALDOESTOQUE where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_SALDOESTOQUE where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_SALDOESTOQUE where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_SALDOESTOQUE where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        ActiveSheet.Range("B15") = gRS!TOTAL
    Else
        ActiveSheet.Range("B15") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C15") = gRS!PEND
    Else
        ActiveSheet.Range("C15") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D15") = gRS!LIB
    Else
        ActiveSheet.Range("D15") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E15") = gRS!NMIG
    Else
        ActiveSheet.Range("E15") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F15") = gRS!EAND
    Else
        ActiveSheet.Range("F15") = 0
    End If
    gRS.Close
    
    'Select CAP
    SqlTotal = "Select count(*) as TOTAL from STAGING_CAP WHERE SITUACAO <> 'P'"
    SqlPend = "Select count(*) as PEND from STAGING_CAP where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_CAP where STATUS = 'L' AND SITUACAO <> 'P'"
    SqlNmig = "Select count(*) as NMIG from STAGING_CAP where STATUS IN ('N','O') AND SITUACAO <> 'P'"
    SqlEand = "Select count(*) as EAND from STAGING_CAP where STATUS = 'E' AND SITUACAO <> 'P'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        ActiveSheet.Range("B16") = gRS!Total
    Else
        ActiveSheet.Range("B16") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C16") = gRS!PEND
    Else
        ActiveSheet.Range("C16") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D16") = gRS!LIB
    Else
        ActiveSheet.Range("D16") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E16") = gRS!NMIG
    Else
        ActiveSheet.Range("E16") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F16") = gRS!EAND
    Else
        ActiveSheet.Range("F16") = 0
    End If
    gRS.Close
    
    'Select CAR
    SqlTotal = "Select count(*) as TOTAL from STAGING_CAR"
    SqlPend = "Select count(*) as PEND from STAGING_CAR where STATUS = 'P'"
    SqlLib = "Select count(*) as LIB from STAGING_CAR where STATUS = 'L'"
    SqlNmig = "Select count(*) as NMIG from STAGING_CAR where STATUS IN ('N','O')"
    SqlEand = "Select count(*) as EAND from STAGING_CAR where STATUS = 'E'"
    
    Set gRS = gCon.Execute(SqlTotal)
    If Not gRS.EOF Then
        ActiveSheet.Range("B17") = gRS!Total
    Else
        ActiveSheet.Range("B17") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlPend)
    If Not gRS.EOF Then
        ActiveSheet.Range("C17") = gRS!PEND
    Else
        ActiveSheet.Range("C17") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlLib)
    If Not gRS.EOF Then
        ActiveSheet.Range("D17") = gRS!LIB
    Else
        ActiveSheet.Range("D17") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlNmig)
    If Not gRS.EOF Then
        ActiveSheet.Range("E17") = gRS!NMIG
    Else
        ActiveSheet.Range("E17") = 0
    End If
    gRS.Close
    
    Set gRS = gCon.Execute(SqlEand)
    If Not gRS.EOF Then
        ActiveSheet.Range("F17") = gRS!EAND
    Else
        ActiveSheet.Range("F17") = 0
    End If
    gRS.Close
    gCon.Close
    
    'Obtem aba anterior
    Aba = ActiveSheet.Index - 1
    
    'Seta valores da primeira aba para carga de teste gerada e/ou validada
    If Aba = 1 Then
        For k = 2 To 17
            Worksheets(Nome).Range("H" & j).Value = "Não"
        Next k
    Else
        'Seta valores das próximas abas para carga de teste gerada e/ou validada
        For j = 2 To 17
            If Worksheets(Aba).Range("H" & j).Value = "Sim" Then
                Worksheets(Nome).Range("H" & j).Value = "Sim"
            Else
                Worksheets(Nome).Range("H" & j).Value = "Não"
            End If
            
            Worksheets(Nome).Range("G" & j).Value = Worksheets(Aba).Range("G" & j).Value
            
        Next j
    End If
    

    
    For i = 2 To 17
        Valor1 = 0
        Valor2 = 0
        Valor1 = Worksheets(Nome).Range("B" & i).Value
        Valor2 = Worksheets(Nome).Range("D" & i).Value + Worksheets(Nome).Range("E" & i).Value
        
        If Valor2 = 0 Then
            Worksheets(Nome).Range("I" & i).Value = 0
            Worksheets(Nome).Range("I" & i).NumberFormat = "0.00%"
        Else
            Worksheets(Nome).Range("I" & i).Value = Valor2 / Valor1
            Worksheets(Nome).Range("I" & i).NumberFormat = "0.00%"
        End If
    Next i
    
    
    If Aba = 1 Then
        For k = 18 to 19
            Worksheets(Nome).Range("G" & k).Value = ""
            Worksheets(Nome).Range("G" & k).Value = "Não"
        Next k
    Else
        For j = 18 To 19
            Worksheets(Nome).Range("G" & j).Value = Worksheets(Aba).Range("G" & j).Value
            If Worksheets(Aba).Range("H" & j).Value = "Sim" Then
                Worksheets(Nome).Range("H" & j).Value = "Sim"
            Else
                Worksheets(Nome).Range("H" & j).Value = "Não"
            End If
        Next j
    End If

    'Ajusta tamanho e formato das colunas
    Worksheets(Nome).Range("B2:F17").NumberFormat = "0"
    Worksheets(Nome).Range("G2:G19").NumberFormat = "dd/mm/yyyy"
    Worksheets(Nome).Range("A:I").AutoFilter
    Worksheets(Nome).Columns("A:I").AutoFit
End Sub