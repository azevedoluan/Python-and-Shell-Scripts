--TRIGGER CONTROLA ULTIMA DATA DE INSERT/UPDATE DO SALDO DE ESTOQUE
CREATE OR REPLACE TRIGGER SE_SAP_IU_TR
	BEFORE INSERT OR UPDATE ON STAGING_SALDOESTOQUE FOR EACH ROW
BEGIN
	--ATUALIZA DATA DE INSERT/UPDATE
	:NEW.STATUS_5 := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS');
END;
/