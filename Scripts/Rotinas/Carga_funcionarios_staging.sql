CREATE OR REPLACE PROCEDURE CARGA_FUNCIONARIO_STAGING IS

	CURSOR WCUR IS
		SELECT	TRIM(F.FUNOMFUNC)																			NOME_COMP,
				SUBSTR(SUBSTR(TRIM(F.FUNOMFUNC),1,INSTR(TRIM(F.FUNOMFUNC),' ',-1,1)-1),1,40)				NOME,
				SUBSTR(TRIM(F.FUNOMFUNC),INSTR(TRIM(F.FUNOMFUNC),' ',-1,1)+1,LENGTH(TRIM(F.FUNOMFUNC)))		SOBRENOME,
				TRIM(F.FUCODTIPOLOGRADOURO)																	COD_END,
				TRIM(FUCODMUNIC)																			COD_MUN,
				TRIM(F.FUENDERECO)																			ENDERECO,
				SUBSTR(TRIM(F.FUNUMERO),1,10)																NUM,
				SUBSTR(TRIM(F.FUCOMPLEMENTO),1,40)															COMP,
				SUBSTR(TRIM(F.FUBAIRRO),1,40)																BAIRRO,
				TRIM(LPAD(F.FUCEP,8,0))																		CEP,
				TRIM(SUBSTR(LPAD(F.FUCEP,8,0),1,5)||'-'||SUBSTR(LPAD(F.FUCEP,8,0),6,8))						CEP_FORMAT,
				TRIM(F.FUEMAIL)																				EMAIL,
				TRIM(F.FUDDD||' '||F.FUTELEFONE)															TELEFONE,
				TRIM(F.FUDDD||' '||F.FUCELULAR)																CELULAR,
				TRIM(LPAD(F.FUCPF,11,0))																	CPF,
				TRIM(F.FUCODBCOPG)																			COD_BANCO,
				SUBSTR(TRIM(F.FUCODAGEPG),1,4)																AGENCIA_ND,
				SUBSTR(TRIM(F.FUCCORPAG),1,LENGTH(TRIM(F.FUCCORPAG))-1)										NUM_CONTA,
				TRIM(SUBSTR(F.FUCODAGEPG,5,5)||SUBSTR(F.FUCCORPAG,LENGTH(FUCCORPAG)))						DIGITO_VER,
				TO_CHAR(F.FUMATFUNC)																		MATRICULA,
				TO_CHAR(TO_DATE(F.FUDTADMIS , 'YYYYMMDD'),'DDMMYYYY')										DATA_VAL,
				TO_CHAR(TO_DATE(F.FUDTNASC, 'YYYYMMDD'), 'DDMMYYYY')										DATA_NASC,
				DECODE (F.FUNACIONAL,	'10','BR',
										'20','BR',
										'21','AR',
										'22','BL',
										'23','CL',
										'24','PA',
										'25','UY',
										'30','GM',
										'31','BE',
										'32','UK',
										'34','CA',
										'35','SP',
										'36','US',
										'37','FR',
										'38','SZ',
										'39','IT',
										'41','JP',
										'42','CH',
										'43','KS',
										'45','PT')															NACIONALIDADE,
				DECODE (F.FUESTCIVIL ,	'1','SOLTEIRO',
										'2','CASADO',
										'3','SEPARADO',
										'4','DIVORCIADO',
										'5','VIÚVO',
										'6','OUTROS',
										'7','IGNORADO')														ESTADOCIVIL,
				TRIM(F.FUSEXFUNC)																			SEXO,
				TRIM(F.FUCENTRCUS)																			CENTRO_CUSTO,
				TRIM('BR1' ||RPAD(SUBSTR(LPAD(FUCODLOT, 12, 0),1,3),4,0))									FILIALCONTAB,
				TRIM(F.FUCODCARGO)																			COD_CARGO
		FROM	FUNCIONA_ST	F
		WHERE	F.FUCODSITU IN ('1', '7', '8', '9', '10', '11', '12', '13','14', '41','36', '45','2','3','4', '5', '6', '31', '32', '33', '34', '35','37','39', '40', '43','44')
		AND		TRIM(F.FUCODEMP) = '12';
	REC WCUR %ROWTYPE;

	CURSOR WCUR1 IS
		SELECT	TRIM(A.CODIGO_ANTIGO)	COD_ANTIGO
		FROM	STAGING_FORNECEDOR_CLIENTE A
		INNER JOIN FUNCIONA_ST B ON TRIM(A.MAT) = TO_CHAR(B.FUMATFUNC)
		WHERE	B.FUCODSITU NOT IN ('1', '7', '8', '9', '10', '11', '12', '13','14', '41','36', '45','2','3','4', '5', '6', '31', '32', '33', '34', '35','37','39', '40', '43','44','26', '27')
		AND		TRIM(B.FUCODEMP) = '12'
		AND		A.TIPO_CADASTRO = 'E';
	REC1 WCUR1 %ROWTYPE;

	V_TPLOG					VARCHAR2(15);
	V_ENDERECO				VARCHAR2(60);
	V_CIDADE				VARCHAR2(30);
	V_UF					VARCHAR2(2);
	V_CODFISC				VARCHAR2(7);
	V_DOMFISC				VARCHAR2(10);
	V_CC					VARCHAR2(10);
	V_CODBAN				VARCHAR2(4);
	V_CHAVE					VARCHAR2(15);
	V_FILIAL				VARCHAR2(4);
	V_TPCAD					VARCHAR2(1);
	V_MASC					VARCHAR2(1);
	V_FEM					VARCHAR2(1);
	V_AN8					VARCHAR2(20);
	I						NUMBER;
	V_DIGITO				VARCHAR2(2);
	V_DIGITO_AUX			VARCHAR2(1);
	V_VALOR					NUMBER;
	V_CONTA					VARCHAR2(20);
	V_BANCO					VARCHAR2(10);
	V_AGENCIA				VARCHAR2(10);
	V_FT					staging_fornecedor_cliente.fT%TYPE;
	V_FT_AUX				staging_fornecedor_cliente.fT%TYPE;
	V_FPAG					staging_fornecedor_cliente.forma_pagamento_san%TYPE;
	V_COD_ANTIGO			staging_fornecedor_cliente.codigo_antigo%TYPE;
	V_NOME_1_ERP			staging_fornecedor_cliente.nome_1_erp%TYPE;
	V_NOME_2_ERP			staging_fornecedor_cliente.nome_2_erp%TYPE;
	V_RUA_ERP				staging_fornecedor_cliente.rua_erp%TYPE;
	V_NUMERO_ERP			staging_fornecedor_cliente.numero_erp%TYPE;
	V_COMPLEMENTO_ERP		staging_fornecedor_cliente.complemento_erp%TYPE;
	V_BAIRRO_ERP			staging_fornecedor_cliente.bairro_erp%TYPE;
	V_CEP_ERP				staging_fornecedor_cliente.cep_erp%TYPE;
	V_CIDADE_ERP			staging_fornecedor_cliente.cidade_erp%TYPE;
	V_UF_ERP				staging_fornecedor_cliente.uf_erp%TYPE;
	V_EMAIL_ERP				staging_fornecedor_cliente.email_erp%TYPE;
	V_TELEFONE_ERP			staging_fornecedor_cliente.telefone_erp%TYPE;
	V_CELULAR_ERP			staging_fornecedor_cliente.celular_erp%TYPE;
	V_CPF_ERP				staging_fornecedor_cliente.cpf_erp%TYPE;
	V_CHAVE_BANCO_ERP		staging_fornecedor_cliente.chave_banco_erp%TYPE;
	V_CONTA_BANCARIA_ERP	staging_fornecedor_cliente.conta_bancaria_erp%TYPE;
	V_CHAVE_CONTROLE_ERP	staging_fornecedor_cliente.chave_controle_erp%TYPE;
	V_DOM_FISCAL_ERP		staging_fornecedor_cliente.dom_fiscal_erp%TYPE;
	V_DTA_VAL				staging_fornecedor_cliente.dta_val%TYPE;
	V_DTA_NASC				staging_fornecedor_cliente.dta_nasc%TYPE;
	V_PS_NASC				staging_fornecedor_cliente.ps_nasc%TYPE;
	V_NAC					staging_fornecedor_cliente.nac%TYPE;
	V_ES_CIVIL				staging_fornecedor_cliente.es_civil%TYPE;
	V_MASCS					staging_fornecedor_cliente.masc%TYPE;
	V_FEMS					staging_fornecedor_cliente.fem%TYPE;
	V_CCS					staging_fornecedor_cliente.cc%TYPE;
	V_OE					staging_fornecedor_cliente.oe%TYPE;
	V_SUB					staging_fornecedor_cliente.sub%TYPE;
	V_APFG					staging_fornecedor_cliente.apfg%TYPE;
	V_CARGO					staging_fornecedor_cliente.cargo%TYPE;
	V_CARGO_SAP				staging_fornecedor_cliente.cargo%TYPE;
	V_POS_SAP				staging_fornecedor_cliente.cargo%TYPE;

BEGIN
	OPEN WCUR;
	FETCH WCUR INTO REC;
	I := 0;

	LOOP
		EXIT WHEN WCUR%NOTFOUND;
		V_CODFISC := NULL;
		V_DOMFISC := NULL;
		V_DIGITO_AUX := NULL;
		V_DIGITO := NULL;

		--RECUPERA  TIPO DE LOGRADOURO (RUA, AVENIDA, ETC...)
		BEGIN
			SELECT	TLODESCRICAO
			INTO	V_TPLOG
			FROM	TIPOLOGRADOURO
			WHERE	REC.COD_END = TLOCODIGO;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_TPLOG := NULL;
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO TPLOG; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;

		--RECUPERA UF E CIDADE DO FUNCIONA_STRIO
		BEGIN
			SELECT	TRIM(MUDESMUNIC),
					TRIM(MUUF)
			INTO	V_CIDADE,
					V_UF
			FROM	MUNICIP
			WHERE	REC.COD_MUN = MUCODMUNIC;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_CIDADE := NULL;
				V_UF := NULL;
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO CIDADE/UFF; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;

		--GERA DOMICILIO FISCAL
		V_CODFISC := MUN_CEP.PCI_FN(REC.CEP);
		IF LENGTH(V_CODFISC) < 7 THEN
			V_DOMFISC := NULL;
		ELSE
			V_DOMFISC := V_UF||' '||V_CODFISC;
		END IF;

		--GERA ENDEREÇO DO FUNCIONÁRIO
		V_ENDERECO := SUBSTR(V_TPLOG||' '||REC.ENDERECO,1,60);

		--RECUPERA CÓDIGO ANTIGO DO FUNCIONÁRIO
		BEGIN
			SELECT	ABAN8,
					TRIM(ABAT1)
			INTO	V_AN8,
					V_TPCAD
			FROM	F0101
			WHERE	TRIM(ABTAX) = REC.CPF
			AND		TRIM(ABAT1) = 'E'
			AND		ABUPMJ	= (SELECT	MAX(ABUPMJ)
							   FROM		F0101
							   WHERE	TRIM(ABTAX) = REC.CPF
							   AND		TRIM(ABAT1) = 'E')
			AND		ROWNUM = 1;

			V_AN8 := 'T'||V_AN8;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				I := FUNC_SEQ.NEXTVAL;
				V_AN8 := 'SEM AN8'||I;
			WHEN OTHERS THEN
				V_AN8 := 'SEM AN8'||I;
				DBMS_OUTPUT.PUT_LINE('ERRO AN8; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;
		
		--RECUPERA CONTA DE REEMBOLSO
		BEGIN
			SELECT	TRIM(AFVALOR)
			INTO	V_VALOR
			FROM	ATRIBFUN_ST
			WHERE	AFMATFUNC = REC.MATRICULA
			AND		AFCODATRIB = 30
			AND		AFVALOR = 1
			AND		AFCODEMP = 12;
			
			SELECT	TRIM(AFVALOR)
			INTO	V_BANCO
			FROM	ATRIBFUN_ST
			WHERE	AFMATFUNC = REC.MATRICULA
			AND		AFCODATRIB = 44
			AND		AFCODEMP = 12;
			
			SELECT	TRIM(REPLACE(AFVALOR,'-',''))
			INTO	V_AGENCIA
			FROM	ATRIBFUN_ST
			WHERE	AFMATFUNC = REC.MATRICULA
			AND		AFCODATRIB = 45
			AND		AFCODEMP = 12;
			
			IF	LENGTH(V_AGENCIA) > 4 THEN
				V_DIGITO_AUX := SUBSTR(V_AGENCIA,LENGTH(V_AGENCIA));
				V_AGENCIA := SUBSTR(V_AGENCIA,1,4);
			END IF;
			
			SELECT	TRIM(AFVALOR)
			INTO	V_CONTA
			FROM	ATRIBFUN_ST
			WHERE	AFMATFUNC = REC.MATRICULA
			AND		AFCODATRIB = 46
			AND		AFCODEMP = 12;
			
			SELECT	TRIM(AFVALOR)
			INTO	V_DIGITO
			FROM	ATRIBFUN_ST
			WHERE	AFMATFUNC = REC.MATRICULA
			AND		AFCODATRIB = 47
			AND		AFCODEMP = 12;
			
			IF V_DIGITO_AUX IS NULL THEN
				V_DIGITO := '$'||V_DIGITO;
			ELSE
				V_DIGITO := V_DIGITO_AUX||V_DIGITO;
			END IF;
			
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_BANCO := REC.COD_BANCO;
				V_AGENCIA := REC.AGENCIA_ND;
				V_CONTA := REC.NUM_CONTA;
				IF LENGTH(REC.DIGITO_VER) = 1 THEN
					V_DIGITO := '$'||REC.DIGITO_VER;
				ELSE
					V_DIGITO := REC.DIGITO_VER;
				END IF;
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO CONTA REEMBOLSO; MAT = '||REC.MATRICULA||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				V_BANCO := NULL;
				V_AGENCIA := NULL;
				V_CONTA := NULL;
				V_DIGITO := NULL;
				NULL;
		END;
		
		--IDENTIFICA FORMA DE PAGAMENTO
		IF TRIM(V_BANCO) = 341 THEN
			V_FPAG := 'U';
		ELSE
			V_FPAG := 'T';
		END IF;
		--RECUPERA CODIGO DO BANCO COM DÍGITO
		BEGIN
			SELECT	TRIM(PARA)
			INTO	V_CODBAN
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO) = 'BANCO'
			AND		TRIM(DE) = V_BANCO;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_CODBAN := NULL;
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO CODBAN; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;

		IF V_CODBAN IS NULL THEN
			V_CHAVE := V_BANCO||V_AGENCIA;
		ELSE
			V_CHAVE := V_CODBAN||V_AGENCIA;
		END IF;

		--DEFINE SE MASCULINO OU FEMINIO
		IF REC.SEXO = 'M' THEN
			V_MASC := 'X';
			V_FEM := NULL;
			V_FT := 'Sr.';
		ELSIF REC.SEXO = 'F' THEN
			V_MASC := NULL;
			V_FEM := 'X';
			V_FT := 'Sra.';
		ELSE
			V_MASC := NULL;
			V_FEM := NULL;
			V_FT := NULL;
		END IF;

		--DE/PARA DE FILIAL
		BEGIN
			SELECT	TRIM(PARA)
			INTO	V_FILIAL
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO) = 'FILIAL'
			AND		TRIM(DE) = REC.FILIALCONTAB;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_FILIAL := NULL;
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO FILIAL; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;

		--DE/PARA DE CENTRO DE CUSTO
		BEGIN
			SELECT	TRIM(PARA)
			INTO	V_CC
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO) = 'CC'
			AND		TRIM(DE) = REC.MATRICULA||REC.CENTRO_CUSTO;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_CC := ' ';
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO CENTRO DE CUSTO; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;
		
		--DE/PARA DE CARGO
		BEGIN
			SELECT	TRIM(PARA)
			INTO	V_CARGO_SAP
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO) = 'CARGO'
			AND		TRIM(DE) = REC.COD_CARGO;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_CARGO_SAP := ' ';
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO CARGO; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;
		
		--DE/PARA DE POSIÇÃO
		BEGIN
			SELECT	TRIM(PARA)
			INTO	V_POS_SAP
			FROM	DE_PARA_TB
			WHERE	TRIM(TIPO) = 'POS'
			AND		TRIM(DE) = REC.COD_CARGO;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_POS_SAP := ' ';
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO CARGO; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;

		--ATUALIZA FUNCIONÁRIO EXISTENTE
		BEGIN
			SELECT	NVL(TRIM(CODIGO_ANTIGO),' '),
					NVL(TRIM(nome_1_erp),' '),
					NVL(TRIM(nome_2_erp),' '),
					NVL(TRIM(rua_erp),' '),
					NVL(TRIM(numero_erp),' '),
					NVL(TRIM(complemento_erp),' '),
					NVL(TRIM(bairro_erp),' '),
					NVL(TRIM(cep_erp),' '),
					NVL(TRIM(cidade_erp),' '),
					NVL(TRIM(uf_erp),' '),
					NVL(TRIM(TO_CHAR(email_erp)),' '),
					NVL(TRIM(TO_CHAR(telefone_erp)), ' '),
					NVL(TRIM(TO_CHAR(celular_erp)), ' '),
					NVL(TRIM(cpf_erp),' '),
					NVL(TRIM(chave_banco_erp),' '),
					NVL(TRIM(conta_bancaria_erp),' '),
					NVL(TRIM(chave_controle_erp),' '),
					NVL(TRIM(dom_fiscal_erp),' '),
					NVL(TRIM(dta_val), ' '),
					NVL(TRIM(dta_nasc),' '),
					NVL(TRIM(ps_nasc), ' '),
					NVL(TRIM(nac),' '),
					NVL(TRIM(es_civil),' '),
					NVL(TRIM(masc),' '),
					NVL(TRIM(fem),' '),
					NVL(TRIM(cc),' '),
					NVL(TRIM(oe),' '),
					NVL(TRIM(sub),' '),
					NVL(TRIM(apfg),' '),
					NVL(TRIM(cargo),' '),
					NVL(TRIM(ft),' ')
			INTO	V_COD_ANTIGO,
					V_NOME_1_ERP,
					V_NOME_2_ERP,
					V_RUA_ERP,
					V_NUMERO_ERP,
					V_COMPLEMENTO_ERP,
					V_BAIRRO_ERP,
					V_CEP_ERP,
					V_CIDADE_ERP,
					V_UF_ERP,
					V_EMAIL_ERP,
					V_TELEFONE_ERP,
					V_CELULAR_ERP,
					V_CPF_ERP,
					V_CHAVE_BANCO_ERP,
					V_CONTA_BANCARIA_ERP,
					V_CHAVE_CONTROLE_ERP,
					V_DOM_FISCAL_ERP,
					V_DTA_VAL,
					V_DTA_NASC,
					V_PS_NASC,
					V_NAC,
					V_ES_CIVIL,
					V_MASC,
					V_FEM,
					V_CCS,
					V_OE,
					V_SUB,
					V_APFG,
					V_CARGO,
					V_FT_AUX
			FROM	STAGING_FORNECEDOR_CLIENTE
			WHERE	TRIM(CPF_ERP) = REC.CPF
			AND		TIPO_CADASTRO = 'E';

			IF	(NVL(TRIM(REC.NOME)				, ' ')	<>	NVL(TRIM(V_NOME_1_ERP)			, ' ')	OR
				 NVL(TRIM(REC.SOBRENOME)		, ' ')	<>	NVL(TRIM(V_NOME_2_ERP)			, ' ')	OR
				 NVL(TRIM(V_ENDERECO)			, ' ')	<>	NVL(TRIM(V_RUA_ERP)				, ' ')	OR
				 NVL(TRIM(REC.NUM)				, ' ')	<>	NVL(TRIM(V_NUMERO_ERP)			, ' ')	OR
				 NVL(TRIM(REC.COMP)				, ' ')	<>	NVL(TRIM(V_COMPLEMENTO_ERP)		, ' ')	OR
				 NVL(TRIM(REC.BAIRRO)			, ' ')	<>	NVL(TRIM(V_BAIRRO_ERP)			, ' ')	OR
				 NVL(TRIM(REC.CEP_FORMAT)		, ' ')	<>	NVL(TRIM(V_CEP_ERP)				, ' ')	OR
				 NVL(TRIM(V_CIDADE)				, ' ')	<>	NVL(TRIM(V_CIDADE_ERP)			, ' ')	OR
				 NVL(TRIM(V_UF)					, ' ')	<>	NVL(TRIM(V_UF_ERP)				, ' ')	OR
				 NVL(TRIM(REC.TELEFONE)			, ' ')	<>	NVL(TRIM(V_TELEFONE_ERP)		, ' ')	OR
				 NVL(TRIM(REC.CELULAR)			, ' ')	<>	NVL(TRIM(V_CELULAR_ERP)			, ' ')	OR
				 NVL(TRIM(REC.CPF)				, ' ')	<>	NVL(TRIM(V_CPF_ERP)				, ' ')	OR
				 NVL(TRIM(V_CHAVE)				, ' ')	<>	NVL(TRIM(V_CHAVE_BANCO_ERP)		, ' ')	OR
				 NVL(TRIM(V_CONTA)				, ' ')	<>	NVL(TRIM(V_CONTA_BANCARIA_ERP)	, ' ')	OR
				 NVL(TRIM(V_DIGITO)				, ' ')	<>	NVL(TRIM(V_CHAVE_CONTROLE_ERP)	, ' ')	OR
				 NVL(TRIM(V_DOMFISC)			, ' ')	<>	NVL(TRIM(V_DOM_FISCAL_ERP)		, ' ')	OR
				 NVL(TRIM(REC.DATA_VAL)			, ' ')	<>	NVL(TRIM(V_DTA_VAL)				, ' ')	OR
				 NVL(TRIM(REC.DATA_NASC)		, ' ')	<>	NVL(TRIM(V_DTA_NASC)			, ' ')	OR
				 NVL(TRIM(REC.NACIONALIDADE)	, ' ')	<>	NVL(TRIM(V_NAC)					, ' ')	OR
				 NVL(TRIM(V_FILIAL)				, ' ')	<>	NVL(TRIM(V_SUB)					, ' ')	OR
				 NVL(TRIM(REC.CENTRO_CUSTO)		, ' ')	<>	NVL(TRIM(V_CCS)					, ' ')	OR
				 NVL(TRIM(REC.NOME_COMP)		, ' ')	<>	NVL(TRIM(V_APFG)				, ' ')	OR	
				 NVL(TRIM(TO_CHAR(REC.EMAIL))	, ' ')	<>	NVL(TRIM(TO_CHAR(V_EMAIL_ERP))	, ' ')	OR
				 NVL(TRIM(V_CARGO_SAP)			, ' ')	<>	NVL(TRIM(V_CARGO)				, ' ')	OR
				 NVL(TRIM(V_POS_SAP)				, ' ')	<>	NVL(TRIM(V_PS_NASC)			, ' '))	THEN

					UPDATE	STAGING_FORNECEDOR_CLIENTE
					SET		CODIGO_ANTIGO = V_AN8,
							nome_1_erp = REC.NOME,
							nome_2_erp = REC.SOBRENOME,
							rua_erp = V_ENDERECO,
							numero_erp = REC.NUM,
							complemento_erp = REC.COMP,
							bairro_erp = REC.BAIRRO,
							cep_erp = REC.CEP_FORMAT,
							cidade_erp = V_CIDADE,
							uf_erp = V_UF,
							email_erp = REC.EMAIL,
							telefone_erp = REC.TELEFONE,
							celular_erp = REC.CELULAR,
							cpf_erp = REC.CPF,
							chave_banco_erp = V_CHAVE,
							conta_bancaria_erp = V_CONTA,
							chave_controle_erp = V_DIGITO,
							status = 'P',
							dom_fiscal_erp = V_DOMFISC,
							dta_val = REC.DATA_VAL,
							dta_nasc = REC.DATA_NASC,
							ps_nasc = V_POS_SAP,
							nac = REC.NACIONALIDADE,
							es_civil = REC.ESTADOCIVIL,
							masc = V_MASC,
							fem = V_FEM,
							cc = REC.CENTRO_CUSTO,
							oe = V_CC,
							sub = V_FILIAL,
							apfg = REC.NOME_COMP,
							cargo = V_CARGO_SAP,
							forma_pagamento_san = V_FPAG,
							ft = V_FT
					WHERE	TRIM(MAT) = REC.MATRICULA
					AND		TIPO_CADASTRO = 'E'
					AND		STATUS NOT IN ('N','O');

					COMMIT;
			END IF;

			GOTO prox_func;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				GOTO ins_func;
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO UPDATE; CPF = '||REC.CPF||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;

		<<ins_func>>
		--INSERE FUNCIONÁRIO
		INSERT INTO STAGING_FORNECEDOR_CLIENTE
			(funcao_parceiro,
			 codigo_antigo,
			 agrupamento_parceiro,
			 nome_1_erp,
			 nome_1_san,
			 nome_2_erp,
			 nome_2_san,
			 rua_erp,
			 rua_san,
			 numero_erp,
			 numero_san,
			 complemento_erp,
			 complemento_san,
			 bairro_erp,
			 bairro_san,
			 cep_erp,
			 cep_san,
			 cidade_erp,
			 cidade_san,
			 uf_erp,
			 uf_san,
			 pais_erp,
			 pais_san,
			 email_erp,
			 email_san,
			 telefone_erp,
			 telefone_san,
			 celular_erp,
			 celular_san,
			 idioma,
			 pessoa_fisica,
			 cpf_erp,
			 cpf_san,
			 conta_conciliacao,
			 grupo_adm_tesouraria,
			 moeda_erp,
			 moeda_san,
			 chave_banco_erp,
			 chave_banco_san,
			 conta_bancaria_erp,
			 conta_bancaria_san,
			 chave_controle_erp,
			 chave_controle_san,
			 status,
			 dom_fiscal_erp,
			 dom_fiscal_san,
			 emp,
			 mat,
			 dta_val,
			 arh,
			 dta_nasc,
			 lc_nasc,
			 ps_nasc,
			 es_nasc,
			 id_com,
			 nac,
			 es_civil,
			 masc,
			 fem,
			 cc,
			 oe,
			 sub,
			 apfg,
			 cargo,
			 tipo_cadastro,
			 condicao_pagamento_san,
			 forma_pagamento_san,
			 ft)
		VALUES
			('E',
			 V_AN8,
			 'Z004',
			 REC.NOME,
			 REC.NOME,
			 REC.SOBRENOME,
			 REC.SOBRENOME,
			 V_ENDERECO,
			 V_ENDERECO,
			 REC.NUM,
			 REC.NUM,
			 REC.COMP,
			 REC.COMP,
			 REC.BAIRRO,
			 REC.BAIRRO,
			 REC.CEP_FORMAT,
			 REC.CEP_FORMAT,
			 V_CIDADE,
			 V_CIDADE,
			 V_UF,
			 V_UF,
			 'BR',
			 'BR',
			 REC.EMAIL,
			 REC.EMAIL,
			 REC.TELEFONE,
			 REC.TELEFONE,
			 REC.CELULAR,
			 REC.CELULAR,
			 'PT',
			 'X',
			 REC.CPF,
			 REC.CPF,
			 '21101001',
			 'FF',
			 'BRL',
			 'BRL',
			 V_CHAVE,
			 V_CHAVE,
			 V_CONTA,
			 V_CONTA,
			 V_DIGITO,
			 V_DIGITO,
			 'P',
			 V_DOMFISC,
			 V_DOMFISC,
			 'BR02',
			 REC.MATRICULA,
			 REC.DATA_VAL,
			 'CRH1',
			 REC.DATA_NASC,
			 '1',
			 V_POS_SAP,
			 'BA',
			 '02',
			 REC.NACIONALIDADE,
			 REC.ESTADOCIVIL,
			 V_MASC,
			 V_FEM,
			 REC.CENTRO_CUSTO,
			 V_CC,
			 V_FILIAL,
			 REC.NOME_COMP,
			 V_CARGO_SAP,
			 V_TPCAD,
			 'Z000',
			 V_FPAG,
			 V_FT);

		COMMIT;

		<<prox_func>>
		FETCH WCUR INTO REC;
	END LOOP;
	CLOSE WCUR;
	COMMIT;

	--REMOVE FUNCIONÁRIOS DEMITIDOS
	OPEN WCUR1;
	FETCH WCUR1 INTO REC1;

	LOOP
		EXIT WHEN WCUR1%NOTFOUND;
		BEGIN
			DELETE FROM STAGING_FORNECEDOR_CLIENTE WHERE TRIM(CODIGO_ANTIGO) = REC1.COD_ANTIGO;
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO DELETAR RESCINDIDO; CODIGO_ANTIGO = '||REC1.COD_ANTIGO||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;
		FETCH WCUR1 INTO REC1;
	END LOOP;
	CLOSE WCUR1;
	COMMIT;

END;
