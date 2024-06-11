CREATE OR REPLACE PROCEDURE "AD_STP_INSERE_DATA_FALTA" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_DTNEG DATE;
       FIELD_NUNOTA NUMBER;
BEGIN

       PARAM_DTNEG := ACT_DTA_PARAM(P_IDSESSAO, 'DTNEG');

       INSERT INTO AD_TGFCTC (NUNOTA,NUMNOTA,CODEMP,CODPARC,CODVEND,VLRNOTA,CODTIPOPER,CODTIPVENDA,DTNEG,DTFATUR)
       SELECT
              NUNOTA,
              NUMNOTA,
              CODEMP,
              CODPARC,
              CODVEND,
              VLRNOTA,
              CODTIPOPER,
              CODTIPVENDA,
              TO_CHAR(DTNEG,'DD/MM/YYYY') AS DTNEG,
              DTFATUR
       FROM TGFCAB
       WHERE
              STATUSNOTA = 'L' AND
              STATUSNFE = 'A' AND
              TIPMOV IN ('V','D','E') AND
              (CODTIPOPER IN (
              SELECT CODTIPOPER FROM TGFTOP WHERE GRUPO = 'Vendas' AND ATUALEST = 'B' AND CODMODDOC = 55    
              ) OR CODTIPOPER IN (1200,1201,1209,300,301,1720,1729)) AND
              DTNEG = TO_CHAR(PARAM_DTNEG,'DD/MM/YYYY');

END;