--Verificar Histórico de Alteração com Usuário

SELECT CODTIPOPER, DHALTER, CALCICMS, PRECIFICA, CODUSU FROM TGFTOP WHERE CODTIPOPER = 205 ORDER BY DHALTER
________________________________________________________________________________________________________________
--Verificar opções do campo

SELECT 
    TDDCAM.NUCAMPO,
    TDDCAM.NOMETAB,
    TDDCAM.NOMECAMPO,
    TDDCAM.DESCRCAMPO,
    TDDOPC.VALOR,
    TDDOPC.OPCAO
FROM TDDCAM INNER JOIN TDDOPC
ON TDDCAM.NUCAMPO = TDDOPC.NUCAMPO
WHERE
    TDDCAM.NOMETAB = 'TGFCAB' AND 
    TDDCAM.NOMECAMPO = 'TIPMOV'
________________________________________________________________________________________________________________
--Verificar tabelas onde existe um campo

SELECT 
    LIG.NUINSTORIG, 
    DINS.NOMETAB 
FROM TDDLIG LIG --tabela de ligações
    INNER JOIN TDDINS DINS ON DINS.NUINSTANCIA = LIG.NUINSTDEST --tabela de instâncias
    INNER JOIN TDDCAM CAM  ON CAM.NOMETAB      = DINS.NOMETAB
WHERE CAM.NOMECAMPO = 'DESCRPROD'
________________________________________________________________________________________________________________
--Alterar tamanho do campo

ALTER TABLE TSIUSU MODIFY NOMEUSU VARCHAR2(20)
________________________________________________________________________________________________________________
--Ajustar Parceiros CPF/CNPJ

SELECT CODPARC, CGC_CPF, LENGTH(CGC_CPF) 
FROM TGFPAR 
WHERE LENGTH(CGC_CPF) > 11 AND LENGTH(CGC_CPF) < 14 AND CODPARC >= 1
ORDER BY CODPARC

SELECT CODPARC, CGC_CPF, LENGTH(CGC_CPF) 
FROM TGFPAR 
WHERE LENGTH(CGC_CPF) = 11 AND TIPPESSOA <> 'F'
ORDER BY CODPARC

UPDATE TGFPAR SET CGC_CPF = '0' || CGC_CPF
WHERE LENGTH(CGC_CPF) > 11 AND LENGTH(CGC_CPF) < 14 AND CODPARC >= 1

SELECT 
    CODPARC, 
    CGC_CPF, 
    TIPPESSOA,
    CLASSIFICMS
FROM TGFPAR 
WHERE TIPPESSOA = 'J' AND CLASSIFICMS <> 'R' AND CODPARC >= 1
ORDER BY CODPARC

________________________________________________________________________________________________________________
--Remover registros duplicados

DELETE FROM TGFPAR
WHERE ROWID NOT IN
    (SELECT MIN(ROWID)
        FROM TGFPAR
        GROUP BY CGC_CPF);
________________________________________________________________________________________________________________
--ALTERAR CAMPOS IPI NO PRODUTO

SELECT 
    PRD.CODPROD, 
    PRD.CODIPI, 
    prd.cstipient, 
    prd.cstipisai 
FROM 
    TGFPRO PRD
WHERE 
    PRD.CODIPI = 33
    
UPDATE TGFPRO
SET CODIPI = '', CSTIPIENT = '', CSTIPISAI = ''
WHERE CODIPI = 33

________________________________________________________________________________________________________________
--DELETAR IMPORTAÇÃO EXTRATO

DELETE FROM TGFEXB WHERE NUIMPORT = 2; 
DELETE FROM TGFIEB WHERE NUIMPORT = 2;

________________________________________________________________________________________________________________
--Remover acentuação

SELECT 
    C.CODCID,
    translate (C.NOMECID,'ŠŽšžŸÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ',

                  'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy'),
    C.UF,
    UF.UF,
    UF.DESCRICAO
FROM TSICID C
INNER JOIN TSIUFS UF
ON C.UF = UF.CODUF
________________________________________________________________________________________________________________
--Remover Configurações de Arquivo Remessa E Retorno

SELECT * FROM TSIIRE WHERE CODIGO >= 1000000 ORDER BY CODIGO
SELECT * FROM TSIREM WHERE CODIGO >= 1000000 ORDER BY CODIGO

DELETE FROM TSIIRE WHERE CODIGO >= 1000000;
DELETE FROM TSIREM WHERE CODIGO >= 1000000;
DELETE FROM TSIIRT WHERE CODIGO >= 1000000;
DELETE FROM TSIRET WHERE CODIGO >= 1000000;
________________________________________________________________________________________________________________
-- Atualizar produtos inserindo casas decimais

UPDATE TGFPRO SET DECVLR = 4, DECQTD = 4 WHERE USOPROD <> 'S' AND CODPROD > 0;
________________________________________________________________________________________________________________
-- Gerar planilha TGFCPL

SELECT 
    P.CODPARC,
    c.sugtipnegentr,
    c.sugtipnegsaid
FROM TGFPAR P LEFT JOIN TGFCPL C
    ON P.CODPARC = C.CODPARC
WHERE 
    P.CODPARC > 0
ORDER BY CODPARC
________________________________________________________________________________________________________________
-- INSERT

INSERT INTO TGFVOA VOA (VOA.CODPROD, VOA.CODVOL, VOA.DIVIDEMULTIPLICA, VOA.QUANTIDADE, VOA.MULTIPVLR)
SELECT CODPROD, 'PC', 'M', 1, 1 
FROM TGFPRO PRO
WHERE PRO.CODVOL = 'UN' AND PRO.CODPROD != 18
________________________________________________________________________________________________________________
--Alterar status de TRIGGERS

ALTER TRIGGER TRG_UPD_TGFHRM_TSICTA DISABLE;
ALTER TRIGGER TRG_UPD_TGFHRM_TSICTA ENABLE;
________________________________________________________________________________________________________________
-- Verificar se há trigger personalizada

SELECT
    TRIGGER_NAME
FROM
    ALL_TRIGGERS
WHERE
    OWNER = (
        SELECT
            USER
        FROM
            DUAL
    ) AND
    TABLE_NAME = 'TGFITE' AND
    TRIGGER_NAME NOT IN (
        'TRG_UPT_TGFITE',
        'TRG_INC_UPD_TGFITE_PRODNFE',
        'TRG_INC_UPT_DLT_TGFITE_FEC_CTB',
        'TRG_INC_UPD_DLT_TGFITE_ESTTERC',
        'TRG_INC_UPD_DLT_TGFITE_DAV',
        'TRG_INC_UPD_TGFITE_TGAMOV',
        'TRG_DLT_TGFITE',
        'TRG_INC_TGFITE',
        'TRG_INC_UPD_TGFITE',
        'TRG_INC_UPD_TGFITE_TRANSG',
        'TRG_INC_UPD_DLT_TGFITE_RASTST',
        'TRG_INC_UPD_DLT_TGFITE_ESE',
        'TRG_UPD_TGFITE_TCIBEM',
        'TRG_DLT_TGFITE_TGFICO',
        'TRG_DLT_TGFITE_TGFCUSITE',
        'TRG_INC_UPD_DLT_TGFITE_LIB41',
        'TRG_DLT_TGFITE_FLEX',
        'TRG_INC_UPD_TGFITE_TGFGXE',
        'TRG_INC_TGFITE_AFTER',
        'TRG_UPT_TGFITE_AFTER',
        'TRG_INC_TGFITE_FLEX',
        'TRG_INC_UPD_TGFITE_VERIFCORTE',
        'TRG_DLT_TGFITE_AFTER',
        'TRG_DLT_TGFITE_METAS',
        'TRG_DLT_TGFITE_TRANSG',
        'TRG_INC_UPD_TGFITE_CERTIFIC',
        'TRG_DLT_TGFITE_HCRUZADAS',
        'TRG_INC_UPD_TGFITE_ATIVO',
        'TRG_UPT_TGFITE_METAS',
        'TRG_INC_UPD_DLT_TGFITE_RASTEST',
        'TRG_INC_UPD_TGFITE_RASTEST',
        'TRG_UPD_TGFITE_FLEX'
    )
________________________________________________________________________________________________________________
--INSERE OS ITENS EXCLUIDOS

INSERT INTO TGFITE 
 		(NUTAB, NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG,
        CONTROLE, USOPROD, CODCFO, QTDNEG, QTDENTREGUE, QTDCONFERIDA, VLRUNIT,
        VLRTOT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT,
        VLRSUBST, ALIQICMS, ALIQIPI, PENDENTE, CODVOL, CODTRIB, ATUALESTOQUE,
        OBSERVACAO, RESERVA, STATUSNOTA, CODOBSPADRAO, CODVEND, CODEXEC, FATURAR,
		VLRREPRED, VLRDESCBONIF, PERCDESC, PERCPUREZA, PERCGERMIN, CODUSU,
        BASEISS, VLRISS, CODTPA, ORIGPROD,VLRUNITLOC, SEQUENCIAFISCAL, CODCFPS, CODENQIPI,
        CODESPECST)
SELECT 
	   NUTAB, NUNOTA, SEQUENCIA, CODEMP, CODPROD, CODLOCALORIG,
       CONTROLE, USOPROD, CODCFO, QTDNEG, QTDENTREGUE, QTDCONFERIDA, VLRUNIT,
       VLRTOT, VLRCUS, BASEIPI, VLRIPI, BASEICMS, VLRICMS, VLRDESC, BASESUBSTIT,
       VLRSUBST, ALIQICMS, ALIQIPI, PENDENTE, CODVOL, CODTRIB, ATUALESTOQUE,
       OBSERVACAO, RESERVA, STATUSNOTA, CODOBSPADRAO, CODVEND, CODEXEC, FATURAR,
       VLRREPRED,VLRDESCBONIF,PERCDESC, PERCPUREZA, 
       PERCGERMIN, CODUSU, BASEISS, VLRISS, CODTPA, ORIGPROD, VLRUNITLOC, SEQUENCIAFISCAL, 
       CODCFPS, CODENQIPI, CODESPECST 
FROM TGFITE_EXC 
WHERE NUNOTA = ?
________________________________________________________________________________________________________________
--INSERIR FINANCEIRO EXCLUIDO

INSERT INTO TGFFIN F
(F.NUFIN, F.CODEMP, F.NUMNOTA, F.SERIENOTA, F.DTNEG, F.DESDOBRAMENTO, F.DHMOV, F.DTVENCINIC, F.DTVENC, F.CODPARC, F.CODTIPOPER, F.DHTIPOPER, F.CODBCO, 
	F.CODCTABCOINT, F.CODNAT, F.CODCENCUS, F.CODVEND, F.CODTIPTIT, F.NOSSONUM, F.HISTORICO, F.VLRDESDOB, F.DTALTER, F.ORIGEM, F.NUNOTA)
SELECT 
	TE.NUFIN, TE.CODEMP, TE.NUMNOTA, TE.SERIENOTA, TE.DTNEG, TE.DESDOBRAMENTO, TE.DHMOV, TE.DTVENCINIC, TE.DTVENC, TE.CODPARC, TE.CODTIPOPER, TE.DHTIPOPER, TE.CODBCO, 
	TE.CODCTABCOINT, TE.CODNAT, TE.CODCENCUS, TE.CODVEND, TE.CODTIPTIT, TE.NOSSONUM, TE.HISTORICO, TE.VLRDESDOB, TE.DHMOV, <?>, <?>  
FROM TGFFIN_EXC TE 
WHERE TE.NUFIN = ?
________________________________________________________________________________________________________________
--Execute o comando abaixo para inserir o NURENEG

BEGIN
EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFFIN DISABLE';
EXECUTE IMMEDIATE 'UPDATE TGFFIN SET NURENEG=**** WHERE NUFIN=***';
EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFFIN ENABLE';
END;
________________________________________________________________________________________________________________
--Inserir NUMNOTA na Movimentação Financeira

SELECT F.NUFIN, F.NUNOTA, F.NUMNOTA, C.NUMNOTA, F.RECDESP, F.DHBAIXA  
FROM TGFFIN F INNER JOIN TGFCAB C 
	ON C.NUNOTA = F.NUNOTA 
WHERE 
	F.NUMNOTA = 0 AND C.NUMNOTA != 0 AND F.RECDESP = 1

UPDATE TGFFIN FIN 
SET FIN.NUMNOTA = 
	(SELECT CAB.NUMNOTA FROM TGFCAB CAB INNER JOIN TGFFIN F 
		ON F.NUNOTA = CAB.NUNOTA WHERE F.NUFIN = FIN.NUFIN)
WHERE FIN.NUFIN IN (
    SELECT F.NUFIN  
    FROM TGFFIN F INNER JOIN TGFCAB C 
        ON C.NUNOTA = F.NUNOTA 
    WHERE 
        F.NUMNOTA = 0 AND C.NUMNOTA != 0 AND F.RECDESP = 1)

--Inserir NUMNOTA na Movimentação Bancária

SELECT M.NUBCO, M.NUMDOC, F.NUFIN, F.NUBCO, F.NUMNOTA   
FROM TGFMBC M INNER JOIN TGFFIN F 
	ON F.NUBCO = M.NUBCO 
WHERE 
	M.NUMDOC = 0 AND M.RECDESP = 1 AND M.ORIGMOV = 'F' AND F.NUMNOTA != 0

UPDATE TGFMBC MBC 
SET MBC.NUMDOC = 
	(SELECT FIN.NUMNOTA FROM TGFFIN FIN WHERE FIN.NUBCO = MBC.NUBCO)
WHERE MBC.NUBCO  IN (
	SELECT M.NUBCO   
	FROM TGFMBC M INNER JOIN TGFFIN F 
		ON F.NUBCO = M.NUBCO 
	WHERE 
		M.NUMDOC = 0 AND M.RECDESP = 1 AND M.ORIGMOV = 'F' AND F.NUMNOTA != 0)

________________________________________________________________________________________________________________
--Inserir Produtos na TGFITE

="INSERT INTO TGFITE (NUNOTA, CODPROD, CONTROLE, QTDNEG, VLRUNIT) VALUES (XXXX,"&&",'"&&"',"&&",1);"

________________________________________________________________________________________________________________
--Ajuste Implantação Saldo Inicial Conta Bancária

SELECT * FROM TGFSBC WHERE CODCTABCOINT = 102

DELETE FROM TGFSBC WHERE CODCTABCOINT = 102

INSERT INTO TGFSBC (CODCTABCOINT, REFERENCIA, SALDOREAL, SALDOBCO) VALUES(9, TIMESTAMP '2023-07-01 00:00:00.000000', 0, 0);

________________________________________________________________________________________________________________
--Alterar o tipo de negociação do parceiro

UPDATE TGFCPL SET SUGTIPNEGENTR = 0;
UPDATE TGFCPL SET SUGTIPNEGSAID = 0;

________________________________________________________________________________________________________________
--Inserir Unidade de Compra na palnilha de Unidades Alternativas (TGFVOA)

INSERT INTO TGFVOA 
	(CODPROD, CODVOL, DIVIDEMULTIPLICA, QUANTIDADE, MULTIPVLR, ATIVO)
SELECT 
	PROD.CODPROD, PROD.CODVOL, 'M', 1, 1, 'S'
FROM TGFPRO PROD
WHERE 
	PROD.CODVOLCOMPRA IS NOT NULL AND
	PROD.CODVOLCOMPRA NOT IN (SELECT VOA.CODVOL FROM TGFVOA VOA WHERE VOA.CODPROD = PROD.CODPROD)
________________________________________________________________________________________________________________
-- UPDATE PARCELAS
SELECT P.CODTIPVENDA, P.CODTIPTITPAD, P.CODBCOPAD, P.CODCTABCOINT, P.CODEMP 
FROM TGFPPG P INNER JOIN TGFTPV N 
	ON N.CODTIPVENDA = P.CODTIPVENDA 
WHERE N.SUBTIPOVENDA IN (2,3)


UPDATE TGFPPG P
SET P.CODTIPTITPAD = 4, P.CODBCOPAD = 748, P.CODCTABCOINT = 1, P.CODEMP = 3
WHERE P.CODTIPVENDA IN 
	(SELECT P.CODTIPVENDA 
		FROM TGFPPG P INNER JOIN TGFTPV N 
			ON N.CODTIPVENDA = P.CODTIPVENDA 
		WHERE N.SUBTIPOVENDA IN (2,3))
________________________________________________________________________________________________________________
--Buscar Valor de Tabela de um Produto na Data de Emissão da NF-e

SELECT
    ITE.NUNOTA,
    CAB.NUMNOTA,
    ITE.NUTAB, 
    ITE.CODPROD, 
    ITE.VLRUNIT, 
    ITE.PRECOBASE, 
    SNK_GET_PRECO (ITE.NUTAB,ITE.CODPROD,CAB.DTNEG) AS PREÇO_TAB  
FROM TGFITE ITE
    INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
WHERE CAB.NUMNOTA IN (22950, 22943, 22933, 22919, 22917, 22916, 22911)

UPDATE TGFITE
SET PRECOBASE = SNK_GET_PRECO (NUTAB,CODPROD,DTALTER)
WHERE NUNOTA IN (SELECT
				    ITE.NUNOTA 
				FROM TGFITE ITE
				    INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
				WHERE CAB.NUMNOTA IN (22950, 22943, 22933, 22919, 22917, 22916, 22911))
________________________________________________________________________________________________________________
--Remover vínculode nota com caixa fechado
DELETE TGFMCX WHERE NROUNICO =?
________________________________________________________________________________________________________________
--Corrigir saldo de estoque reservado após Ordem de Produção finalizada

ALTER TABLE TGFITE DISABLE ALL TRIGGERS;
UPDATE TGFCAB SET PENDENTE = 'N' WHERE TIPMOV = 'J' AND PENDENTE = 'S' AND STATUSNOTA = 'L' AND IDIPROC IN (SELECT IDIPROC FROM TPRIPROC WHERE STATUSPROC = 'F');
UPDATE TGFITE SET PENDENTE = 'N' WHERE PENDENTE = 'S' AND NUNOTA IN (SELECT CAB.NUNOTA FROM TGFCAB CAB INNER JOIN TPRIPROC OP ON OP.IDIPROC = CAB.IDIPROC WHERE CAB.TIPMOV = 'J' AND CAB.STATUSNOTA = 'L' AND OP.STATUSPROC = 'F');
UPDATE TGFITE SET QTDENTREGUE = QTDNEG WHERE QTDENTREGUE <> QTDNEG AND NUNOTA IN (SELECT CAB.NUNOTA FROM TGFCAB CAB INNER JOIN TPRIPROC OP ON OP.IDIPROC = CAB.IDIPROC WHERE CAB.TIPMOV = 'J' AND CAB.STATUSNOTA = 'L' AND OP.STATUSPROC = 'F');
ALTER TABLE TGFITE ENABLE ALL TRIGGERS;

--Após rodar script acessar a tela Verificação de Saldo de Estoque, buscar por Reserva e Corrigir
________________________________________________________________________________________________________________
--Ajustar campo nas Operações de Estoque do Processo Produtivo

SELECT 
    OE.IDEFX,
    PP.IDPROC,
    PP.CODPRC,
    PP.DESCRABREV,
    OE.BAIXARESERVAEST
FROM TPROEST OE, TPREFX EFX, TPRPRC PP
WHERE
    OE.IDEFX = EFX.IDEFX AND
    EFX.IDPROC = PP.IDPROC AND
    PP.CODPRC = 900
    
--UPDATE TPROEST SET BAIXARESERVAEST = 'S' WHERE IDEFX IN (SELECT OE.IDEFX FROM TPROEST OE, TPREFX EFX, TPRPRC PP WHERE OE.IDEFX = EFX.IDEFX AND EFX.IDPROC = PP.IDPROC AND PP.CODPRC = 900)
________________________________________________________________________________________________________________
--AJUSTAR CFOP

SELECT CAB.INDPRESNFCE, ITE.CODPROD, ITE.CODCFO 
FROM TGFITE ITE 
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA 
WHERE ITE.NUNOTA = 49054;

--UPDATE TGFITE SET CODCFO = 5102 WHERE NUNOTA = 49054;
UPDATE TGFITE SET CODCFO = '5' || SUBSTR(CODCFO,2,3) WHERE NUNOTA = 49054;
________________________________________________________________________________________________________________
--INSERIR NOTA NA TGFCAN (AJUSTE NOTA CANCELADA NA SEFAZ E APROVADA NO SISTEMA)
INSERT INTO TGFCAN (NUMNOTA,CODEMP,SERIENOTA,DTNEG,DTFATUR,DTMOV,MOTCANCEL,ATUALLIVFIS,DTCANC,NUNOTA,CODPARC,CODMODDOC,CHAVENFE,NUMPROTOCNFE,DHPROTOCNFE,NUMPROTOCCAN,DHPROTOCCAN,TPEMISNFE,VLRNOTA)
SELECT NUMNOTA,CODEMP,SERIENOTA,DTNEG,DTFATUR,DTMOV,'Nota emitida errada','S',TO_DATE('23/02/2023 16:41:12','DD/MM/YYYY HH24:MI:SS'),NUNOTA,CODPARC,55,CHAVENFE,'141230047330588',TO_DATE('23/02/2023 16:34:14','DD/MM/YYYY HH24:MI:SS'),'141230047342151',TO_DATE('23/02/2023 16:41:12','DD/MM/YYYY HH24:MI:SS'),TPEMISNFE,VLRNOTA
    FROM TGFCAB WHERE NUNOTA = 9843

________________________________________________________________________________________________________________
--REMOVER VINCULO ENTRE NOTAS

DELETE FROM TGFVAR WHERE NUNOTA = <NOTA DESTINO>
________________________________________________________________________________________________________________
-- UPDATE NA TGFCUS

UPDATE TGFCUS SET CUSMEDICM = CUSGER, CUSSEMICM = CUSGER, CUSREP = CUSGER, CUSMED = CUSGER, CUSVARIAVEL = CUSGER 
    WHERE DTATUAL < TO_DATE('31/12/2022', 'DD/MM/YYYY') AND CUSGER > 0 AND CUSMED <= 0
________________________________________________________________________________________________________________
--Consulta Composição de Produtos da Produção
SELECT 
    PA.IDPROC AS COD_COMPOSICAO,
    PR.CODPRC AS COD_PROCESSO_PROD,
    MP.IDEFX AS COD_ATIVIDADE,
    EF.DESCRICAO,
    PA.CODPRODPA AS COD_PRODUTOACABADO,
    MP.CODPRODMP AS COD_MATERIAPRIMA,
    MP.QTDMISTURA AS QTD_MISTURA,
    PR.VERSAO AS VERSAO_COMPOSICAO
FROM TPRLMP MP 
    INNER JOIN TPRATV AT ON AT.IDEFX = MP.IDEFX
    INNER JOIN TPRLPA PA ON PA.IDPROC = AT.IDPROC AND PA.CODPRODPA = MP.CODPRODPA
    INNER JOIN TPRPRC PR ON PR.IDPROC = AT.IDPROC
    LEFT JOIN TPREFX EF ON EF.IDEFX = AT.IDEFX
WHERE 
    PA.CODPRODPA = 10001002 AND
    PR.VERSAO = (SELECT MAX(VERSAO) FROM TPRPRC WHERE CODPRC = PR.CODPRC)
ORDER BY PA.IDPROC, PA.CODPRODPA
________________________________________________________________________________________________________________
--AJUSTE PARCEIROS PARA EMISSÃO/ENVIO DE BOLETO NO MOMENTO DA EMISSÃO DA NF-e

SELECT CODPARC, EMAIL, EMAILDANFE, EMAILNFE, TIPGERBOLCENT FROM TGFPAR WHERE EMAIL IS NOT NULL AND CLIENTE = 'S' AND CODPARC > 0

UPDATE TGFPAR SET EMAILDANFE = 'S', EMAILNFE = EMAIL, TIPGERBOLCENT = 'A' WHERE EMAIL IS NOT NULL AND CLIENTE = 'S' AND CODPARC > 0 
________________________________________________________________________________________________________________
--Conciliar via UPDATE

UPDATE TGFMBC
SET
    PREDATA = DTLANC,
    DHCONCILIACAO = DTLANC,
    CONCILIADO = 'S'
WHERE 
    NUBCO > 10000 AND 
    DTLANC BETWEEN '01/01/2023' AND '31/05/2023'
________________________________________________________________________________________________________________
--Ajuste Saldo Estoque de Terceiros

-- Verificar produtos com saldo em estoque de terceiros
SELECT 
    CODEMP,
    CODLOCAL,
    CODPROD,
    CODPARC,
    ESTOQUE,
    RESERVADO
FROM TGFEST
WHERE CODPARC <> 0

--DELETE FROM TGFEST WHERE CODPARC <> 0 AND ESTOQUE = 0

-- Verificar status dos itens na TGFITE se estão marcados para movimentar estoque de terceiros
SELECT
    CAB.CODTIPOPER,
    ITE.ATUALESTTERC,
    ITE.TERCEIROS,
    ITE.CODLOCALTERC
FROM TGFITE ITE
    JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
WHERE
    ITE.CODPROD IN (
        SELECT CODPROD FROM TGFEST WHERE CODPARC <> 0)
        
--Alterar itens na tgfite para não movimentar estoque de terceiros
ALTER TRIGGER TRG_UPT_TGFITE DISABLE;
UPDATE TGFITE SET ATUALESTTERC = 'N', TERCEIROS = 'N', CODLOCALTERC = '' WHERE CODPROD IN (SELECT CODPROD FROM TGFEST WHERE CODPARC <> 0);
ALTER TRIGGER TRG_UPT_TGFITE ENABLE;

--Verificar as TOPs que estão marcadas para movimentar estoque de terceiros
SELECT CODTIPOPER, DESCROPER, DHALTER, ATUALESTTERC, ATUALESTWMSTERC, CODUSU FROM TGFTOP
WHERE 
    (ATUALESTTERC NOT LIKE 'N' OR
    ATUALESTWMSTERC NOT LIKE 'N') AND
    ATIVO = 'S'
    
UPDATE TGFTOP SET ATUALESTTERC = 'N', ATUALESTWMSTERC = 'N' WHERE (ATUALESTTERC NOT LIKE 'N' OR ATUALESTWMSTERC NOT LIKE 'N')    