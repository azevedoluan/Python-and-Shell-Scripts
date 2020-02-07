Private Sub CommandButton1_Click()
    Dim myFile, centro As String
    Dim myWB As Workbook
    Dim r As Range
    Dim fNum As Integer


    'Seta planilha e nome que serão usados para extrair os dados
    Set myWB = ThisWorkbook
    Nome = "Apontamento QUALIDADE"
    ActiveSheet.Name = Nome
    
	'Range de busca dos dados
    Set r = Range("B2:H100")
    'Nome do arquivo txt
	centro = Worksheets(Nome).Range("D3").Value
    myFile = "C:\Logs\" & "QUA" & centro & VBA.Format(VBA.Now, "ddMMyyyyhhmmss") & ".txt"


    'Linha que sera inserida no arquivo
    linha = ""
    'Id do Arquivo
    fNum = FreeFile

    'Abre o arquivo para salvar as informações
    Open myFile For Output As #fNum
    
    'Percorre linhas
    For i = 2 To r.Rows.Count
		If IsEmpty(r(i , 1).Value) then
			exit for
		End If
		'Percorre colunas
		linha = "" 
		For j = 1 To r.Columns.Count
			'Se não tem valor vai para a próxima coluna
			If  IsEmpty(r(i ,j).Value)  then
				GoTo ProxCol
			Else
			
				If linha = "" then 

					linha =  r(i ,j)
					
				ElseIf j = 7 and IsEmpty(r(i, j).Value) then
					
					linha = linha & ";" & r(i, j) & ";"
				Else
				
					linha = linha & ";" & r(i, j) 
					
				End If
				
			End If
ProxCol:
		Next j
		
		Print #fNum, linha
	Next i
		
		
    'Fecha arquivo
    Close #fNum
    
    'Botão de "OK" para fim da execução
    response = MsgBox("Processamento Concluído", vbOKOnly)
    
End Sub


