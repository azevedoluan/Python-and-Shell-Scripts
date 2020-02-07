CREATE OR REPLACE PROCEDURE CARGA_CIF_RFSINT_STAGING IS

  CURSOR WCUR0 IS
    SELECT  DISTINCT TRIM(A.cnpj)              CNPJ,
        TRIM(A.nome_1)                  NOME_1,
        NVL(SUBSTR(TRIM(A.nome_2),1,40), ' ')      NOME_2,
        LENGTH(A.nome_2)                TAM_NOME,
        NVL(TRIM(A.fantasia), ' ')            FANTASIA,
        NVL(TRIM(A.cnae), ' ')              CNAE,
        NVL(TRIM(A.nat_juri), ' ')            NAT_JURI,
        NVL(SUBSTR(TRIM(A.rua),1,60), ' ')        RUA,
        LENGTH(A.rua)                  TAM_RUA,
        NVL(TRIM(A.num), ' ')              NUM,
        NVL(SUBSTR(TRIM(A.complemento),1,40), ' ')    COMPLEMENTO,
        LENGTH(A.complemento)              TAM_COMPLEMENTO,
        NVL(TRIM(A.cep), ' ')              CEP,
        NVL(SUBSTR(TRIM(A.bairro),1,40), ' ')      BAIRRO,
        LENGTH(A.bairro)                TAM_BAIRRO,
        NVL(TRIM(A.cidade), ' ')            CIDADE,
        NVL(TRIM(A.sit_cadastro), ' ')          SIT_CADASTRO,
        NVL(TRIM(A.email), ' ')              EMAIL,
        NVL(TRIM(A.uf), ' ')              UF,
        NVL(TRIM(A.tel), ' ')              TEL,
        NVL(TRIM(B.codigo_antigo), ' ')          CODIGO_ANTIGO
    FROM  STAGING_SANEADORECEITASINTEGRA A,
        STAGING_FORNECEDOR_CLIENTE B
    WHERE  TRIM(B.CNPJ_ERP) = TRIM(A.CNPJ)
    AND    B.TIPO_CADASTRO = 'T'
    AND    A.CONTROLE_RECEITA = 'N'
    AND    TO_DATE(DATA_PROC_RECEITA) >= (SELECT TO_DATE(DATA_PROC-1) FROM STAGING_CONTROLE WHERE DADO = 'RECEITA');
    REC0 WCUR0 %ROWTYPE;

    CURSOR WCUR1 IS
      SELECT  TRIM(A.cnpj)            CNPJ,
          NVL(TRIM(SITUACAO), '1')      SITUACAO,
          NVL(TRIM(RT), '5')          RT,
          NVL(TRIM(B.codigo_antigo), ' ')    CODIGO_ANTIGO
      FROM  STAGING_SANEADORECEITASINTEGRA A,
          STAGING_FORNECEDOR_CLIENTE B
      WHERE  TRIM(B.CNPJ_ERP) = TRIM(A.CNPJ)
      AND    B.TIPO_CADASTRO = 'T'
      AND    A.CONTROLE_SINTEGRA = 'N'
      AND    TO_DATE(DATA_PROC_SINTEGRA) >= (SELECT TO_DATE(DATA_PROC-1) FROM STAGING_CONTROLE WHERE DADO = 'SINTEGRA');
    REC1 WCUR1 %ROWTYPE;

    EMAIL    staging_fornecedor_cliente.email_san%type;
    TELEFONE  staging_fornecedor_cliente.telefone_san%type;
    OBSERVA    staging_fornecedor_cliente.observacao%type;
    OBS      staging_fornecedor_cliente.observacao%type;

BEGIN

  OPEN WCUR0;
  FETCH WCUR0 INTO REC0;

  LOOP
    EXIT WHEN WCUR0%NOTFOUND;

    --VERIFICA CAMPOS ESTOURANDO
    OBS := NULL;
    IF REC0.TAM_NOME > 40 THEN
      OBS := 'NOME ESTOURANDO';
    END IF;

    IF  OBS <> NULL THEN
      IF REC0.TAM_RUA > 60 THEN
        OBS := OBS||'; RUA ESTOURANDO';
      END IF;
    ELSE
      IF REC0.TAM_RUA > 60 THEN
        OBS := 'RUA ESTOURANDO';
      END IF;
    END IF;

    IF  OBS <> NULL THEN
      IF REC0.TAM_COMPLEMENTO > 40 THEN
        OBS := OBS||'; COMPLEMENTO ESTOURANDO';
      END IF;
    ELSE
      IF REC0.TAM_COMPLEMENTO > 40 THEN
        OBS := 'COMPLEMENTO ESTOURANDO';
      END IF;
    END IF;

    IF  OBS <> NULL THEN
      IF REC0.TAM_BAIRRO > 40 THEN
        OBS := OBS||'; BAIRRO ESTOURANDO';
      END IF;
    ELSE
      IF REC0.TAM_BAIRRO > 40 THEN
        OBS := 'BAIRRO ESTOURANDO';
      END IF;
    END IF;

    --RETORNA EMAIL,TELEFONE E OBSERVAÇÕES EXISTENTES NO STAGING
    SELECT  NVL(email_san, '1'),
        NVL(TRIM(TO_CHAR(telefone_san)), '1'),
        NVL(TRIM(TO_CHAR(observacao)), '1')
    INTO  EMAIL,
        TELEFONE,
        OBSERVA
    FROM  STAGING_FORNECEDOR_CLIENTE
    WHERE  TRIM(codigo_antigo) = REC0.CODIGO_ANTIGO
    AND    TIPO_CADASTRO = 'T';

    IF EMAIL = '1' AND REC0.EMAIL = ' ' THEN
      EMAIL := NULL;
    ELSIF  EMAIL = '1' AND REC0.EMAIL <> ' ' THEN
      EMAIL := REC0.EMAIL;
    ELSE
      EMAIL := EMAIL||';'||REC0.EMAIL;
    END IF;

    IF TELEFONE = '1' AND REC0.TEL = ' ' THEN
      TELEFONE := NULL;
    ELSIF TELEFONE = '1' AND REC0.TEL <> ' ' THEN
      TELEFONE := REC0.TEL;
    ELSE
      TELEFONE := TELEFONE||';'||REC0.TEL;
    END IF;

    IF OBSERVA <> '1' THEN
      OBS := OBSERVA||' '||OBS;
    END IF;

    --ATUALIZA STAGING COM AS INFORMAÇÕES DA RECEITA
    UPDATE  STAGING_FORNECEDOR_CLIENTE
    SET    nome_1_san = REC0.NOME_1,
        nome_2_san = REC0.NOME_2,
        termo_pesquisa_1 = REC0.FANTASIA,
        cnae = REC0.CNAE,
        natureza_juridica = REC0.NAT_JURI,
        rua_san = REC0.RUA,
        numero_san = REC0.NUM,
        complemento_san = REC0.COMPLEMENTO,
        cep_san = REC0.CEP,
        bairro_san = REC0.BAIRRO,
        cidade_san = REC0.CIDADE,
        status_1 = REC0.SIT_CADASTRO,
        email_san = EMAIL,
        uf_san = REC0.UF,
        telefone_san = TELEFONE,
        observacao = OBS
    WHERE  TRIM(codigo_antigo) = REC0.CODIGO_ANTIGO
    AND    TIPO_CADASTRO = 'T';

    COMMIT;

    UPDATE  STAGING_SANEADORECEITASINTEGRA
    SET    CONTROLE_RECEITA = 'S',
        DATA_PROC_RECEITA = SYSDATE
    WHERE  CNPJ = REC0.CNPJ;

    COMMIT;
    FETCH WCUR0 INTO REC0;

  END LOOP;

  CLOSE WCUR0;
  UPDATE  STAGING_CONTROLE
  SET    DATA_PROC = SYSDATE
  WHERE  DADO = 'RECEITA';

  OPEN WCUR1;
  FETCH WCUR1 INTO REC1;

  LOOP
    EXIT WHEN WCUR1%NOTFOUND;

    IF REC1.SITUACAO <> '1' THEN

      UPDATE  STAGING_FORNECEDOR_CLIENTE
      SET    status_2 = REC1.SITUACAO,
          numero_crt = REC1.RT
      WHERE  TRIM(codigo_antigo) = REC1.CODIGO_ANTIGO
      AND    TIPO_CADASTRO = 'T';

      COMMIT;

      UPDATE  STAGING_SANEADORECEITASINTEGRA
      SET    CONTROLE_SINTEGRA = 'S',
          DATA_PROC_SINTEGRA = SYSDATE
      WHERE  CNPJ = REC1.CNPJ;

      COMMIT;
    END IF;

    FETCH WCUR1 INTO REC1;

  END LOOP;

  CLOSE WCUR1;

  UPDATE  STAGING_CONTROLE
  SET    DATA_PROC = SYSDATE
  WHERE  DADO = 'SINTEGRA';

  COMMIT;

END;
