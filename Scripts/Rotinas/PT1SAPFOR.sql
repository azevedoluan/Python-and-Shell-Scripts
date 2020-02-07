CREATE OR REPLACE PACKAGE PT1SAPFOR
AS
   -- Sylvio Alves - 30/10/19 - Versão 20/12/19

   PROCEDURE PCI;

   PROCEDURE PCI_FOR;

   PROCEDURE TRATA_FOR;

   PROCEDURE INS_FOR;

   PROCEDURE UPD_FOR;

   PROCEDURE PCI_END_ETR_T1;

   PROCEDURE PCI_END_ETR_XE;

   PROCEDURE PCI_TEL_T1;

   PROCEDURE PCI_TEL_XE;

   PROCEDURE PCI_BAN;

   PROCEDURE PCI_IRF;

   FUNCTION NUM(PRM VARCHAR2)
            RETURN VARCHAR2;

   PROCEDURE TRATA_ERRO;

   PROCEDURE FCH_PRC;

   CURSOR WCURFOR IS
      SELECT A.ABAN8                                            ABAN8,
             NVL(TRIM(B.ABAT1),' ')                             ABAT1,
             CASE WHEN B.ABAT1  = 'V' AND C.ALADDS = 'EX' THEN 'Z003'
                  WHEN B.ABAT1  = 'CE'                    THEN 'Z009'
                  WHEN B.ABAT1  = 'V' AND B.ABTAXC = '2'  THEN 'Z001'
                  WHEN B.ABAT1  = 'V' AND B.ABTAXC = '1'  THEN 'Z002'
                  WHEN B.ABAT1  = 'T' AND B.ABTAXC = '2'  THEN 'Z007'
                  WHEN B.ABAT1  = 'T'                     THEN 'Z008'
                  ELSE 'Z001' END                               AGRUPAMENTO_PARCEIRO,
             NVL(TRIM(B.ABALPH),' ')                            ABALPH,
             CASE WHEN C.ALADDS = 'EX' THEN ' '
                  WHEN B.ABAT1  = 'CE' THEN ' '
                  WHEN B.ABTAXC = '2'  THEN TO_CHAR(NVL(TRIM(B.ABTAX),' '))
                  WHEN B.ABTAXC = '1'  THEN ' '
                  ELSE                      '  ' END            CNPJ,
             CASE WHEN C.ALADDS = 'EX' THEN ' '
                  WHEN B.ABAT1  = 'CE' THEN ' '
                  WHEN B.ABTAXC = '2'  THEN ' '
                  WHEN B.ABTAXC = '1'  THEN TO_CHAR(NVL(TRIM(B.ABTAX),' '))
                  ELSE                      ' ' END             CPF,
             NVL(TRIM(B.ABTX2 ),' ')                            ABTX2,
             NVL(TRIM(B.ABTAXC),' ')                            ABTAXC,
             DECODE(B.ABTAXC,'1','X',' ')                       PESSOA_FISICA,
             NVL(TRIM(C.ALADD1),' ')                            ALADD1,
             SUBSTR(NVL(TRIM(C.ALADD2),' '),1,10)               ALADD2,
             NVL(TRIM(C.ALADD3),' ')                            ALADD3,
             SUBSTR(NVL(TRIM(C.ALADD4),' '),1,10)               ALADD4,
             NVL(TRIM(C.ALADDZ),' ')                            ALADDZ,
             NVL(TRIM(C.ALCTY1),' ')                            ALCTY1,
             NVL(TRIM(C.ALCTR ),' ')                            ALCTR,
             CASE WHEN LENGTH(NVL(TRIM(C.ALADDS),' ')) > 2 THEN TO_NCHAR(' ')
                  ELSE        NVL(TRIM(C.ALADDS),' ') END       ALADDS,
             DECODE(TRIM(C.ALADDZ),NULL,' ',SUBSTR(C.ALADDZ,1,5)||'-'||SUBSTR(C.ALADDZ,6,3)) CEP,
             NVL(TRIM(D.WWMLNM),' ')                            WWMLNM,
             NVL(TRIM(E.AIBMUN),' ')                            AIBMUN,
             NVL(TRIM(F.A6TRAP),' ')                            A6TRAP,
             NVL(TRIM(F.A6PYIN),' ')                            A6PYIN,
             B.ABALKY                                           ABALKY,
             TO_NCHAR(B.ABAN85)                                 ABAN85,
             B.ABTAX                                            ABTAX,
             TRIM(E.AIBRTAX1)                                   AIBRTAX1,
             TRIM(E.AIBRTAX2)                                   AIBRTAX2,
             TRIM(E.AIBRTAX3)                                   AIBRTAX3,
             TRIM(E.AIBRTAX4)                                   AIBRTAX4,
             TRIM(E.AIBRTAX5)                                   AIBRTAX5,
             TRIM(E.AIBRTAX6)                                   AIBRTAX6,
             TRIM(E.AIBRTAX7)                                   AIBRTAX7,
             TRIM(E.AIBRTAX8)                                   AIBRTAX8,
             CASE WHEN E.AIBICC = 1 THEN 'NO'
                  WHEN E.AIBICC = 2 THEN 'NC'
                  ELSE NULL END                                 CONTRIBUINTE_ICMS
        FROM F0401        F,
             F76011       E,
             F0111        D,
             F0116        C,
             F0101        B,
             DT1SAPFOR_TB A
       WHERE F.A6AN8  (+) = B.ABAN8
         AND E.AIAN8  (+) = B.ABAN8
         AND D.WWIDLN (+) = 1
         AND D.WWAN8  (+) = B.ABAN8
         AND C.ALEFTB (+) = B.ABEFTB
         AND C.ALAN8  (+) = B.ABAN8
         AND B.ABAN8  (+) = A.ABAN8
    ORDER BY A.ABAN8;
   RECFOR WCURFOR%ROWTYPE;

   CURSOR WCURENDETRT1 IS
      SELECT NVL(TRIM(EAEMAL),' ') EAEMAL
        FROM F01151
       WHERE EAAN8 = RECFOR.ABAN8
    ORDER BY EAIDLN,
             EARCK7;
   RECENDETRT1 WCURENDETRT1%ROWTYPE;

   CURSOR WCURENDETRXE IS
      SELECT CAST(NVL(TRIM(EAEMAL),' ')  AS VARCHAR2(256 CHAR)) EAEMAL
        FROM F01151_XE,
             F0101_XE
       WHERE EAAN8 = ABAN8
         AND ABAT1 = 'TR'
         AND ABTAX = RECFOR.ABTAX
    ORDER BY DECODE(TO_CHAR(ABAN8),TRIM(RECFOR.ABALKY),0,1),
             DECODE(TRIM(EAETP),'N',1,2);
   RECENDETRXE WCURENDETRXE%ROWTYPE;

   CURSOR WCURTELT1 IS
      SELECT NVL(TRIM(WPAR1 ),' ')   WPAR1,
             NVL(TRIM(WPPH1 ),' ')   WPPH1
        FROM F0115
       WHERE WPAN8  = RECFOR.ABAN8
    ORDER BY WPIDLN,
             WPRCK7;
   RECTELT1 WCURTELT1%ROWTYPE;

   CURSOR WCURTELXE IS
      SELECT CAST(NVL(TRIM(WPAR1 ),' ')  AS VARCHAR2( 6 CHAR)) WPAR1,
             CAST(NVL(TRIM(WPPH1 ),' ')  AS VARCHAR2(20 CHAR)) WPPH1
        FROM F0115_XE,
             F0101_XE
       WHERE WPAN8  = ABAN8
         AND ABAT1 = 'TR'
         AND ABTAX = RECFOR.ABTAX
    ORDER BY DECODE(TO_CHAR(ABAN8),TRIM(RECFOR.ABALKY),0,1),
             WPIDLN,
             WPRCK7;
   RECTELXE WCURTELXE%ROWTYPE;

   CURSOR WCURBAN IS
      SELECT CASE WHEN INSTR(AYTNST,'-',1) = 0 THEN NVL(TRIM(AYTNST),' ')
                       ELSE NVL(TRIM(SUBSTR(AYTNST,1,INSTR(AYTNST,'-',1)-1)),' ') END CHAVE_BANCO,
             CASE WHEN INSTR(AYTNST,'-',1) = 0 THEN TO_NCHAR(' ')
                       ELSE NVL(TRIM(SUBSTR(AYTNST,INSTR(AYTNST,'-',1)+1,LENGTH(AYTNST))),' ') END DIGITO,
             NVL(TRIM(AYTNST),' ')   AYTNST,
             NVL(TRIM(AYCBNK),' ')   CONTA_BANCARIA,
             NVL(TRIM(AYCHKD),' ')   AYCHKD
        FROM F0030
       WHERE TRIM(AYTNST) IS NOT NULL
         AND TRIM(AYCBNK) IS NOT NULL
         AND AYAN8        = RECFOR.ABAN8
    ORDER BY AYTNST;
   RECBAN WCURBAN%ROWTYPE;

   WRK_EMAIL                        STAGING_FORNECEDOR_CLIENTE.EMAIL_ERP%TYPE;
   WRK_TELEFONE                     STAGING_FORNECEDOR_CLIENTE.TELEFONE_ERP%TYPE;
   WRK_CONDICAO_PAGAMENTO_SAN       STAGING_FORNECEDOR_CLIENTE.CONDICAO_PAGAMENTO_SAN%TYPE;
   WRK_DOM_FISCAL                   STAGING_FORNECEDOR_CLIENTE.DOM_FISCAL_ERP%TYPE;
   WRK_CHAVE_BANCO_ERP              STAGING_FORNECEDOR_CLIENTE.CHAVE_BANCO_ERP%TYPE;
   WRK_CHAVE_BANCO_SAN              STAGING_FORNECEDOR_CLIENTE.CHAVE_BANCO_SAN%TYPE;
   WRK_CONTA_BANCARIA               STAGING_FORNECEDOR_CLIENTE.CONTA_BANCARIA_ERP%TYPE;
   WRK_CHAVE_CONTROLE               STAGING_FORNECEDOR_CLIENTE.CHAVE_CONTROLE_ERP%TYPE;
   WRK_COD_CATEGORIA_IRF            STAGING_FORNECEDOR_CLIENTE.COD_CATEGORIA_IRF%TYPE;
   WRK_FORMA_PAGAMENTO_SAN          STAGING_FORNECEDOR_CLIENTE.FORMA_PAGAMENTO_SAN%TYPE;
   WRK_STATUS_4                     STAGING_FORNECEDOR_CLIENTE.STATUS_4%TYPE;
   WRK_CONTA_CONCILIACAO            STAGING_FORNECEDOR_CLIENTE.CONta_CONCILIACAO%TYPE;
   ATU_AGRUPAMENTO_PARCEIRO         STAGING_FORNECEDOR_CLIENTE.AGRUPAMENTO_PARCEIRO%TYPE;
   ATU_NOME_1_ERP                   STAGING_FORNECEDOR_CLIENTE.NOME_1_ERP%TYPE;
   ATU_RUA_ERP                      STAGING_FORNECEDOR_CLIENTE.RUA_ERP%TYPE;
   ATU_NUMERO_ERP                   STAGING_FORNECEDOR_CLIENTE.NUMERO_ERP%TYPE;
   ATU_COMPLEMENTO_ERP              STAGING_FORNECEDOR_CLIENTE.COMPLEMENTO_ERP%TYPE;
   ATU_BAIRRO_ERP                   STAGING_FORNECEDOR_CLIENTE.BAIRRO_ERP%TYPE;
   ATU_CEP_ERP                      STAGING_FORNECEDOR_CLIENTE.CEP_ERP%TYPE;
   ATU_CIDADE_ERP                   STAGING_FORNECEDOR_CLIENTE.CIDADE_ERP%TYPE;
   ATU_UF_ERP                       STAGING_FORNECEDOR_CLIENTE.UF_ERP%TYPE;
   ATU_PAIS_ERP                     STAGING_FORNECEDOR_CLIENTE.PAIS_ERP%TYPE;
   ATU_CONT_PRIN_ERP                STAGING_FORNECEDOR_CLIENTE.CONT_PRIN_ERP%TYPE;
   ATU_EMAIL_ERP                    STAGING_FORNECEDOR_CLIENTE.EMAIL_ERP%TYPE;
   ATU_TELEFONE_ERP                 STAGING_FORNECEDOR_CLIENTE.TELEFONE_ERP%TYPE;
   ATU_PESSOA_FISICA                STAGING_FORNECEDOR_CLIENTE.PESSOA_FISICA%TYPE;
   ATU_CNPJ_ERP                     STAGING_FORNECEDOR_CLIENTE.CNPJ_ERP%TYPE;
   ATU_CPF_ERP                      STAGING_FORNECEDOR_CLIENTE.CPF_ERP%TYPE;
   ATU_INCRICAO_ESTADUAL_ERP        STAGING_FORNECEDOR_CLIENTE.INCRICAO_ESTADUAL_ERP%TYPE;
   ATU_INSCRICAO_MUNICIPAL_ERP      STAGING_FORNECEDOR_CLIENTE.INSCRICAO_MUNICIPAL_ERP%TYPE;
   ATU_CONTA_CONCILIACAO            STAGING_FORNECEDOR_CLIENTE.CONta_CONCILIACAO%TYPE;
   ATU_CONDICAO_PAGAMENTO_ERP       STAGING_FORNECEDOR_CLIENTE.CONDICAO_PAGAMENTO_ERP%TYPE;
   ATU_CONDICAO_PAGAMENTO_SAN       STAGING_FORNECEDOR_CLIENTE.CONDICAO_PAGAMENTO_SAN%TYPE;
   ATU_FORMA_PAGAMENTO_ERP          STAGING_FORNECEDOR_CLIENTE.FORMA_PAGAMENTO_ERP%TYPE;
   ATU_FORMA_PAGAMENTO_SAN          STAGING_FORNECEDOR_CLIENTE.FORMA_PAGAMENTO_SAN%TYPE;
   ATU_CHAVE_BANCO_ERP              STAGING_FORNECEDOR_CLIENTE.CHAVE_BANCO_ERP%TYPE;
   ATU_CHAVE_BANCO_SAN              STAGING_FORNECEDOR_CLIENTE.CHAVE_BANCO_SAN%TYPE;
   ATU_CONTA_BANCARIA_ERP           STAGING_FORNECEDOR_CLIENTE.CONTA_BANCARIA_ERP%TYPE;
   ATU_CHAVE_CONTROLE_ERP           STAGING_FORNECEDOR_CLIENTE.CHAVE_CONTROLE_ERP%TYPE;
   ATU_COD_CATEGORIA_IRF            STAGING_FORNECEDOR_CLIENTE.COD_CATEGORIA_IRF%TYPE;
   ATU_CONTRIBUINTE_ICMS            STAGING_FORNECEDOR_CLIENTE.CONTRIBUINTE_ICMS%TYPE;
   ATU_INFO                         STAGING_FORNECEDOR_CLIENTE.INFO%TYPE;
   ATU_OBSERVACAO                   STAGING_FORNECEDOR_CLIENTE.OBSERVACAO%TYPE;
   ATU_COD_PAI_ERP                  STAGING_FORNECEDOR_CLIENTE.COD_PAI_ERP%TYPE;
   ATU_TIPO_CADASTRO                STAGING_FORNECEDOR_CLIENTE.TIPO_CADASTRO%TYPE;
   ATU_DOM_FISCAL_ERP               STAGING_FORNECEDOR_CLIENTE.DOM_FISCAL_ERP%TYPE;
   ATU_STATUS                       STAGING_FORNECEDOR_CLIENTE.STATUS%TYPE;
   ATU_STATUS_4                     STAGING_FORNECEDOR_CLIENTE.STATUS_4%TYPE;
   WRK_PARA                         DE_PARA_TB.PARA%TYPE;
   WRK_AIBRTAX                      F76011.AIBRTAX1%TYPE;
   WRK_NOM_ROT                      DSAPERR_TB.NOM_ROT%TYPE;
   WRK_NUM_ERR                      DSAPERR_TB.NUM_ERR%TYPE;
   WRK_CHV_ERR                      DSAPERR_TB.CHV_ERR%TYPE;
   WRK_ERR_ORA                      DSAPERR_TB.ERR_ORA%TYPE;
   WRK_DES_ERR                      DSAPERR_TB.DES_ERR%TYPE;
   WRK_DTH_ERR                      DSAPERR_TB.DTH_ERR%TYPE;
   WRK_DTA_EMI_NTF                  DATE;
   WRK_NUM_NTF                      NUMBER;
   WRK_COD_MUN                      NUMBER;
   WRK_NUM                          NUMBER;
   WRK_QTD_BAN                      NUMBER;
   WRK_TXT                          VARCHAR2(2000);
   WRK_TXT_BAN                      VARCHAR2(2000);
   WRK_EXCEPT_01                    EXCEPTION;
   WRK_SAIDA                        EXCEPTION;
   IND_ERR                          BOOLEAN;

END PT1SAPFOR;
/

CREATE OR REPLACE PACKAGE BODY PT1SAPFOR
AS
-- Sylvio Alves - 30/10/19 - Versão 20/12/19

PROCEDURE PCI
IS
BEGIN

   WRK_NOM_ROT := 'PT1SAPFOR';
   WRK_NUM_ERR := 0;
   WRK_CHV_ERR := 'INICIO';
   WRK_DTH_ERR := SYSDATE;

   BEGIN
      SELECT DES_ERR
        INTO WRK_DES_ERR
        FROM DSAPERR_TB
       WHERE NOM_ROT = WRK_NOM_ROT
         AND NUM_ERR = 0
         FOR UPDATE OF DSAPERR_TB.DES_ERR;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         WRK_DES_ERR := 'NUNCA RODOU';
      WHEN OTHERS THEN
         RAISE WRK_SAIDA;
   END;

   IF WRK_DES_ERR = 'EM PROCESSAMENTO' THEN
      RAISE WRK_SAIDA;
   END IF;

   IF WRK_DES_ERR = 'NUNCA RODOU' THEN
      BEGIN
         INSERT INTO DSAPERR_TB
         VALUES (WRK_NOM_ROT,
                 WRK_NUM_ERR,
                 WRK_CHV_ERR,
                 ' ',
                 'EM PROCESSAMENTO',
                 WRK_DTH_ERR);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE WRK_SAIDA;
      END;
   ELSE
      BEGIN
         UPDATE DSAPERR_TB
            SET ERR_ORA = ' ',
                CHV_ERR = WRK_CHV_ERR,
                DES_ERR = 'EM PROCESSAMENTO',
                DTH_ERR = WRK_DTH_ERR
          WHERE NOM_ROT = WRK_NOM_ROT
            AND NUM_ERR = 0;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE WRK_SAIDA;
      END;
      IF SQL%ROWCOUNT = 0 THEN
         RAISE WRK_SAIDA;
      END IF;
   END IF;

   DELETE DSAPERR_TB
    WHERE NOM_ROT  = WRK_NOM_ROT
      AND NUM_ERR <> 0;

   COMMIT;

   PCI_FOR;

   FCH_PRC;

EXCEPTION
   WHEN WRK_SAIDA THEN
      ROLLBACK;
   WHEN WRK_EXCEPT_01 THEN
      TRATA_ERRO;
      FCH_PRC;
   WHEN OTHERS THEN
      WRK_CHV_ERR := 'ERRO OTHERS PCI.';
      WRK_DES_ERR := 'ERRO OTHERS PCI.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
      FCH_PRC;
END PCI;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_FOR
IS
BEGIN

   BEGIN
      INSERT INTO DT1SAPFOR_TB
      SELECT A.ABAN8,
             SYSDATE
        FROM DT1SAPFOR_TB B,
             F0101        A
       WHERE B.ABAN8    IS NULL
         AND B.ABAN8 (+) = A.ABAN8
         AND A.ABAT1     = 'V';
   EXCEPTION
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO INSERT DXESAPCLI_TB';
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         TRATA_ERRo;
   END;

   COMMIT;

   BEGIN
      INSERT INTO DT1SAPFOR_TB
      SELECT A.ABAN8,
             SYSDATE
        FROM DT1SAPFOR_TB B,
            (SELECT DISTINCT ABAN8
               FROM F0101 C,
                    F7611B B,
                    F7601B A
              WHERE C.ABAT1   = 'T'
                AND C.ABAN8   = FHBSFH
                AND A.FHISSU >=  1||TO_CHAR(SYSDATE-7,'RRDDD')
                AND B.FDNXTR  > '780'
                AND B.FDPDCT IN ('OP')
                AND B.FDBNNF  = A.FHBNNF
                AND B.FDBSER  = A.FHBSER
                AND B.FDN001  = A.FHN001
                AND B.FDDCT   = A.FHDCT
                AND A.FHBNFS <= '4') A
         WHERE B.ABAN8 IS NULL
           AND B.ABAN8 (+) = A.ABAN8;
   EXCEPTION
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO INSERT DXESAPCLI_TB';
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         TRATA_ERRo;
   END;

   COMMIT;

   OPEN WCURFOR;
   FETCH WCURFOR INTO RECFOR;
   LOOP
      EXIT WHEN WCURFOR%NOTFOUND;

      BEGIN
         WRK_CHV_ERR := RECFOR.ABAN8;
         TRATA_FOR;
      EXCEPTION
         WHEN WRK_EXCEPT_01 THEN
            TRATA_ERRO;
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO PCI 2.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            TRATA_ERRO;
      END;

      FETCH WCURFOR INTO RECFOR;
   END LOOP;

   CLOSE WCURFOR;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      RAISE WRK_EXCEPT_01;
   WHEN OTHERS THEN
      CLOSE WCURFOR;
      WRK_DES_ERR := 'ERRO OTHERS PCI_FOR.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_FOR;
---------------------------------------------------------------------------------------------
PROCEDURE TRATA_FOR
IS
BEGIN

   IND_ERR := FALSE;

   IF NVL(TRIM(RECFOR.ABAT1),' ') = 'V' THEN
      PCI_END_ETR_T1;
      PCI_TEL_T1;
   ELSIF NVL(TRIM(RECFOR.ABAT1),' ') = 'T' THEN
      PCI_END_ETR_XE;
      PCI_TEL_XE;
   END IF;
   PCI_BAN;

   WRK_NUM_NTF     := NULL;
   WRK_DTA_EMI_NTF := NULL;
   WRK_TXT         := NULL;

   IF NOT IND_ERR THEN
      IF NVL(TRIM(RECFOR.ABAT1),' ') = 'V' THEN
         BEGIN
            SELECT MAX(TO_DATE(SUBSTR(A.FHISSU,2,5),'RRDDD')),
                   MAX(A.FHBNNF)
              INTO WRK_DTA_EMI_NTF,
                   WRK_NUM_NTF
              FROM F7611B B,
                   F7601B A
             WHERE A.FHISSU = (SELECT MAX(A.FHISSU)
                                 FROM F7611B B,
                                      F7601B A
                                WHERE B.FDNXTR  > '780'
                                  AND B.FDPDCT IN ('OR','OQ','OP')
                                  AND B.FDBNNF  = A.FHBNNF
                                  AND B.FDBSER  = A.FHBSER
                                  AND B.FDN001  = A.FHN001
                                  AND B.FDDCT   = A.FHDCT
                                  AND A.FHBNFS <= '4'
                                  AND A.FHBSFH  = RECFOR.ABAN8)
               AND B.FDNXTR  > '780'
               AND B.FDPDCT IN ('OR','OQ','OP')
               AND B.FDBNNF  = A.FHBNNF
               AND B.FDBSER  = A.FHBSER
               AND B.FDN001  = A.FHN001
               AND B.FDDCT   = A.FHDCT
               AND A.FHBNFS <= '4'
               AND A.FHBSFH  = RECFOR.ABAN8;
         EXCEPTION
            WHEN OTHERS THEN
               WRK_DES_ERR := 'ERRO LEITURA F7601B';
               WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
               RAISE WRK_EXCEPT_01;
         END;
      ELSIF NVL(TRIM(RECFOR.ABAT1),' ') = 'T' THEN
         BEGIN
            SELECT MAX(TO_DATE(SUBSTR(A.FHISSU,2,5),'RRDDD')),
                   MAX(A.FHBNNF)
              INTO WRK_DTA_EMI_NTF,
                   WRK_NUM_NTF
              FROM F7611B B,
                   F7601B A
             WHERE A.FHISSU = (SELECT MAX(A.FHISSU)
                                 FROM F7611B B,
                                      F7601B A
                                WHERE B.FDNXTR  > '780'
                                  AND B.FDPDCT IN ('OP')
                                  AND B.FDBNNF  = A.FHBNNF
                                  AND B.FDBSER  = A.FHBSER
                                  AND B.FDN001  = A.FHN001
                                  AND B.FDDCT   = A.FHDCT
                                  AND A.FHBNFS <= '4'
                                  AND A.FHBSFH  = RECFOR.ABAN8)
               AND B.FDNXTR  > '780'
               AND B.FDPDCT IN ('OP')
               AND B.FDBNNF  = A.FHBNNF
               AND B.FDBSER  = A.FHBSER
               AND B.FDN001  = A.FHN001
               AND B.FDDCT   = A.FHDCT
               AND A.FHBNFS <= '4'
               AND A.FHBSFH  = RECFOR.ABAN8;
         EXCEPTION
            WHEN OTHERS THEN
               WRK_DES_ERR := 'ERRO LEITURA F7601B';
               WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
               RAISE WRK_EXCEPT_01;
         END;
      END IF;
   END IF;

   BEGIN
     SELECT PARA
       INTO WRK_FORMA_PAGAMENTO_SAN
       FROM DE_PARA_TB
      WHERE TIPO = 'FPAG'
        AND DE   = TRIM(RECFOR.A6PYIN);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         WRK_FORMA_PAGAMENTO_SAN := NULL;
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO LEITURA DE_PARA_TB(FPAG)='||TRIM(RECFOR.A6PYIN);
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         RAISE WRK_EXCEPT_01;
   END;

   IF WRK_DTA_EMI_NTF IS NOT NULL THEN
      WRK_TXT := 'DATA='||TO_CHAR(WRK_DTA_EMI_NTF,'DD/MM/YYYY');
      IF WRK_NUM_NTF IS NOT NULL THEN
         WRK_TXT := WRK_TXT||' FATURA='||TO_CHAR(WRK_NUM_NTF);
      END IF;
   ELSIF WRK_NUM_NTF IS NOT NULL THEN
      WRK_TXT := 'NUMERO='||TO_CHAR(WRK_NUM_NTF);
   END IF;

   WRK_DOM_FISCAL      := NULL;
   IF TRIM(RECFOR.ALADDS) <> 'EX' THEN
      WRK_COD_MUN := MUN_CEP.PCI_FN(RECFOR.ALADDZ);
      IF WRK_COD_MUN IS NOT NULL THEN
         WRK_DOM_FISCAL      := SUBSTR(RECFOR.ALADDS,1,2)||' '||WRK_COD_MUN;
      END IF;
   END IF;


   WRK_STATUS_4          := NULL;
   WRK_COD_CATEGORIA_IRF := NULL;

   WRK_AIBRTAX  := RECFOR.AIBRTAX1;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX2;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX3;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX4;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX5;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX6;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX7;
   PCI_IRF;
   WRK_AIBRTAX  := RECFOR.AIBRTAX8;
   PCI_IRF;

   IF RECFOR.AGRUPAMENTO_PARCEIRO = 'Z003' THEN
      WRK_CONTA_CONCILIACAO := '0021101010';
   ELSE
      WRK_CONTA_CONCILIACAO := '0021101001';
   END IF;

   BEGIN
     SELECT PARA
       INTO WRK_CONDICAO_PAGAMENTO_SAN
       FROM DE_PARA_TB
      WHERE TIPO = 'CPAG'
        AND DE   = TRIM(RECFOR.A6TRAP);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         WRK_CONDICAO_PAGAMENTO_SAN := NULL;
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO LEITURA DE_PARA_TB(CPAG)='||TRIM(RECFOR.A6TRAP);
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         RAISE WRK_EXCEPT_01;
   END;

   BEGIN
     SELECT 1,
            AGRUPAMENTO_PARCEIRO,
            NOME_1_ERP,
            RUA_ERP,
            NUMERO_ERP,
            COMPLEMENTO_ERP,
            BAIRRO_ERP,
            CEP_ERP,
            CIDADE_ERP,
            UF_ERP,
            PAIS_ERP,
            CONT_PRIN_ERP,
            EMAIL_ERP,
            TELEFONE_ERP,
            PESSOA_FISICA,
            CNPJ_ERP,
            CPF_ERP,
            INCRICAO_ESTADUAL_ERP,
            INSCRICAO_MUNICIPAL_ERP,
            CONTA_CONCILIACAO,
            CONDICAO_PAGAMENTO_ERP,
            CONDICAO_PAGAMENTO_SAN,
            FORMA_PAGAMENTO_ERP,
            FORMA_PAGAMENTO_SAN,
            CHAVE_BANCO_ERP,
            CHAVE_BANCO_SAN,
            CONTA_BANCARIA_ERP,
            CHAVE_CONTROLE_ERP,
            COD_CATEGORIA_IRF,
            CONTRIBUINTE_ICMS,
            INFO,
            OBSERVACAO,
            COD_PAI_ERP,
            TIPO_CADASTRO,
            DOM_FISCAL_ERP,
            STATUS,
            STATUS_4
       INTO WRK_NUM,
            ATU_AGRUPAMENTO_PARCEIRO,
            ATU_NOME_1_ERP,
            ATU_RUA_ERP,
            ATU_NUMERO_ERP,
            ATU_COMPLEMENTO_ERP,
            ATU_BAIRRO_ERP,
            ATU_CEP_ERP,
            ATU_CIDADE_ERP,
            ATU_UF_ERP,
            ATU_PAIS_ERP,
            ATU_CONT_PRIN_ERP,
            ATU_EMAIL_ERP,
            ATU_TELEFONE_ERP,
            ATU_PESSOA_FISICA,
            ATU_CNPJ_ERP,
            ATU_CPF_ERP,
            ATU_INCRICAO_ESTADUAL_ERP,
            ATU_INSCRICAO_MUNICIPAL_ERP,
            ATU_CONTA_CONCILIACAO,
            ATU_CONDICAO_PAGAMENTO_ERP,
            ATU_CONDICAO_PAGAMENTO_SAN,
            ATU_FORMA_PAGAMENTO_ERP,
            ATU_FORMA_PAGAMENTO_SAN,
            ATU_CHAVE_BANCO_ERP,
            ATU_CHAVE_BANCO_SAN,
            ATU_CONTA_BANCARIA_ERP,
            ATU_CHAVE_CONTROLE_ERP,
            ATU_COD_CATEGORIA_IRF,
            ATU_CONTRIBUINTE_ICMS,
            ATU_INFO,
            ATU_OBSERVACAO,
            ATU_COD_PAI_ERP,
            ATU_TIPO_CADASTRO,
            ATU_DOM_FISCAL_ERP,
            ATU_STATUS,
            ATU_STATUS_4
       FROM STAGING_FORNECEDOR_CLIENTE
      WHERE CODIGO_ANTIGO = 'T'||RECFOR.ABAN8;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         WRK_NUM := 0;
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO STAGING_FORNECEDOR_CLIENTE';
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         RAISE WRK_EXCEPT_01;
   END;

   IF NOT IND_ERR THEN
      IF WRK_NUM = 0 THEN
         IF RECFOR.ABALPH               IS NOT NULL  AND
            NVL(TRIM(RECFOR.ABAT1),' ') IN ('V','T') THEN
            INS_FOR;
         ELSE
            DELETE DT1SAPFOR_TB
             WHERE ABAN8  = RECFOR.ABAN8;
            COMMIT;
            RAISE WRK_SAIDA;
         END IF;
      ELSE
         UPD_FOR;
      END IF;
   END IF;

EXCEPTION
   WHEN WRK_SAIDA THEN
      NULL;
   WHEN WRK_EXCEPT_01 THEN
      RAISE WRK_EXCEPT_01;
   WHEN OTHERS THEN
      WRK_DES_ERR := 'ERRO OTHERS TRATA_FOR.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      RAISE WRK_EXCEPT_01;
END TRATA_FOR;
---------------------------------------------------------------------------------------------
PROCEDURE INS_FOR
IS
BEGIN

   BEGIN
      INSERT INTO STAGING_FORNECEDOR_CLIENTE
      VALUES('F',
             ' ',
             'T'||RECFOR.ABAN8,
             RECFOR.AGRUPAMENTO_PARCEIRO,
             RECFOR.ABALPH,
             RECFOR.ABALPH,
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             RECFOR.ALADD1,
             RECFOR.ALADD1,
             RECFOR.ALADD2,
             RECFOR.ALADD2,
             RECFOR.ALADD4,
             RECFOR.ALADD4,
             RECFOR.ALADD3,
             RECFOR.ALADD3,
             RECFOR.CEP,
             RECFOR.CEP,
             RECFOR.ALCTY1,
             RECFOR.ALCTY1,
             RECFOR.ALADDS,
             RECFOR.ALADDS,
             RECFOR.ALCTR,
             RECFOR.ALCTR,
             RECFOR.WWMLNM,
             RECFOR.WWMLNM,
             WRK_EMAIL,
             WRK_EMAIL,
             WRK_TELEFONE,
             WRK_TELEFONE,
             ' ',
             ' ',
             ' ',
             'PT',
             RECFOR.PESSOA_FISICA,
             RECFOR.CNPJ,
             RECFOR.CNPJ,
             RECFOR.CPF,
             RECFOR.CPF,
             RECFOR.ABTX2,
             RECFOR.ABTX2,
             RECFOR.AIBMUN,
             RECFOR.AIBMUN,
             ' ',
             WRK_CONTA_CONCILIACAO,
             ' ',
             RECFOR.A6TRAP,
             WRK_CONDICAO_PAGAMENTO_SAN,
             RECFOR.A6PYIN,
             WRK_FORMA_PAGAMENTO_SAN,
             NULL,
             'BRL',
             'BRL',
             WRK_CHAVE_BANCO_ERP,
             WRK_CHAVE_BANCO_SAN,
             WRK_CONTA_BANCARIA,
             WRK_CONTA_BANCARIA,
             WRK_CHAVE_CONTROLE,
             WRK_CHAVE_CONTROLE,
             WRK_COD_CATEGORIA_IRF,
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             RECFOR.CONTRIBUINTE_ICMS,
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             'P',
             WRK_TXT,
             WRK_TXT_BAN,
             RECFOR.ABAN85,
             ' ',
             ' ',
             RECFOR.ABAT1,
             ' ',
             WRK_DOM_FISCAL,
             WRK_DOM_FISCAL,
             'BR02',
             ' ',
             ' ',
             ' ',
             ' ',
             ' ',
             NULL,
             NULL,
             NULL,
             WRK_STATUS_4,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL,
             NULL);
   EXCEPTION
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO INSERT INTO STAGING_FORNECEDOR_CLIENTE VALUES('
                        ||CHR(39)||'F'||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||'T'||RECFOR.ABAN8||CHR(39)||','
                        ||CHR(39)||RECFOR.AGRUPAMENTO_PARCEIRO||CHR(39)||','
                        ||CHR(39)||RECFOR.ABALPH||CHR(39)||','
                        ||CHR(39)||RECFOR.ABALPH||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD1||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD1||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD2||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD2||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD4||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD4||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD3||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADD3||CHR(39)||','
                        ||CHR(39)||RECFOR.CEP||CHR(39)||','
                        ||CHR(39)||RECFOR.CEP||CHR(39)||','
                        ||CHR(39)||RECFOR.ALCTY1||CHR(39)||','
                        ||CHR(39)||RECFOR.ALCTY1||CHR(39)||','
                        ||CHR(39)||RECFOR.ALCTR||CHR(39)||','
                        ||CHR(39)||RECFOR.ALCTR||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADDS||CHR(39)||','
                        ||CHR(39)||RECFOR.ALADDS||CHR(39)||','
                        ||CHR(39)||RECFOR.WWMLNM||CHR(39)||','
                        ||CHR(39)||RECFOR.WWMLNM||CHR(39)||','
                        ||CHR(39)||WRK_EMAIL||CHR(39)||','
                        ||CHR(39)||WRK_EMAIL||CHR(39)||','
                        ||CHR(39)||WRK_TELEFONE||CHR(39)||','
                        ||CHR(39)||WRK_TELEFONE||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||'PT'||CHR(39)||','
                        ||CHR(39)||RECFOR.PESSOA_FISICA||CHR(39)||','
                        ||CHR(39)||RECFOR.CNPJ||CHR(39)||','
                        ||CHR(39)||RECFOR.CNPJ||CHR(39)||','
                        ||CHR(39)||RECFOR.CPF||CHR(39)||','
                        ||CHR(39)||RECFOR.CPF||CHR(39)||','
                        ||CHR(39)||RECFOR.ABTX2||CHR(39)||','
                        ||CHR(39)||RECFOR.ABTX2||CHR(39)||','
                        ||CHR(39)||RECFOR.AIBMUN||CHR(39)||','
                        ||CHR(39)||RECFOR.AIBMUN||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||WRK_CONTA_CONCILIACAO||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||RECFOR.A6TRAP||CHR(39)||','
                        ||CHR(39)||WRK_CONDICAO_PAGAMENTO_SAN||CHR(39)||','
                        ||CHR(39)||RECFOR.A6PYIN||CHR(39)||','
                        ||CHR(39)||WRK_FORMA_PAGAMENTO_SAN||CHR(39)||','
                        ||'NULL'||','
                        ||CHR(39)||'BRL'||CHR(39)||','
                        ||CHR(39)||'BRL'||CHR(39)||','
                        ||CHR(39)||WRK_CHAVE_BANCO_ERP||CHR(39)||','
                        ||CHR(39)||WRK_CHAVE_BANCO_SAN||CHR(39)||','
                        ||CHR(39)||WRK_CONTA_BANCARIA||CHR(39)||','
                        ||CHR(39)||WRK_CONTA_BANCARIA||CHR(39)||','
                        ||CHR(39)||WRK_CHAVE_CONTROLE||CHR(39)||','
                        ||CHR(39)||WRK_CHAVE_CONTROLE||CHR(39)||','
                        ||CHR(39)||WRK_COD_CATEGORIA_IRF||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||RECFOR.CONTRIBUINTE_ICMS||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||'P'||CHR(39)||','
                        ||CHR(39)||WRK_TXT||CHR(39)||','
                        ||CHR(39)||WRK_TXT_BAN||CHR(39)||','
                        ||CHR(39)||RECFOR.ABAN85||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||RECFOR.ABAT1||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||WRK_DOM_FISCAL||CHR(39)||','
                        ||CHR(39)||WRK_DOM_FISCAL||CHR(39)||','
                        ||CHR(39)||'BR02'||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||CHR(39)||' '||CHR(39)||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||CHR(39)||WRK_STATUS_4||CHR(39)||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||','
                        ||'NULL'||')';
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         RAISE WRK_EXCEPT_01;
   END;

   COMMIT;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      RAISE WRK_EXCEPT_01;
   WHEN OTHERS THEN
      WRK_DES_ERR := 'ERRO OTHERS INS_FOR.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      RAISE WRK_EXCEPT_01;
END INS_FOR;
---------------------------------------------------------------------------------------------
PROCEDURE UPD_FOR
IS
BEGIN

   IF RECFOR.ABALPH                   IS NULL      OR
      NVL(TRIM(RECFOR.ABAT1),' ') NOT IN ('V','T') THEN
      IF ATU_STATUS <> 'N' THEN
         BEGIN
            UPDATE STAGING_FORNECEDOR_CLIENTE
               SET STATUS        = 'N'
             WHERE CODIGO_ANTIGO = 'T'||RECFOR.ABAN8;
         EXCEPTION
            WHEN OTHERS THEN
               WRK_DES_ERR := 'ERRO UPDATE STAGING_FORNECEDOR_CLIENTE(3).';
               WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
               RAISE WRK_EXCEPT_01;
         END;
      END IF;
   ELSIF NVL(ATU_AGRUPAMENTO_PARCEIRO   ,' ') <> NVL(RECFOR.AGRUPAMENTO_PARCEIRO,' ') OR
         NVL(ATU_NOME_1_ERP             ,' ') <> NVL(RECFOR.ABALPH              ,' ') OR
         NVL(ATU_RUA_ERP                ,' ') <> NVL(RECFOR.ALADD1              ,' ') OR
         NVL(ATU_NUMERO_ERP             ,' ') <> NVL(RECFOR.ALADD2              ,' ') OR
         NVL(ATU_COMPLEMENTO_ERP        ,' ') <> NVL(RECFOR.ALADD4              ,' ') OR
         NVL(ATU_BAIRRO_ERP             ,' ') <> NVL(RECFOR.ALADD3              ,' ') OR
         NVL(ATU_CEP_ERP                ,' ') <> NVL(RECFOR.CEP                 ,' ') OR
         NVL(ATU_CIDADE_ERP             ,' ') <> NVL(RECFOR.ALCTY1              ,' ') OR
         NVL(ATU_UF_ERP                 ,' ') <> NVL(RECFOR.ALADDS              ,' ') OR
         NVL(ATU_PAIS_ERP               ,' ') <> NVL(RECFOR.ALCTR               ,' ') OR
         NVL(ATU_CONT_PRIN_ERP          ,' ') <> NVL(RECFOR.WWMLNM              ,' ') OR
         NVL(ATU_EMAIL_ERP              ,' ') <> NVL(WRK_EMAIL                  ,' ') OR
         NVL(ATU_TELEFONE_ERP           ,' ') <> NVL(WRK_TELEFONE               ,' ') OR
         NVL(ATU_PESSOA_FISICA          ,' ') <> NVL(RECFOR.PESSOA_FISICA       ,' ') OR
         NVL(ATU_CNPJ_ERP               ,' ') <> NVL(RECFOR.CNPJ                ,' ') OR
         NVL(ATU_CPF_ERP                ,' ') <> NVL(RECFOR.CPF                 ,' ') OR
         NVL(ATU_INCRICAO_ESTADUAL_ERP  ,' ') <> NVL(RECFOR.ABTX2               ,' ') OR
         NVL(ATU_INSCRICAO_MUNICIPAL_ERP,' ') <> NVL(RECFOR.AIBMUN              ,' ') OR
         NVL(ATU_CONTA_CONCILIACAO      ,' ') <> NVL(WRK_CONTA_CONCILIACAO      ,' ') OR
         NVL(ATU_CONDICAO_PAGAMENTO_ERP ,' ') <> NVL(RECFOR.A6TRAP              ,' ') OR
         NVL(ATU_FORMA_PAGAMENTO_ERP    ,' ') <> NVL(RECFOR.A6PYIN              ,' ') OR
         NVL(ATU_CHAVE_BANCO_ERP        ,' ') <> NVL(WRK_CHAVE_BANCO_ERP        ,' ') OR
         NVL(ATU_CONTA_BANCARIA_ERP     ,' ') <> NVL(WRK_CONTA_BANCARIA         ,' ') OR
         NVL(ATU_CHAVE_CONTROLE_ERP     ,' ') <> NVL(WRK_CHAVE_CONTROLE         ,' ') OR
         NVL(ATU_COD_CATEGORIA_IRF      ,' ') <> NVL(WRK_COD_CATEGORIA_IRF      ,' ') OR
         NVL(ATU_CONTRIBUINTE_ICMS      ,' ') <> NVL(RECFOR.CONTRIBUINTE_ICMS   ,' ') OR
         NVL(ATU_OBSERVACAO             ,' ') <> NVL(WRK_TXT_BAN                ,' ') OR
         NVL(ATU_COD_PAI_ERP            ,' ') <> NVL(RECFOR.ABAN85              ,' ') OR
         NVL(ATU_TIPO_CADASTRO          ,' ') <> NVL(RECFOR.ABAT1               ,' ') OR
         NVL(ATU_DOM_FISCAL_ERP         ,' ') <> NVL(WRK_DOM_FISCAL             ,' ') OR
         NVL(ATU_STATUS_4               ,' ') <> NVL(WRK_STATUS_4               ,' ') THEN

      BEGIN
         UPDATE STAGING_FORNECEDOR_CLIENTE
            SET AGRUPAMENTO_PARCEIRO    = RECFOR.AGRUPAMENTO_PARCEIRO,
                NOME_1_ERP              = RECFOR.ABALPH,
                RUA_ERP                 = RECFOR.ALADD1,
                NUMERO_ERP              = RECFOR.ALADD2,
                COMPLEMENTO_ERP         = RECFOR.ALADD4,
                BAIRRO_ERP              = RECFOR.ALADD3,
                CEP_ERP                 = RECFOR.CEP,
                CIDADE_ERP              = RECFOR.ALCTY1,
                UF_ERP                  = RECFOR.ALADDS,
                PAIS_ERP                = RECFOR.ALCTR,
                CONT_PRIN_ERP           = RECFOR.WWMLNM,
                EMAIL_ERP               = WRK_EMAIL,
                TELEFONE_ERP            = WRK_TELEFONE,
                PESSOA_FISICA           = RECFOR.PESSOA_FISICA,
                CNPJ_ERP                = RECFOR.CNPJ,
                CPF_ERP                 = RECFOR.CPF,
                INCRICAO_ESTADUAL_ERP   = RECFOR.ABTX2,
                INSCRICAO_MUNICIPAL_ERP = RECFOR.AIBMUN,
                CONTA_CONCILIACAO       = WRK_CONTA_CONCILIACAO,
                CONDICAO_PAGAMENTO_ERP  = RECFOR.A6TRAP,
                FORMA_PAGAMENTO_ERP     = RECFOR.A6PYIN,
                CHAVE_BANCO_ERP         = WRK_CHAVE_BANCO_ERP,
                CONTA_BANCARIA_ERP      = WRK_CONTA_BANCARIA,
                CHAVE_CONTROLE_ERP      = WRK_CHAVE_CONTROLE,
                COD_CATEGORIA_IRF       = WRK_COD_CATEGORIA_IRF,
                CONTRIBUINTE_ICMS       = RECFOR.CONTRIBUINTE_ICMS,
                STATUS                  = 'P',
                INFO                    = WRK_TXT,
                OBSERVACAO              = WRK_TXT_BAN,
                COD_PAI_ERP             = RECFOR.ABAN85,
                TIPO_CADASTRO           = RECFOR.ABAT1,
                DOM_FISCAL_ERP          = WRK_DOM_FISCAL,
                STATUS_4                = WRK_STATUS_4
          WHERE CODIGO_ANTIGO           = 'T'||RECFOR.ABAN8;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO UPDATE STAGING_FORNECEDOR_CLIENTE(2).';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;
   ELSIF NVL(ATU_INFO,' ') <> NVL(WRK_TXT,' ') THEN
      BEGIN
         UPDATE STAGING_FORNECEDOR_CLIENTE
            SET INFO          = WRK_TXT
          WHERE CODIGO_ANTIGO = 'T'||RECFOR.ABAN8;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO UPDATE STAGING_FORNECEDOR_CLIENTE(3).';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;
   END IF;

   COMMIT;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      RAISE WRK_EXCEPT_01;
   WHEN OTHERS THEN
      WRK_DES_ERR := 'ERRO OTHERS UPD_FOR.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      RAISE WRK_EXCEPT_01;
END UPD_FOR;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_END_ETR_T1
IS
BEGIN

   WRK_EMAIL := NULL;

   OPEN WCURENDETRT1;
   FETCH WCURENDETRT1 INTO RECENDETRT1;
   LOOP
      EXIT WHEN WCURENDETRT1%NOTFOUND;

      BEGIN
         IF WRK_EMAIL IS NULL THEN
            WRK_EMAIL := RECENDETRT1.EAEMAL;
         ELSE
            WRK_EMAIL := WRK_EMAIL||';'||RECENDETRT1.EAEMAL;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO MONTAGEM EMAIL.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;

      FETCH WCURENDETRT1 INTO RECENDETRT1;
   END LOOP;

   CLOSE WCURENDETRT1;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      CLOSE WCURENDETRT1;
      TRATA_ERRO;
   WHEN OTHERS THEN
      CLOSE WCURENDETRT1;
      WRK_DES_ERR := 'ERRO OTHERS PCI_END_ETR_T1.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_END_ETR_T1;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_END_ETR_XE
IS
BEGIN

   WRK_EMAIL := NULL;

   OPEN WCURENDETRXE;
   FETCH WCURENDETRXE INTO RECENDETRXE;
   LOOP
      EXIT WHEN WCURENDETRXE%NOTFOUND;

      BEGIN
         IF WRK_EMAIL IS NULL THEN
            WRK_EMAIL := RECENDETRXE.EAEMAL;
         ELSE
            WRK_EMAIL := WRK_EMAIL||';'||RECENDETRXE.EAEMAL;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO MONTAGEM EMAIL.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;

      FETCH WCURENDETRXE INTO RECENDETRXE;
   END LOOP;

   CLOSE WCURENDETRXE;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      CLOSE WCURENDETRXE;
      TRATA_ERRO;
   WHEN OTHERS THEN
      CLOSE WCURENDETRXE;
      WRK_DES_ERR := 'ERRO OTHERS PCI_END_ETR_XE.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_END_ETR_XE;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_TEL_T1
IS
BEGIN

   WRK_TELEFONE := NULL;

   OPEN WCURTELT1;
   FETCH WCURTELT1 INTO RECTELT1;
   LOOP
      EXIT WHEN WCURTELT1%NOTFOUND;
      BEGIN
         IF WRK_TELEFONE IS NULL THEN
            WRK_TELEFONE := NUM(RECTELT1.WPAR1)||' '||NUM(RECTELT1.WPPH1);
         ELSE
            WRK_TELEFONE := WRK_TELEFONE||';'||NUM(RECTELT1.WPAR1)||' '||NUM(RECTELT1.WPPH1);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO MONTAGEM TELEFONE.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;

      FETCH WCURTELT1 INTO RECTELT1;
   END LOOP;

   CLOSE WCURTELT1;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      CLOSE WCURTELT1;
      TRATA_ERRO;
   WHEN OTHERS THEN
      CLOSE WCURTELT1;
      WRK_DES_ERR := 'ERRO OTHERS PCI_TEL_T1.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_TEL_T1;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_TEL_XE
IS
BEGIN

   WRK_TELEFONE := NULL;

   OPEN WCURTELXE;
   FETCH WCURTELXE INTO RECTELXE;
   LOOP
      EXIT WHEN WCURTELXE%NOTFOUND;
      BEGIN
         IF WRK_TELEFONE IS NULL THEN
            WRK_TELEFONE := NUM(RECTELXE.WPAR1)||' '||NUM(RECTELXE.WPPH1);
         ELSE
            WRK_TELEFONE := WRK_TELEFONE||';'||NUM(RECTELXE.WPAR1)||' '||NUM(RECTELXE.WPPH1);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO MONTAGEM TELEFONE.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;

      FETCH WCURTELXE INTO RECTELXE;
   END LOOP;

   CLOSE WCURTELXE;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      CLOSE WCURTELXE;
      TRATA_ERRO;
   WHEN OTHERS THEN
      CLOSE WCURTELXE;
      WRK_DES_ERR := 'ERRO OTHERS PCI_TEL_XE.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_TEL_XE;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_BAN
IS
BEGIN

   WRK_QTD_BAN         := 0;
   WRK_CHAVE_BANCO_ERP := NULL;
   WRK_CHAVE_BANCO_SAN := NULL;
   WRK_CONTA_BANCARIA  := NULL;
   WRK_CHAVE_CONTROLE  := NULL;
   WRK_TXT_BAN         := ' ';

   OPEN WCURBAN;
   FETCH WCURBAN INTO RECBAN;
   LOOP
      EXIT WHEN WCURBAN%NOTFOUND;
      BEGIN
         WRK_QTD_BAN := WRK_QTD_BAN + 1;
         IF WRK_QTD_BAN = 1 THEN
            WRK_CHAVE_BANCO_ERP := NUM(RECBAN.CHAVE_BANCO);
            WRK_CONTA_BANCARIA  := NUM(RECBAN.CONTA_BANCARIA);
            BEGIN
               SELECT PARA||SUBSTR(WRK_CHAVE_BANCO_ERP,4,LENGTH(WRK_CHAVE_BANCO_ERP)-3)
                 INTO WRK_CHAVE_BANCO_SAN
                 FROM DE_PARA_TB
                WHERE TIPO = 'BANCO'
                  AND DE   = SUBSTR(WRK_CHAVE_BANCO_ERP,1,3);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  WRK_CHAVE_BANCO_SAN := WRK_CHAVE_BANCO_ERP;
               WHEN OTHERS THEN
                  WRK_DES_ERR := 'ERRO LEITURA DE_PARA_TB(BANCO)='||SUBSTR(WRK_CHAVE_BANCO_ERP,1,3);
                  WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
                  RAISE WRK_EXCEPT_01;
            END;
            IF LENGTH(NUM(RECBAN.DIGITO)) = 1 THEN
               WRK_CHAVE_CONTROLE := NUM(RECBAN.DIGITO);
            ELSE
               WRK_CHAVE_CONTROLE := '$';
            END IF;
            IF LENGTH(NUM(RECBAN.AYCHKD)) = 1 THEN
               WRK_CHAVE_CONTROLE := WRK_CHAVE_CONTROLE||NUM(RECBAN.AYCHKD);
            ELSE
               WRK_CHAVE_CONTROLE := WRK_CHAVE_CONTROLE||' ';
            END IF;
         ELSE
            IF WRK_TXT_BAN = ' ' THEN
               WRK_TXT_BAN := RECBAN.AYTNST||'/'||RECBAN.CONTA_BANCARIA||'/'||RECBAN.AYCHKD;
            ELSE
               WRK_TXT_BAN := WRK_TXT_BAN||' '||RECBAN.AYTNST||'/'||RECBAN.CONTA_BANCARIA||'/'||RECBAN.AYCHKD;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO MONTAGEM BANCO.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            RAISE WRK_EXCEPT_01;
      END;

      FETCH WCURBAN INTO RECBAN;
   END LOOP;

   CLOSE WCURBAN;

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      CLOSE WCURBAN;
      TRATA_ERRO;
   WHEN OTHERS THEN
      CLOSE WCURBAN;
      WRK_DES_ERR := 'ERRO OTHERS PCI_BAN.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_BAN;
---------------------------------------------------------------------------------------------
PROCEDURE PCI_IRF
IS
BEGIN

   IF WRK_AIBRTAX IS NULL THEN
      RAISE WRK_SAIDA;
   END IF;

   IF WRK_STATUS_4 IS NULL THEN
      WRK_STATUS_4 := WRK_AIBRTAX;
   ELSE
      WRK_STATUS_4 := WRK_STATUS_4||';'||WRK_AIBRTAX;
   END IF;

   BEGIN
     SELECT PARA
       INTO WRK_PARA
       FROM DE_PARA_TB
      WHERE TIPO = 'IR'
        AND DE   = TRIM(WRK_AIBRTAX);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE WRK_SAIDA;
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO LEITURA DE_PARA_TB(IR)='||TRIM(WRK_AIBRTAX);
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         RAISE WRK_EXCEPT_01;
   END;

   IF WRK_COD_CATEGORIA_IRF IS NULL THEN
      WRK_COD_CATEGORIA_IRF := TRIM(WRK_PARA);
   ELSE
      WRK_COD_CATEGORIA_IRF := WRK_COD_CATEGORIA_IRF||';'||TRIM(WRK_PARA);
   END IF;

EXCEPTION
   WHEN WRK_SAIDA THEN
      NULL;
   WHEN WRK_EXCEPT_01 THEN
      TRATA_ERRO;
   WHEN OTHERS THEN
      WRK_DES_ERR := 'ERRO OTHERS PCI_IRF.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_IRF;
---------------------------------------------------------------------------------------------
FUNCTION NUM
    (PRM VARCHAR2)
    RETURN VARCHAR2
IS

   WRK_VAR  NUMBER;
   WRK_RES  VARCHAR2(2000);

BEGIN

   WRK_VAR := 1;

   LOOP
      EXIT WHEN WRK_VAR > LENGTH(PRM);
      IF SUBSTR(PRM,WRK_VAR,1) IN ('0','1','2','3','4','5','6','7','8','9') THEN
         WRK_RES := WRK_RES||SUBSTR(PRM,WRK_VAR,1);
      END IF;
      WRK_VAR := WRK_VAR + 1;
   END LOOP;
   RETURN WRK_RES;

END NUM;
---------------------------------------------------------------------------------------------
PROCEDURE TRATA_ERRO
IS
BEGIN

   IND_ERR     := TRUE;
   WRK_NUM_ERR := WRK_NUM_ERR + 1;

   ROLLBACK;
   INSERT INTO DSAPERR_TB
   VALUES (WRK_NOM_ROT,
           WRK_NUM_ERR,
           NVL(WRK_CHV_ERR,'X'),
           WRK_ERR_ORA,
           WRK_DES_ERR,
           WRK_DTH_ERR);

   COMMIT;

END TRATA_ERRO;
---------------------------------------------------------------------------------------------
PROCEDURE FCH_PRC
IS
BEGIN

   UPDATE DSAPERR_TB
      SET DES_ERR = 'PROCESSAMENTO TERMINADO.',
          CHV_ERR = 'FIM= '||TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI:SS')
    WHERE NOM_ROT = WRK_NOM_ROT
      AND NUM_ERR = 0;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END FCH_PRC;
---------------------------------------------------------------------------------------------
END PT1SAPFOR;
/