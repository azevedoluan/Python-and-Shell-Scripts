--TABELA DE CONTROLE DE EXTRAÇÕES
create table EXTSAP_TB (
	ID_REG		number			not null,
	TABELA		varchar2(30)	not null,
	TP_REG		varchar2(30)	not null,
	DATA_EXT	date			not null,
	ARQ_EXT		varchar2(200)	not null,
	AMB			VARCHAR2(10)	not null
);

comment on table EXTSAP_TB is 'Tabela de controle das extrações para o SAP';
comment on column EXTSAP_TB.TABELA is 'Tabela de origem do registro';
comment on column EXTSAP_TB.TP_REG is 'Tipo do Registro';
comment on column EXTSAP_TB.DATA_EXT is 'Data da ultima extração do registro';
comment on column EXTSAP_TB.ARQ_EXT is 'Nome do ultimo arquivo gerado';
comment on column EXTSAP_TB.AMB is 'Ambiente para qual o dado foi enviado';

alter table EXTSAP_TB add constraint EXTSAP_PK primary key (ID_REG);
create index EXTSAP_DX ON EXTSAP_TB(DATA_EXT);
create index EXTSAP_DX2 on EXTSAP_TB(TABELA,TP_REG,AMB);

--SEQUENCE PARA CONTROLE DE REGISTRO
CREATE SEQUENCE EXTSAP_SEQ
	MINVALUE 1
	MAXVALUE 999999999999999999999999999
	START WITH 1
	INCREMENT BY 1;


--INSERT NA TABELA DE CONTROLE PÓS EXTRAÇÃO
/*
TIPOS DE REGISTROS:		TABELAS:							AMBIENTES:
	CLIENTE_OBRA;			STAGING_FORNECEDOR_CLIENTE;			QAS;	
	FORNECEDOR;				STAGING_MATERIAL;					PRD;
	TRANSPORTADOR;			STAGING_LIMITE_CREDITO;			
	FUNCIONARIO;			STAGING_INFACOES;				
	MOTORISTA;				STAGING_SALDOESTOQUE;			
	MATERIAL;				STAGING_VEICULO;				
	LIMITE_CREDITO;											
	INFRACAO;												
	SALDO_ESTOQUE;											
	VEICULO;												
*/


--INSERE DADOS DA ULTIMA CARGA NA TABELA DE CONTROLE DE EXTRAÇÃO
INSERT INTO EXTSAP_TB
  (ID_REG,
   TABELA,
   TP_REG,
   DATA_EXT,
   ARQ_EXT,
   AMB) 
VALUES      
  (EXTSAP_SEQ.NEXTVAL,
   '&TABELA',
   '&TIPO_REGISTRO',
   SYSDATE,
   'CARGA_'||'&TIPO_REGISTRO'||'_'||'&AMBIENTE'||'_'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')||'.xlsx',
   '&AMBIENTE');