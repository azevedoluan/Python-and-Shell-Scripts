Private Sub CommandButton1_Click()
Dim gSQL As String
Dim gCon As ADODB.Connection
Dim gRS As ADODB.Recordset

Set gCon = New ADODB.Connection
gCon.Open "Provider=OraOLEDB.Oracle;Data Source=BRERPPD1;User Id=<user>;Password=<password>;"
Dim i As Long
Dim Item As Long
Dim Sql As String


Item = Range("B2").Value

i = 5

    gSQL = "SELECT DISTINCT A.IMITM COD_ITEM, "
    gSQL = gSQL & "TRIM(A.IMDSC1)||' '||TRIM(A.IMDSC2) DESC_ITEM, "
    gSQL = gSQL & "D.FILIAL FILIAL, "
    gSQL = gSQL & "D.EXISTENTE EXISTENTE, "
    gSQL = gSQL & "D.DISPONIVEL, "
    gSQL = gSQL & "TO_CHAR(E.TIPO_PEDIDO) TIPO_PEDIDO, "
    gSQL = gSQL & "TO_CHAR(E.NUM_PEDIDO) NUM_PEDIDO, "
    gSQL = gSQL & "TO_CHAR(E.VALOR_RECEBER) VALOR_RECEBER, "
    gSQL = gSQL & "TO_CHAR(F.CONTRATO) CONTRATO, "
    gSQL = gSQL & "'' QTD_NFE "
    gSQL = gSQL & "FROM BRPD285DTA.F4101 A "
    gSQL = gSQL & "LEFT JOIN (SELECT DISTINCT LIITM AS CODIGO, TRIM(LIMCU) AS FILIAL ,SUM(LIPQOH)/10000 AS EXISTENTE,SUM(LIPREQ)/10000 DISPONIVEL "
    gSQL = gSQL & "FROM BRPD285DTA.F41021 "
    gSQL = gSQL & "WHERE TRIM(LIMCU) IN ('BR13120','BR13020','BR13030','BR13040','BR13100') "
    gSQL = gSQL & "GROUP BY LIITM, TRIM(LIMCU)) D ON A.IMITM=D.CODIGO "
    gSQL = gSQL & "LEFT JOIN (SELECT PDITM, "
    gSQL = gSQL & "TRIM(PDMCU) AS FILIAL, "
    gSQL = gSQL & "LISTAGG(TRIM(TO_CHAR(PDDCTO)), '; ') WITHIN GROUP (ORDER BY PDITM) AS TIPO_PEDIDO, "
    gSQL = gSQL & "LISTAGG(PDDOCO, '; ') WITHIN GROUP (ORDER BY PDITM) AS NUM_PEDIDO, "
    gSQL = gSQL & "LISTAGG((PDAOPN/100), '; ') WITHIN GROUP (ORDER BY PDITM) AS VALOR_RECEBER "
    gSQL = gSQL & "FROM BRPD285DTA.F4311 WHERE PDDCTO IN ('OP','OQ','OR') AND PDAOPN > 1 "
    gSQL = gSQL & "GROUP BY PDITM,TRIM(PDMCU)) E ON A.IMITM=E.PDITM "
    gSQL = gSQL & "LEFT JOIN (SELECT distinct DPITM, "
    gSQL = gSQL & "LISTAGG(trim(TO_CHAR(DPDMCT)), '; ') WITHIN GROUP (ORDER BY DPITM) AS CONTRATO "
    gSQL = gSQL & "FROM BRPD285DTA.F38012 "
    gSQL = gSQL & "GROUP BY DPITM) F ON A.IMITM=F.DPITM "
    gSQL = gSQL & "WHERE A.IMITM IN (SELECT PDITM "
    gSQL = gSQL & "FROM BRPD285DTA.F4311 "
    gSQL = gSQL & "WHERE PDDCTO IN ('OP','OQ','OR') "
    gSQL = gSQL & "AND TRIM(PDMCU) IN ('BR13120','BR13020','BR13030','BR13040','BR13100') "
    gSQL = gSQL & "AND PDAOPN > 1) "
    gSQL = gSQL & "AND A.IMITM = '" & Item & "' "
    gSQL = gSQL & "UNION "
    gSQL = gSQL & "SELECT DISTINCT A.IMITM COD_ITEM, "
    gSQL = gSQL & "TRIM(A.IMDSC1)||' '||TRIM(A.IMDSC2) DESC_ITEM, "
    gSQL = gSQL & "D.FILIAL FILIAL, "
    gSQL = gSQL & "D.EXISTENTE EXISTENTE, "
    gSQL = gSQL & "D.DISPONIVEL, "
    gSQL = gSQL & "'' TIPO_PEDIDO, "
    gSQL = gSQL & "'' NUM_PEDIDO, "
    gSQL = gSQL & "'' VALOR_RECEBER, "
    gSQL = gSQL & "TO_CHAR(F.CONTRATO) CONTRATO, "
    gSQL = gSQL & "'' QTD_NFE "
    gSQL = gSQL & "FROM BRPD285DTA.F4101 A "
    gSQL = gSQL & "LEFT JOIN (SELECT DISTINCT LIITM AS CODIGO, TRIM(LIMCU) AS FILIAL ,SUM(LIPQOH)/10000 AS EXISTENTE,SUM(LIPREQ)/10000 DISPONIVEL "
    gSQL = gSQL & "FROM BRPD285DTA.F41021 "
    gSQL = gSQL & "WHERE TRIM(LIMCU) IN ('BR13120','BR13020','BR13030','BR13040','BR13100') "
    gSQL = gSQL & "GROUP BY LIITM, TRIM(LIMCU)) D ON A.IMITM=D.CODIGO "
    gSQL = gSQL & "LEFT JOIN (SELECT distinct DPITM, "
    gSQL = gSQL & "LISTAGG(trim(TO_CHAR(DPDMCT)), '; ') WITHIN GROUP (ORDER BY DPITM) AS CONTRATO "
    gSQL = gSQL & "FROM BRPD285DTA.F38012 "
    gSQL = gSQL & "GROUP BY DPITM) F ON A.IMITM=F.DPITM "
    gSQL = gSQL & "WHERE A.IMITM NOT IN (SELECT PDITM "
    gSQL = gSQL & "FROM BRPD285DTA.F4311 "
    gSQL = gSQL & "WHERE PDDCTO IN ('OP','OQ','OR') "
    gSQL = gSQL & "AND TRIM(PDMCU) IN ('BR13120','BR13020','BR13030','BR13040','BR13100') "
    gSQL = gSQL & "AND PDAOPN > 1) "
    gSQL = gSQL & "AND A.IMITM = '" & Item & "' "
    gSQL = gSQL & "UNION "
    gSQL = gSQL & "SELECT DISTINCT A.IMITM COD_ITEM, "
    gSQL = gSQL & "TRIM(A.IMDSC1)||' '||TRIM(A.IMDSC2) DESC_ITEM, "
    gSQL = gSQL & "D.FILIAL FILIAL, "
    gSQL = gSQL & "D.EXISTENTE EXISTENTE, "
    gSQL = gSQL & "D.DISPONIVEL, "
    gSQL = gSQL & "'' TIPO_PEDIDO, "
    gSQL = gSQL & "'' NUM_PEDIDO, "
    gSQL = gSQL & "'' VALOR_RECEBER, "
    gSQL = gSQL & "TO_CHAR(F.CONTRATO) CONTRATO, "
    gSQL = gSQL & "TO_CHAR(QTD_NFE) QTD_NFE "
    gSQL = gSQL & "FROM BRPD285DTA.F4101 A "
    gSQL = gSQL & "LEFT JOIN (SELECT DISTINCT LIITM AS CODIGO, TRIM(LIMCU) AS FILIAL ,SUM(LIPQOH)/10000 AS EXISTENTE,SUM(LIPREQ)/10000 DISPONIVEL "
    gSQL = gSQL & "FROM BRPD285DTA.F41021 "
    gSQL = gSQL & "WHERE TRIM(LIMCU) IN ('BR13120','BR13020','BR13030','BR13040','BR13100') "
    gSQL = gSQL & "GROUP BY LIITM, TRIM(LIMCU)) D ON A.IMITM=D.CODIGO "
    gSQL = gSQL & "LEFT JOIN (SELECT distinct DPITM, "
    gSQL = gSQL & "LISTAGG(trim(TO_CHAR(DPDMCT)), '; ') WITHIN GROUP (ORDER BY DPITM) AS CONTRATO "
    gSQL = gSQL & "FROM BRPD285DTA.F38012 "
    gSQL = gSQL & "GROUP BY DPITM) F ON A.IMITM=F.DPITM "
    gSQL = gSQL & "LEFT JOIN (SELECT FDITM, TRIM(FDMCU) AS FILIAL, COUNT(*) AS QTD_NFE "
    gSQL = gSQL & "FROM BRPD285DTA.F7611B "
    gSQL = gSQL & "WHERE FDLTTR = 760 AND FDNXTR = 780 "
    gSQL = gSQL & "GROUP BY FDITM, TRIM(FDMCU)) G ON A.IMITM=G.FDITM "
    gSQL = gSQL & "WHERE A.IMITM IN (SELECT FDITM "
    gSQL = gSQL & "FROM BRPD285DTA.F7611B "
    gSQL = gSQL & "WHERE FDLTTR = 760 AND FDNXTR = 780 "
    gSQL = gSQL & "GROUP BY FDITM, TRIM(FDMCU)) "
    gSQL = gSQL & "AND A.IMITM = '" & Item & "' "
    
    Set gRS = gCon.Execute(gSQL)
    If Not gRS.EOF Then
        Do While Not gRS.EOF
            ActiveSheet.Range("A" & i) = gRS!COD_ITEM
            ActiveSheet.Range("B" & i) = gRS!DESC_ITEM
            ActiveSheet.Range("C" & i) = gRS!FILIAL
            ActiveSheet.Range("D" & i) = gRS!EXISTENTE
            ActiveSheet.Range("E" & i) = gRS!DISPONIVEL
            ActiveSheet.Range("F" & i) = gRS!TIPO_PEDIDO
            ActiveSheet.Range("G" & i) = gRS!NUM_PEDIDO
            ActiveSheet.Range("H" & i) = gRS!VALOR_RECEBER
            ActiveSheet.Range("I" & i) = gRS!CONTRATO
            ActiveSheet.Range("J" & i) = gRS!QTD_NFE
            i = i + 1
            gRS.MoveNext
        Loop
    End If
    
gCon.Close
End Sub