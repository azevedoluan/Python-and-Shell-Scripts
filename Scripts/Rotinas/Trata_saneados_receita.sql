CREATE OR REPLACE PROCEDURE TRATA_SANEADOS_RECEITA_STAGING IS

	CURSOR WCUR IS
		SELECT	TRIM(CODIGO_ANTIGO)	COD_ANTIGO,
				TRIM(TIPO_CADASTRO)	TP_CAD
		FROM	STAGING_FORNECEDOR_CLIENTE
		WHERE	TRIM(STATUS_1) NOT LIKE '%ATIVA%'
		AND TIPO_CADASTRO IN ('T','TB','V');
	REC WCUR %ROWTYPE;

BEGIN
	OPEN WCUR;
	FETCH WCUR INTO REC;

	LOOP
		EXIT WHEN WCUR%NOTFOUND;

		BEGIN
			UPDATE	STAGING_FORNECEDOR_CLIENTE
			SET		STATUS = 'N'
			WHERE	TRIM(CODIGO_ANTIGO) = REC.COD_ANTIGO
			AND		TRIM(TIPO_CADASTRO) = REC.TP_CAD;

			COMMIT;

		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO UPDATE CODIGO_ANTIGO: '||REC.COD_ANTIGO||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;
		FETCH WCUR INTO REC;
	END LOOP;
	COMMIT;
	CLOSE WCUR;
END;
