CREATE OR REPLACE PACKAGE PEXPSAPCAP
AS
   -- Sylvio Alves - 02/12/19 - Versão 19/12/19

   PROCEDURE PCI;

   PROCEDURE PCI_CAP;

   PROCEDURE TRATA_CAP;

   PROCEDURE TRATA_ERRO;

   PROCEDURE FCH_PRC;

   CURSOR WCURCAP IS
      SELECT NUM_DOC,
             TP_DOC_JDE,
             NUM_CIA,
             MAX(NVL(DT_DOC    ,' '))   DT_DOC,
             MAX(NVL(TP_DOC_SAP,' '))   TP_DOC_SAP,
             MAX(NVL(EMP1      ,' '))   EMP1,
             MAX(NVL("USER"    ,' '))   "USER",
             MAX(NVL(EXE       ,' '))   "EXE",
             MAX(NVL("REF"     ,' '))   "REF",
             MAX(NVL(TXT_H     ,' '))   TXT_H,
             MAX(NVL(COD_FORN  ,' '))   COD_FORN,
             MAX(NVL(EMP2      ,' '))   EMP2,
             MAX(NVL(COD_RZ    ,' '))   COD_RZ,
             MAX(NVL(DT_VEN    ,' '))   DT_VEN,
             MAX(NVL(FORM_PG   ,' '))   FORM_PG,
             MAX(NVL(BL_PAG    ,' '))   BL_PAG,
             MAX(NVL(DIV1      ,' '))   DIV1,
             MAX(NVL(ATR1      ,' '))   ATR1,
             MAX(NVL(TXT1      ,' '))   TXT1,
             MAX(NVL(BANCO     ,' '))   BANCO,
             MAX(NVL(CC        ,' '))   CC,
             MAX(NVL(TXT2      ,' '))   TXT2,
             MAX(NVL(EMP3      ,' '))   EMP3,
             MAX(NVL(DIV1      ,' '))   DIV2,
             MAX(NVL(ATR2      ,' '))   ATR2,
             MAX(NVL(MOEDA     ,' '))   MOEDA,
             CASE WHEN SUM(VL_LAN_IT1) < 0 THEN LTRIM(REPLACE(TO_CHAR((-1*SUM(VL_LAN_IT1)),'9999999999999990.00'),'.',','))||'-'
                  ELSE LTRIM(REPLACE(TO_CHAR(SUM(VL_LAN_IT1),'9999999999999990.00'),'.',',')) END VL_LAN_IT1,
             CASE WHEN SUM(VAL_BR) < 0 THEN LTRIM(REPLACE(TO_CHAR((-1*SUM(VAL_BR)),'9999999999999990.00'),'.',','))||'-'
                  ELSE LTRIM(REPLACE(TO_CHAR(SUM(VAL_BR),'9999999999999990.00'),'.',',')) END VAL_BR,
             MIN(DT_LAN)                DT_LAN
        FROM STAGING_CAP
       WHERE STATUS    = 'L'
         AND SITUACAO <> 'P'
   GROUP BY NUM_DOC,
            TP_DOC_JDE,
            NUM_CIA;
   RECCAP WCURCAP%ROWTYPE;


   WRK_SEQ                          INTEGER;
   WRK_NOM_ROT                      DSAPERR_TB.NOM_ROT%TYPE;
   WRK_NUM_ERR                      DSAPERR_TB.NUM_ERR%TYPE;
   WRK_CHV_ERR                      DSAPERR_TB.CHV_ERR%TYPE;
   WRK_ERR_ORA                      DSAPERR_TB.ERR_ORA%TYPE;
   WRK_DES_ERR                      DSAPERR_TB.DES_ERR%TYPE;
   WRK_DTH_ERR                      DSAPERR_TB.DTH_ERR%TYPE;
   WRK_NOM_ARQ_LOG                  UTL_FILE.FILE_TYPE;
   WRK_TXT                          NVARCHAR2(2000);
   WRK_NOM_DIR                      NVARCHAR2(60) := 'EXT_CAP_CAR';
   WRK_NOM_ARQ_FIS                  NVARCHAR2(60);
   WRK_LNH                          NVARCHAR2(200);

   WRK_EXCEPT_01                    EXCEPTION;
   WRK_SAIDA                        EXCEPTION;
   IND_ERR                          BOOLEAN;

END PEXPSAPCAP;
/

CREATE OR REPLACE PACKAGE BODY PEXPSAPCAP
AS
-- Sylvio Alves - 02/12/19 - Versão 19/12/19

PROCEDURE PCI
IS
BEGIN

   WRK_NOM_ROT := 'PEXPSAPCAP';
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

   PCI_CAP;

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
PROCEDURE PCI_CAP
IS
BEGIN

   WRK_NOM_ARQ_FIS := 'DSAPCAP'||TO_CHAR(SYSDATE,'YYMMDDHH24MISS')||'.TXT';
   BEGIN
      WRK_NOM_ARQ_LOG := UTL_FILE.FOPEN(WRK_NOM_DIR,WRK_NOM_ARQ_FIS,'W');
   EXCEPTION
      WHEN OTHERS THEN
         WRK_DES_ERR := 'ERRO ABERTURA DIRETORIO/ARQUIVO='||WRK_NOM_DIR||'-'||WRK_NOM_ARQ_FIS;
         WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
         RAISE WRK_EXCEPT_01;
   END;

   WRK_SEQ := 0;

   OPEN WCURCAP;
   FETCH WCURCAP INTO RECCAP;
   LOOP
      EXIT WHEN WCURCAP%NOTFOUND;

      BEGIN
         WRK_CHV_ERR := RECCAP.NUM_DOC||RECCAP.TP_DOC_JDE||RECCAP.NUM_CIA;
         TRATA_CAP;
      EXCEPTION
         WHEN WRK_EXCEPT_01 THEN
            TRATA_ERRO;
         WHEN OTHERS THEN
            WRK_DES_ERR := 'ERRO PCI 2.';
            WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
            TRATA_ERRO;
      END;

      FETCH WCURCAP INTO RECCAP;
   END LOOP;
   CLOSE WCURCAP;

   UTL_FILE.FCLOSE(WRK_NOM_ARQ_LOG);

EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      RAISE WRK_EXCEPT_01;
   WHEN OTHERS THEN
      CLOSE WCURCAP;
      WRK_DES_ERR := 'ERRO OTHERS PCI_CAP.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      TRATA_ERRO;
END PCI_CAP;
---------------------------------------------------------------------------------------------
PROCEDURE TRATA_CAP
IS
BEGIN

   WRK_SEQ := WRK_SEQ + 1;

   WRK_TXT := LPAD(WRK_SEQ,8,0)||';H;'||RECCAP."USER"||';'||RECCAP.DT_DOC||';'||RECCAP.TP_DOC_SAP||';'||RECCAP.EMP1||';'||RECCAP.DT_LAN||';'||RECCAP."EXE"||';'||RECCAP."REF"||';'||RECCAP.TXT_H;
   UTL_FILE.PUT_LINE(WRK_NOM_ARQ_LOG,WRK_TXT);

   WRK_TXT := LPAD(WRK_SEQ,8,0)||';P;0000000001;'||RECCAP.COD_FORN||';'||RECCAP.EMP2||';'||RECCAP.COD_RZ||';'||RECCAP.DT_VEN||';'||RECCAP.FORM_PG||';'||RECCAP.BL_PAG||';'||RECCAP.DIV1||';'||RECCAP.ATR1||';'||RECCAP.TXT1||';'||RECCAP.BANCO;
   UTL_FILE.PUT_LINE(WRK_NOM_ARQ_LOG,WRK_TXT);

   WRK_TXT := LPAD(WRK_SEQ,8,0)||';G;0000000002;'||RECCAP.CC||';'||RECCAP.TXT2||';'||RECCAP.EMP3||';'||RECCAP.DIV2||';'||RECCAP.ATR2;
   UTL_FILE.PUT_LINE(WRK_NOM_ARQ_LOG,WRK_TXT);

   WRK_TXT := LPAD(WRK_SEQ,8,0)||';A;0000000001;'||RECCAP.MOEDA||';'||RECCAP.VL_LAN_IT1;
   UTL_FILE.PUT_LINE(WRK_NOM_ARQ_LOG,WRK_TXT);

   WRK_TXT := LPAD(WRK_SEQ,8,0)||';A;0000000002;'||RECCAP.MOEDA||';'||RECCAP.VAL_BR;
   UTL_FILE.PUT_LINE(WRK_NOM_ARQ_LOG,WRK_TXT);


EXCEPTION
   WHEN WRK_EXCEPT_01 THEN
      RAISE WRK_EXCEPT_01;
   WHEN OTHERS THEN
      WRK_DES_ERR := 'ERRO OTHERS TRATA_CAP.';
      WRK_ERR_ORA := SQLCODE||'-'||SQLERRM;
      RAISE WRK_EXCEPT_01;
END TRATA_CAP;
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
END PEXPSAPCAP;
/