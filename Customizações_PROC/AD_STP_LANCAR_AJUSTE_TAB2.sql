CREATE OR REPLACE PROCEDURE "AD_STP_LANCAR_AJUSTE_TAB2" (
    P_CODUSU NUMBER,        -- Código do usuário logado
    P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
    FIELD_NUNOTA NUMBER;
    V_NUNOTA NUMBER;
    V_NUTAB INT;

BEGIN

    SELECT MAX(NUNOTA)+1 INTO V_NUNOTA FROM TGFCAB;
    SELECT MAX(NUTAB) INTO V_NUTAB FROM TGFTAB WHERE CODTAB = 2;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--INSERIR CABEÇALHO DA NOTA
       INSERT INTO TGFCAB (NUNOTA,NUMNOTA,CODEMP,CODEMPNEGOC,CODPARC,TIPMOV,CODTIPVENDA,DHTIPVENDA,CODTIPOPER,DHTIPOPER,NUFOP,DTMOV,DTNEG,CODVEND,CODCENCUS,CODNAT,PENDENTE,STATUSNOTA,CODUSU,DTALTER,OBSERVACAO)
       VALUES (
              V_NUNOTA,
              0,
              1,
              1,
              30313,
              'P',
              355,
              (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 355),
              1723,
              (SELECT MAX(DHALTER) FROM TGFTOP WHERE CODTIPOPER = 1723),
              1,
              SYSDATE,
              SYSDATE,
              17,
              104002,
              101001,
              'S',
              'A',
              P_CODUSU,
              SYSDATE,
              'Orçamento para Ajuste de Valores da Tabela de Preço 2' 
       );
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--INSERIR ITENS NA NOTA
    INSERT INTO TGFITE (NUNOTA,CODEMP,SEQUENCIA,CODPROD,CODVOL,USOPROD,QTDNEG,VLRUNIT,VLRTOT,BASEIPI,ALIQIPI,VLRIPI,BASESUBSTIT,VLRSUBST,ATUALESTOQUE,RESERVA,STATUSNOTA,CODVEND,CODLOCALORIG)
    WITH TAB_P2 AS (
        SELECT
            EXC.CODPROD AS CODPROD,
            EXC.VLRVENDA AS VLRVENDA
        FROM TGFEXC EXC
        WHERE 
            NUTAB = V_NUTAB
    )
    SELECT
        V_NUNOTA,
        1,
        ROWNUM,
        P2.CODPROD,
        P.CODVOL,
        P.USOPROD,
        1,
        P2.VLRVENDA,
        P2.VLRVENDA,
        (CASE WHEN P.TEMIPIVENDA = 'S' THEN P2.VLRVENDA ELSE 0 END),
        NVL(I.PERCENTUAL,0),
        (CASE WHEN P.TEMIPIVENDA = 'S' THEN (P2.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END),
        (P2.VLRVENDA + (CASE WHEN P.TEMIPIVENDA = 'S' THEN (P2.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END)) * (1+74.94/100),
        ((P2.VLRVENDA + (CASE WHEN P.TEMIPIVENDA = 'S' THEN (P2.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END)) * (1+74.94/100) * 19.5/100) - 
            (P2.VLRVENDA * 12 / 100),
        0,
        'N',
        'A',
        17,
        NVL((SELECT CODLOCAL FROM TGFEST WHERE CODPROD = P.CODPROD AND CODEMP = 1 AND CODPARC = 0),7000000)
    FROM TAB_P2 P2
        INNER JOIN TGFPRO P ON P.CODPROD = P2.CODPROD
        LEFT JOIN TGFIPI I ON I.CODIPI = P.CODIPI
    WHERE P.ATIVO = 'S';   
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
       P_MENSAGEM := 'Gerado a NUNOTA ' || V_NUNOTA;
END;