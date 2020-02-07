CREATE OR REPLACE PROCEDURE CARGA_MATERIAL_TONE_STAGING IS

	--VARIÁVEIS
	ID					NUMBER;
	CONTADOR			NUMBER;
	CONTADOR2			NUMBER;
	QTD_MAX				NUMBER;
	DESC_LONGA_AUX		CHAR(4000);
	CLASS_MAT_AUX		staging_material.class_mat%TYPE;
	FILIAL_ERP			staging_material.centro_erp%TYPE;
	FILIAL_SAN			staging_material.centro_san%TYPE;
	UM_ERP				staging_material.un_med_bas_erp%TYPE;
	UM_SAN				staging_material.un_med_bas_erp%TYPE;
	UM_PED_ERP			staging_material.un_med_ped_erp%TYPE;
	UM_PED_SAN			staging_material.un_med_ped_san%TYPE;
	UM_ALTER_ERP		staging_material.um_alt_erp%TYPE;
	UM_ALTER_SAN		staging_material.um_alt_san%TYPE;
	POS_ERP				staging_material.pos_dep_erp%TYPE;
	POS_SAN				staging_material.pos_dep_san%TYPE;
	PT_RB_ERP			staging_material.pt_reab_erp%TYPE;
	PR_RB_SAN			staging_material.pt_reab_san%TYPE;
	TM_FX_LT_ERP		staging_material.tam_fx_lt_erp%TYPE;
	TM_FX_LT_SAN		staging_material.tam_fx_lt_san%TYPE;
	centro_erp_aux		staging_material.centro_erp%TYPE;
	desc_erp_aux		staging_material.desc_erp%TYPE;
	un_med_bas_erp_aux	staging_material.un_med_bas_erp%TYPE;
	un_med_ped_erp_aux	staging_material.un_med_ped_erp%TYPE;
	um_alt_erp_aux		staging_material.um_alt_erp%TYPE;
	txt_lon_mm_erp_aux	staging_material.txt_lon_mm_erp%TYPE;
	ncm_erp_aux			staging_material.ncm_erp%TYPE;
	pos_dep_erp_aux		staging_material.pos_dep_erp%TYPE;
	prec_padr_erp_aux	staging_material.prec_padr_erp%TYPE;
	pt_reab_erp_aux		staging_material.pt_reab_erp%TYPE;
	tam_fx_lt_erp_aux	staging_material.tam_fx_lt_erp%TYPE;
	info_aux			staging_material.info%TYPE;
	DTA_ULT_MOV			DATE;
	DTA_ULT_MOV_AUX		CHAR(40);
	DTA_MAX_PRC			NUMBER;
	INFO_COMP			staging_material.info%TYPE;
	TXT_COMP			staging_material.info%TYPE;
	OPER				CHAR(1);
	V_BLQ				staging_material.blq%TYPE;
	V_DTA_ULT_MOV		staging_material.dta_ult_movi%TYPE;
	V_QTD_BAS			staging_material.qtd_bas%TYPE;
	V_QTD_BAS_AUX		staging_material.qtd_bas%TYPE;
	V_DEN_CONV			staging_material.den_conv_um%TYPE;

	--DADOS ITEM MESTRE
	CURSOR WCUR0 IS
		SELECT	A.IMITM CODIGO_ANTIGO,
				CAST(SUBSTR((TRIM(A.IMDSC1)||' '||TRIM(A.IMDSC2)),1,40) AS VARCHAR2( 40 CHAR))	DESC_CURTA,
				CAST(NVL(TRIM(C.ITBCLF),' ') AS VARCHAR2 ( 16 CHAR))							NCM,
				CAST(NVL(TRIM(B.IBMCU),' ') AS VARCHAR2( 12 CHAR))								FILIAL,
				NVL(TRIM(B.IBSRP0),' ')															CLASS_MAT
		FROM	F4101_TONE A
		LEFT JOIN	F4102_TONE	B	ON A.IMITM=B.IBITM
		LEFT JOIN	F76411_TONE	C ON A.IMITM=C.ITITM
		WHERE	A.IMITM > 1122200
		AND		(TO_DATE(SUBSTR(A.IMUPMJ,2,5),'RRDDD') >= (SELECT TO_DATE(data_proc-1) FROM STAGING_CONTROLE WHERE DADO = 'MATERIAL_TONE') OR TO_DATE(SUBSTR(B.IBUPMJ,2,5),'RRDDD') >= (SELECT TO_DATE(data_proc-1) FROM STAGING_CONTROLE WHERE DADO = 'MATERIAL_TONE') OR TO_DATE(SUBSTR(C.ITUPMJ,2,5),'RRDDD') >= (SELECT TO_DATE(data_proc-1) FROM STAGING_CONTROLE WHERE DADO = 'MATERIAL_TONE'));
	REC0 WCUR0 %ROWTYPE;

BEGIN

	OPEN WCUR0;
	FETCH WCUR0 INTO REC0;

	LOOP

		EXIT WHEN WCUR0%NOTFOUND;

		--VERIFICA SE ITEM FOI OBSOLETADO
		SELECT	COUNT(*)
		INTO	CONTADOR
		FROM	F4101_TONE
		WHERE	IMITM = REC0.CODIGO_ANTIGO
		AND TRIM(IMSTKT) = 'O';

		IF	CONTADOR > 0 THEN
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	STAGING_MATERIAL
			WHERE TO_NUMBER(TRIM(COD_ANTIGO)) = REC0.CODIGO_ANTIGO;

			IF CONTADOR = 0 THEN
				GOTO prox_mat;
			ELSE
				UPDATE	STAGING_MATERIAL
				SET		STATUS = 'O'
				WHERE	TO_NUMBER(TRIM(COD_ANTIGO)) = REC0.CODIGO_ANTIGO;

				COMMIT;

			END IF;

		ELSE
			--SETA CANTAGALO PARA ITENS SEM FILIAL
			IF REC0.FILIAL = ' ' THEN
				FILIAL_ERP := 'BR13120';
			ELSE
				FILIAL_ERP := REC0.FILIAL;
			END IF;
			--INDICA SE SERÁ UMA OPERAÇÃO DE INSERT OU UPDATE

			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	STAGING_MATERIAL
			WHERE	TO_NUMBER(TRIM(COD_ANTIGO)) = REC0.CODIGO_ANTIGO
			AND		CENTRO_ERP = FILIAL_ERP;

			IF CONTADOR = 0 THEN
				OPER := 'I';
			ELSE
				OPER := 'U';
			END IF;

			--OBTEM DESCRIÇÃO LONGA

			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	F00165_TONE
			WHERE	GDTXKY = TO_CHAR(REC0.CODIGO_ANTIGO);

			IF CONTADOR = 0 THEN
				DESC_LONGA_AUX := NULL;
			ELSE
				SELECT	GDTXFT
				INTO	DESC_LONGA_AUX
				FROM	F00165_TONE
				WHERE	GDTXKY = TO_CHAR(REC0.CODIGO_ANTIGO)
				AND		ROWNUM = 1;
			END IF;

			--DE/PARA DE FILIAIS
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO)='FILIAL'
			AND		TRIM(DE)=FILIAL_ERP;

			IF CONTADOR = 0 THEN
				FILIAL_SAN := ' ';
			ELSE
				SELECT	DISTINCT CAST(NVL(TRIM(PARA),' ') AS VARCHAR2( 4 CHAR)) FILIAL_SAN
				INTO	FILIAL_SAN
				FROM	DE_PARA_TB
				WHERE	TRIM(TIPO)='FILIAL'
				AND		TRIM(DE)=FILIAL_ERP;
			END IF;

			--OBTEM UNIDADE DE MEDIDA
			SELECT	DISTINCT CAST(NVL(TRIM(IMUOM1),' ') AS VARCHAR2( 3 CHAR)) UNIDAE_MEDIDA_ERP,
					CAST(NVL(TRIM(IMUOM3),' ') AS VARCHAR2( 3 CHAR)) UNIDAE_MEDIDA_PEDIDO_ERP,
					CAST(NVL(TRIM(IMUOM2),' ') AS VARCHAR2( 3 CHAR)) UNIDAE_MEDIDA_ALT_ERP
			INTO	UM_ERP,
					UM_PED_ERP,
					UM_ALTER_ERP
			FROM	F4101_TONE
			WHERE	IMITM = REC0.CODIGO_ANTIGO;

			--DE/PARA DE UNIDADE DE MEDIDA PARA TONELADA SECA
			IF	FILIAL_SAN = 'FARC' AND UM_ERP = 'TH' THEN
				UM_SAN := 'T1';
			ELSIF	FILIAL_SAN = 'FARJ' AND UM_ERP = 'TH' THEN
				UM_SAN := 'T2';
			ELSIF	FILIAL_SAN = 'FCTG' AND UM_ERP = 'TH' THEN
				UM_SAN := 'T3';
			ELSIF	FILIAL_SAN = 'FMTZ' AND UM_ERP = 'TH' THEN
				UM_SAN := 'T4';
			ELSIF	FILIAL_SAN = 'FSLU' AND UM_ERP = 'TH' THEN
				UM_SAN := 'T5';
			END IF;

			--DE/PARA DE UNIDADE DE MEDIDA DO PEDIDO PARA TONELADA SECA
			IF	FILIAL_SAN = 'FARC' AND UM_PED_ERP = 'TH' THEN
				UM_PED_SAN := 'T1';
			ELSIF	FILIAL_SAN = 'FARJ' AND UM_PED_ERP = 'TH' THEN
				UM_PED_SAN := 'T2';
			ELSIF	FILIAL_SAN = 'FCTG' AND UM_PED_ERP = 'TH' THEN
				UM_PED_SAN := 'T3';
			ELSIF	FILIAL_SAN = 'FMTZ' AND UM_PED_ERP = 'TH' THEN
				UM_PED_SAN := 'T4';
			ELSIF	FILIAL_SAN = 'FSLU' AND UM_PED_ERP = 'TH' THEN
				UM_PED_SAN := 'T5';
			END IF;

			--DE/PARA DE UNIDADE DE MEDIDA ALTERNATIVA PARA TONELADA SECA
			IF	FILIAL_SAN = 'FARC' AND UM_ALTER_ERP = 'TH' THEN
				UM_ALTER_SAN := 'T1';
				GOTO prox_param;
			ELSIF	FILIAL_SAN = 'FARJ' AND UM_ALTER_ERP = 'TH' THEN
				UM_ALTER_SAN := 'T2';
				GOTO prox_param;
			ELSIF	FILIAL_SAN = 'FCTG' AND UM_ALTER_ERP = 'TH' THEN
				UM_ALTER_SAN := 'T3';
				GOTO prox_param;
			ELSIF	FILIAL_SAN = 'FMTZ' AND UM_ALTER_ERP = 'TH' THEN
				UM_ALTER_SAN := 'T4';
				GOTO prox_param;
			ELSIF	FILIAL_SAN = 'FSLU' AND UM_ALTER_ERP = 'TH' THEN
				UM_ALTER_SAN := 'T5';
				GOTO prox_param;
			END IF;

			--DE/PARA DE UNIDADE DE MEDIDA
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO)='UMED'
			AND		TRIM(DE)=UM_ERP;

			IF	CONTADOR = 0 THEN
				UM_SAN := ' ';
			ELSE
				SELECT	DISTINCT CAST(NVL(TRIM(PARA),' ') AS VARCHAR2( 3 CHAR)) UNIDAE_MEDIDA_SAN
				INTO	UM_SAN
				FROM	DE_PARA_TB
				WHERE	TRIM(TIPO)='UMED'
				AND		TRIM(DE)=UM_ERP;
			END IF;

			--DE/PARA DE UNIDADE DE MEDIDA DO PEDIDO
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO)='UMED'
			AND		TRIM(DE)=UM_PED_ERP;

			IF	CONTADOR = 0 THEN
				UM_PED_SAN := ' ';
			ELSE
				SELECT	DISTINCT CAST(NVL(TRIM(PARA),' ') AS VARCHAR2( 3 CHAR)) UNIDAE_MEDIDA_SAN
				INTO	UM_PED_SAN
				FROM	DE_PARA_TB
				WHERE	TRIM(TIPO)='UMED'
				AND		TRIM(DE)=UM_PED_ERP;
			END IF;

			--DE/PARA DE UNIDADE DE MEDIDA ALTERNATIVA
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO)='UMED'
			AND		TRIM(DE)=UM_ALTER_ERP;

			IF	CONTADOR = 0 THEN
				UM_ALTER_SAN := ' ';
			ELSE
				SELECT	DISTINCT CAST(NVL(TRIM(PARA),' ') AS VARCHAR2( 3 CHAR)) UNIDAE_MEDIDA_SAN
				INTO	UM_ALTER_SAN
				FROM	DE_PARA_TB
				WHERE	TRIM(TIPO)='UMED'
				AND		TRIM(DE)=UM_ALTER_ERP;
			END IF;

			<<prox_param>>
			--OBTEM LOCAL DO ITEM
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	F41021_TONE
			WHERE	LIITM = REC0.CODIGO_ANTIGO
			AND		TRIM(LIMCU) = FILIAL_ERP
			AND		LIPBIN = 'P';

			IF CONTADOR = 0 THEN
				POS_ERP := ' ';
				POS_SAN := ' ';
			ELSE

				SELECT	DISTINCT CAST(NVL(TRIM(LILOCN),' ') AS VARCHAR2( 10 CHAR)) LOCAL_ERP,
						CAST(NVL(TRIM(LILOCN),' ') AS VARCHAR2( 10 CHAR)) LOCAL_SAN
				INTO	POS_ERP,
						POS_SAN
				FROM	F41021_TONE
				WHERE	LIITM = REC0.CODIGO_ANTIGO
				AND		TRIM(LIMCU) = FILIAL_ERP
				AND		LIPBIN = 'P';
			END IF;

			--VERIFICA PONTO DE REABASTECIMENTO E TAMANHO FIXO DO LOTE
			SELECT	COUNT(*)
			INTO	CONTADOR
			FROM	F4102_TONE
			WHERE	IBITM = REC0.CODIGO_ANTIGO
			AND		TRIM(IBMCU) = FILIAL_ERP;

			IF	CONTADOR = 0 THEN
				PT_RB_ERP := NULL;
				PR_RB_SAN := NULL;
				TM_FX_LT_ERP := NULL;
				TM_FX_LT_SAN := NULL;
			ELSE
				SELECT	DISTINCT ROUND(IBROQI/10000,3) TAM_FX_LOTE_ERP,
						ROUND(IBROQI/10000,3) TAM_FX_LOTE_SAN,
						ROUND(IBROPI/10000,3) PT_REAB_ERP,
						ROUND(IBROPI/10000,3) PT_REAB_SAN
				INTO	TM_FX_LT_ERP,
						TM_FX_LT_SAN,
						PT_RB_ERP,
						PR_RB_SAN
				FROM	F4102_TONE
				WHERE	IBITM = REC0.CODIGO_ANTIGO
				AND		TRIM(IBMCU) = FILIAL_ERP;

				IF TM_FX_LT_ERP > 0 AND PT_RB_ERP = 0 THEN
					PT_RB_ERP := 1.000;
					PR_RB_SAN := 1.000;
				ELSIF TM_FX_LT_ERP = 0 THEN
					PT_RB_ERP := NULL;
					PR_RB_SAN := NULL;
					TM_FX_LT_ERP := NULL;
					TM_FX_LT_SAN := NULL;
				END IF;
			END IF;

			--RECUPERA DATA DA ULTIMA MOVIMENTAÇÃO DO ITEM
			SELECT	COUNT(*)
			INTO	CONTADOR2
			FROM	F4111_TONE
			WHERE	ILITM=REC0.CODIGO_ANTIGO
			AND		TRIM(ILMCU)=FILIAL_ERP
			AND		ROWNUM = 1;

			IF CONTADOR2 = 0 THEN
				DTA_ULT_MOV_AUX := TO_CHAR(SYSDATE,'DD/MM/YYYY')||' (ITEM SEM FILIAL NO TONE)';
				INFO_COMP := 'ULTIMA MOVIMENTAÇÃO (FILIAL '||FILIAL_ERP||') = '||DTA_ULT_MOV_AUX;
			ELSE
				SELECT	MAX(TO_DATE(SUBSTR(ILTRDJ,2,5),'RRDDD'))
				INTO	DTA_ULT_MOV
				FROM	F4111_TONE
				WHERE	ILITM=REC0.CODIGO_ANTIGO
				AND		TRIM(ILMCU)=FILIAL_ERP;

				SELECT	COUNT(*)
				INTO	CONTADOR
				FROM	F41021_TONE
				WHERE	LIITM = REC0.CODIGO_ANTIGO
				AND		TRIM(LIMCU) = FILIAL_ERP
				AND		LIPBIN <> 'P';

				IF	CONTADOR = 0 THEN
					INFO_COMP := 'ULTIMA MOVIMENTAÇÃO (FILIAL '||FILIAL_ERP||') = '||TO_CHAR(DTA_ULT_MOV,'DD/MM/YYYY');
				ELSE
					TXT_COMP := ' - POSSUI LOCAL SECUNDÁRIO';
					INFO_COMP := 'ULTIMA MOVIMENTAÇÃO (FILIAL '||FILIAL_ERP||') = '||TO_CHAR(DTA_ULT_MOV,'DD/MM/YYYY')||TXT_COMP;
				END IF;
			END IF;
			
			--UNIDADE DE CONVERSÃO DE UM PARA UM
			BEGIN
				SELECT	NVL(TRIM(TO_CHAR(UMCONV/10000000,'99999999999.99')), '0.00')
				INTO	V_QTD_BAS
				FROM	F41002_TONE
				WHERE	UMITM = REC0.CODIGO_ANTIGO
				AND		TRIM(UMMCU) = FILIAL_ERP;
				
				V_DEN_CONV := '1';
				
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_QTD_BAS := '0.00';
					V_DEN_CONV := NULL;
				WHEN OTHERS THEN
					NULL;
			END;

			--INSERT NA TABELA STAGING_MATERIAL

			IF OPER = 'I' THEN
				--GERA ID DE INSERÇÃO
				ID := STAGING_MATERIAL_SQ.NEXTVAL;

				INSERT INTO STAGING_MATERIAL
						(id,
						cod_antigo,
						centro_erp,
						centro_san,
						dep,
						desc_erp,
						desc_san,
						un_med_bas_erp,
						un_med_bas_san,
						un_med_ped_erp,
						un_med_ped_san,
						um_alt_erp,
						um_alt_san,
						txt_lon_mm_erp,
						txt_lon_mm_san,
						ncm_erp,
						ncm_san,
						pos_dep_erp,
						pos_dep_san,
						un_prec,
						pt_reab_erp,
						pt_reab_san,
						tam_fx_lt_erp,
						tam_fx_lt_san,
						status,
						info,
						class_mat,
						dta_ult_movi,
						qtd_bas)
				VALUES (ID,
						REC0.CODIGO_ANTIGO,
						FILIAL_ERP,
						FILIAL_SAN,
						'D001',
						REC0.DESC_CURTA,
						REC0.DESC_CURTA,
						UM_ERP,
						UM_SAN,
						UM_PED_ERP,
						UM_PED_SAN,
						UM_ALTER_ERP,
						UM_ALTER_SAN,
						DESC_LONGA_AUX,
						DESC_LONGA_AUX,
						REC0.NCM,
						REC0.NCM,
						POS_ERP,
						POS_SAN,
						'1',
						PT_RB_ERP,
						PR_RB_SAN,
						TM_FX_LT_ERP,
						TM_FX_LT_SAN,
						'P',
						INFO_COMP,
						REC0.CLASS_MAT,
						TO_CHAR(DTA_ULT_MOV,'DD/MM/YYYY'),
						V_QTD_BAS);

				COMMIT;

			ELSE
				SELECT COUNT(*)
				INTO CONTADOR
				FROM	STAGING_MATERIAL
				WHERE	TO_NUMBER(TRIM(cod_antigo)) = REC0.CODIGO_ANTIGO
				AND		centro_erp = FILIAL_ERP;

				IF CONTADOR = 0 THEN
					GOTO prox_mat;
				ELSE
					SELECT	NVL(TRIM(centro_erp),' '),
							NVL(TRIM(desc_erp),' '),
							NVL(TRIM(un_med_bas_erp),' '),
							NVL(TRIM(un_med_ped_erp),' '),
							NVL(TRIM(um_alt_erp),' '),
							NVL(TRIM(TO_CHAR(txt_lon_mm_erp)),' '),
							NVL(TRIM(ncm_erp),'1'),
							NVL(TRIM(pos_dep_erp),' '),
							NVL(pt_reab_erp,0),
							NVL(tam_fx_lt_erp,0),
							NVL(TRIM(TO_CHAR(info)), ' '),
							NVL(TRIM(class_mat),' '),
							NVL(TRIM(dta_ult_movi), ' '),
							NVL(TRIM(qtd_bas), '0.00')
					INTO	centro_erp_aux,
							desc_erp_aux,
							un_med_bas_erp_aux,
							un_med_ped_erp_aux,
							um_alt_erp_aux,
							txt_lon_mm_erp_aux,
							ncm_erp_aux,
							pos_dep_erp_aux,
							pt_reab_erp_aux,
							tam_fx_lt_erp_aux,
							info_aux,
							class_mat_aux,
							v_dta_ult_mov,
							v_qtd_bas_aux
					FROM	STAGING_MATERIAL
					WHERE	TO_NUMBER(TRIM(cod_antigo)) = REC0.CODIGO_ANTIGO
					AND		centro_erp = FILIAL_ERP;

					IF	(NVL(TRIM(FILIAL_ERP)				, ' ')	<> NVL(TRIM(centro_erp_aux)					, ' ') 	OR 
						 NVL(TRIM(REC0.DESC_CURTA)			, ' ')	<> NVL(TRIM(desc_erp_aux)					, ' ') 	OR 
						 NVL(TRIM(UM_ERP)					, ' ')	<> NVL(TRIM(un_med_bas_erp_aux)				, ' ') 	OR 
						 NVL(TRIM(UM_PED_ERP)				, ' ')	<> NVL(TRIM(un_med_ped_erp_aux)				, ' ') 	OR 
						 NVL(TRIM(UM_ALTER_ERP)				, ' ')	<> NVL(TRIM(um_alt_erp_aux)					, ' ') 	OR 
						 NVL(TRIM(TO_CHAR(DESC_LONGA_AUX))	, ' ')	<> NVL(TRIM(TO_CHAR(txt_lon_mm_erp_aux))	, ' ') 	OR 
						 NVL(TRIM(REC0.NCM)					, ' ')	<> NVL(TRIM(ncm_erp_aux)					, ' ') 	OR 
						 NVL(TRIM(POS_ERP)					, ' ')	<> NVL(TRIM(pos_dep_erp_aux)				, ' ') 	OR 
						 NVL(PT_RB_ERP						,   0)	<> NVL(pt_reab_erp_aux						,   0) 	OR 
						 NVL(TM_FX_LT_ERP					,   0)	<> NVL(tam_fx_lt_erp_aux					,   0) 	OR 
						 NVL(TRIM(REC0.CLASS_MAT)			, ' ')	<> NVL(TRIM(class_mat_aux)					, ' ')) THEN
						UPDATE	STAGING_MATERIAL
						SET		centro_erp = FILIAL_ERP,
								desc_erp = REC0.DESC_CURTA,
								un_med_bas_erp = UM_ERP,
								un_med_ped_erp = UM_PED_ERP,
								um_alt_erp = UM_ALTER_ERP,
								txt_lon_mm_erp = DESC_LONGA_AUX,
								ncm_erp = REC0.NCM,
								pos_dep_erp = POS_ERP,
								pt_reab_erp = PT_RB_ERP,
								tam_fx_lt_erp = TM_FX_LT_ERP,
								status = 'P',
								info = INFO_COMP,
								class_mat = REC0.CLASS_MAT,
								dta_ult_movi = TO_CHAR(DTA_ULT_MOV,'DD/MM/YYYY'),
								qtd_bas = V_QTD_BAS,
								den_conv_um = V_DEN_CONV
						WHERE	TO_NUMBER(TRIM(cod_antigo)) = REC0.CODIGO_ANTIGO
						AND		centro_erp = FILIAL_ERP
						AND		STATUS IN ('P','L','E');

						COMMIT;

					ELSIF	(NVL(TRIM(TO_CHAR(INFO_COMP))					,    ' ')	<> NVL(TRIM(TO_CHAR(info_aux))	, 	 ' ')	OR 
							 NVL(TRIM(TO_CHAR(DTA_ULT_MOV,'DD/MM/YYYY'))	,    ' ')	<> NVL(TRIM(v_dta_ult_mov)		, 	 ' ')	OR 
							 NVL(TRIM(V_QTD_BAS)							, '0.00')	<> NVL(TRIM(v_qtd_bas_aux)		, '0.00'))	THEN
						UPDATE	STAGING_MATERIAL
						SET		info = INFO_COMP,
								qtd_bas = V_QTD_BAS,
								den_conv_um = V_DEN_CONV,
								dta_ult_movi = TO_CHAR(DTA_ULT_MOV,'DD/MM/YYYY')
						WHERE	TO_NUMBER(TRIM(cod_antigo)) = REC0.CODIGO_ANTIGO
						AND		centro_erp = FILIAL_ERP
						AND		STATUS IN ('P','L','E');

						COMMIT;

					END IF;
				END IF;
			END IF;

		END IF;

		<<prox_mat>>
		FETCH WCUR0 INTO REC0;
	END LOOP;

	CLOSE WCUR0;

	UPDATE STAGING_CONTROLE SET DATA_PROC = SYSDATE WHERE DADO = 'MATERIAL_TONE';
	COMMIT;

END;
