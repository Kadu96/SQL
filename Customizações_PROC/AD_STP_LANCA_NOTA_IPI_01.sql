CREATE OR REPLACE PROCEDURE "AD_STP_LANCA_NOTA_IPI" AS
BEGIN
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--INSERI CABEÇALHO DA NOTA
    INSERT INTO TGFCAB (NUNOTA,NUMNOTA,CODEMP,CODEMPNEGOC,CODPARC,TIPMOV,CODTIPVENDA,DHTIPVENDA,CODTIPOPER,DHTIPOPER,NUFOP,DTMOV,DTNEG,CODVEND,CODCENCUS,CODNAT,PENDENTE,STATUSNOTA,CODUSU,DTALTER)
    VALUES (
        (SELECT MAX(NUNOTA)+1 FROM TGFCAB),
        0,
        1,
        1,
        1,
        'V',
        11,
        (SELECT MAX(DHALTER) FROM TGFTPV WHERE CODTIPVENDA = 11),
        1726,
        (SELECT MAX(DHALTER) FROM TGFTOP WHERE CODTIPOPER = 1726),
        1,
        SYSDATE,
        SYSDATE,
        17,
        104002,
        101001,
        'S',
        'A',
        0,
        SYSDATE
    );
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--ATUALIZA OBSERVAÇÕES DA NOTA
    UPDATE TGFCAB SET OBSERVACAO = 
        (WITH CONSULTA AS (
        SELECT DISTINCT 
            (CASE 
                WHEN CAB.TIPMOV = 'V' THEN CAB.NUMNOTA
                WHEN CAB.TIPMOV = 'D' THEN
                    (SELECT C.NUMNOTA FROM TGFCAB C WHERE C.NUNOTA = VAR.NUNOTAORIG AND VAR.SEQUENCIA = 1)
            END) AS NUMNOTA
        FROM TGFCAB CAB
        LEFT JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
        LEFT JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD 
        LEFT JOIN TGFIPI IPI ON IPI.CODIPI = PRO.CODIPI
        LEFT JOIN TGFVAR VAR ON VAR.NUNOTA = CAB.NUNOTA
        WHERE PRO.CODIPI > 0
        AND PRO.TEMIPIVENDA = 'S'
        AND CAB.TIPMOV IN ('V', 'D')
        AND CAB.DTNEG = SYSDATE
        AND CAB.STATUSNOTA = 'L'
        AND CAB.CODTIPOPER IN (1101,1710)
        )
        SELECT 'Nota fiscal emitida exclusivamente pra uso interno cfe. Art. 408 RIPI/2010. Notas Fiscais de Venda a Consumidor nº '||LISTAGG(NUMNOTA,',') WITHIN GROUP (ORDER BY NUMNOTA) AS OBS 
        FROM CONSULTA)
    WHERE NUNOTA = (SELECT MAX(NUNOTA) FROM TGFCAB WHERE CODTIPOPER = 1726);
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--INSERI ITENS NA NOTA
    INSERT INTO TGFITE (NUNOTA,CODEMP,SEQUENCIA,CODPROD,CODVOL,USOPROD,QTDNEG,VLRUNIT,VLRTOT,ALIQIPI,VLRIPI,ATUALESTOQUE,RESERVA,STATUSNOTA,CODVEND,PERCDESC,VLRDESC,CODLOCALORIG)
    WITH TAB_IPI AS (
        SELECT
            CAB.NUNOTA,
            CAB.NUMNOTA,
            (CASE WHEN CAB.TIPMOV = 'D' THEN (SELECT NUMNOTA FROM TGFCAB WHERE NUNOTA = VAR.NUNOTAORIG) ELSE CAB.NUMNOTA END), 
            CAB.SERIENOTA, 
            CAB.DTNEG, 
            CAB.DTMOV,
            PRO.CODPROD, 
            PRO.DESCRPROD,
            ITE.QTDNEG,
            ITE.VLRUNIT,
            ITE.VLRTOT - ITE.VLRDESC as VLRTOTNOTA, 
            ITE.VLRDESC,
            ITE.PERCDESC,
            SNK_GET_PRECO(1, ITE.CODPROD, CAB.DTNEG) as VLRUNTT0,
            SNK_GET_PRECO(1, ITE.CODPROD, CAB.DTNEG) * ITE.QTDNEG AS VLRTOT,
            IPI.PERCENTUAL AS PERC_IPI,
            (
                (
                    ( SNK_GET_PRECO(1, ITE.CODPROD, CAB.DTNEG) * ITE.QTDNEG ) - 
                    (
                        ( SNK_GET_PRECO(1, ITE.CODPROD, CAB.DTNEG) * ITE.QTDNEG ) * ITE.PERCDESC / 100
                    )
                ) *  IPI.PERCENTUAL / 100
            ) AS VLRIPI,
            CAB.TIPMOV
        FROM TGFITE ITE
            LEFT JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
            LEFT JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD 
            LEFT JOIN TGFIPI IPI ON IPI.CODIPI = PRO.CODIPI
            LEFT JOIN TGFVAR VAR ON VAR.NUNOTA = ITE.NUNOTA AND VAR.SEQUENCIA = 1
        WHERE PRO.CODIPI > 0
            AND PRO.TEMIPIVENDA = 'S'
            AND CAB.TIPMOV IN ('V', 'D')
            AND CAB.DTNEG = TO_CHAR(SYSDATE,'DD/MM/YYYY')
            AND CAB.STATUSNOTA = 'L'
            AND CAB.CODTIPOPER IN (1101,1710)
    )
    SELECT
        (SELECT MAX(NUNOTA) FROM TGFCAB WHERE CODTIPOPER = 1726),
        1,
        ROWNUM,
        I.CODPROD,    
        P.CODVOL,
        P.USOPROD,
        I.QTDNEG,
        I.VLRUNTT0,
        I.VLRTOT,
        I.PERC_IPI,
        I.VLRIPI,
        0,
        'N',
        'A',
        17,
        I.PERCDESC,
        I.VLRDESC,
        (SELECT CODLOCAL FROM TGFEST WHERE CODPROD = P.CODPROD AND CODEMP = 1 AND CODPARC = 0)
    FROM TAB_IPI I
        INNER JOIN TGFPRO P ON P.CODPROD = I.CODPROD;
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

END;