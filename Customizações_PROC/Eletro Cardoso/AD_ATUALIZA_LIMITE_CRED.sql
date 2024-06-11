CREATE OR REPLACE PROCEDURE "AD_ATUALIZA_LIMITE_CRED" AS
BEGIN
/*--VERIFICA OS PARCEIROS COM TÍTULO VENCIDO (D+1) E COM LIMITE DE CRÉDITO DIFERENTE DE 0,01 E INSERE NA TEBELA DE HISTÓRICO (AD_TGFHLC) SE AINDA NÃO ESTIVER*/

    INSERT INTO AD_TGFHLC (CODPARC, LIMCREDANT) 
    SELECT P.CODPARC, P.LIMCRED FROM TGFPAR P
    WHERE P.CODPARC IN (        
        SELECT PAR.CODPARC 
        FROM TGFPAR PAR
        WHERE
            PAR.CLIENTE = 'S' AND PAR.USUARIO <> 'S' AND
            PAR.CODPARC NOT IN (SELECT CODPARC FROM AD_TGFHLC) AND PAR.CODPARC NOT IN (0,1,7,9,21452) AND
            EXISTS (
                SELECT F.NUFIN
                FROM TGFFIN F
                    LEFT JOIN TGFTOP T ON T.CODTIPOPER = F.CODTIPOPER
                WHERE
                    F.PROVISAO = 'N' AND
                    F.RECDESP = 1 AND
                    F.DHBAIXA IS NULL AND
                    F.CODPARC = PAR.CODPARC AND
                    T.GRUPO NOT LIKE 'Ajustes'
                HAVING
                    (CASE 
                        WHEN TO_CHAR(DTVENC, 'D') = 7 THEN
                            DTVENC + 2
                        WHEN TO_CHAR(DTVENC, 'D') = 1 THEN
                            DTVENC + 1 
                        WHEN TO_CHAR(DTVENC, 'DD/MM/YYYY') IN 
                            (SELECT TO_CHAR(DTFERIADO, 'DD/MM/YYYY') FROM TSIFER WHERE TO_CHAR(DTFERIADO, 'YYYY') = 2024) AND TO_CHAR(DTVENC, 'D') = 6 THEN
                            DTVENC + 3
                        WHEN TO_CHAR(DTVENC, 'DD/MM/YYYY') IN 
                            (SELECT TO_CHAR(DTFERIADO, 'DD/MM/YYYY') FROM TSIFER WHERE TO_CHAR(DTFERIADO, 'YYYY') = 2024) THEN
                            DTVENC + 1
                        WHEN CODBCO = 33 AND CODTIPTIT = 4 THEN
                            DTVENC + 1 
                        ELSE DTVENC + 1 END) < TRUNC(SYSDATE)
                GROUP BY
                    NUFIN, CODBCO, CODTIPTIT, DTVENC
            ));
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
/*--ATUALIZA NA TGFPAR O CAMPO "ÚLTIMO LIMITE APROVADO" COM O VALOR DE LIMITE DE CRÉDITO ANTERIOR--*/

    UPDATE TGFPAR PAR SET PAR.AD_ULTLIMCRED = (
        SELECT LIMCREDANT FROM AD_TGFHLC WHERE CODPARC = PAR.CODPARC) 
    WHERE PAR.CODPARC IN (
        SELECT PAR.CODPARC 
        FROM TGFPAR PAR
        WHERE
            PAR.CLIENTE = 'S' AND PAR.USUARIO <> 'S' AND PAR.AD_ULTLIMCRED IS NULL AND
            PAR.CODPARC IN (SELECT CODPARC FROM AD_TGFHLC) AND PAR.CODPARC NOT IN (0,1,7,9,21452) AND
            EXISTS (
                SELECT F.NUFIN
                FROM TGFFIN F
                    LEFT JOIN TGFTOP T ON T.CODTIPOPER = F.CODTIPOPER
                WHERE
                    F.PROVISAO = 'N' AND
                    F.RECDESP = 1 AND
                    F.DHBAIXA IS NULL AND
                    F.CODPARC = PAR.CODPARC AND
                    T.GRUPO NOT LIKE 'Ajustes'
                HAVING
                    (CASE 
                        WHEN TO_CHAR(DTVENC, 'D') = 7 THEN
                            DTVENC + 2
                        WHEN TO_CHAR(DTVENC, 'D') = 1 THEN
                            DTVENC + 1 
                        WHEN TO_CHAR(DTVENC, 'DD/MM/YYYY') IN 
                            (SELECT TO_CHAR(DTFERIADO, 'DD/MM/YYYY') FROM TSIFER WHERE TO_CHAR(DTFERIADO, 'YYYY') = 2024) AND TO_CHAR(DTVENC, 'D') = 6 THEN
                            DTVENC + 3
                        WHEN TO_CHAR(DTVENC, 'DD/MM/YYYY') IN 
                            (SELECT TO_CHAR(DTFERIADO, 'DD/MM/YYYY') FROM TSIFER WHERE TO_CHAR(DTFERIADO, 'YYYY') = 2024) THEN
                            DTVENC + 1
                        WHEN CODBCO = 33 AND CODTIPTIT = 4 THEN
                            DTVENC + 1 
                        ELSE DTVENC + 1 END) < TRUNC(SYSDATE)
                GROUP BY
                    NUFIN, CODBCO, CODTIPTIT, DTVENC
            ));

/*-------------------------------------------------------------------------------------------------------------------------------------------*/ 
/*--ATUALIZA O LIMITE DE CRÉDITO DOS CLIENTES COM ATRASO PARA 0,01--*/     

    UPDATE TGFPAR SET LIMCRED = 0.01 WHERE CODPARC IN (
        SELECT PAR.CODPARC 
        FROM TGFPAR PAR
        WHERE
            PAR.CLIENTE = 'S' AND PAR.USUARIO <> 'S' AND
            PAR.CODPARC IN (SELECT CODPARC FROM AD_TGFHLC) AND PAR.CODPARC NOT IN (0,1,7,9,21452) AND
            EXISTS (
                SELECT F.NUFIN
                FROM TGFFIN F
                    LEFT JOIN TGFTOP T ON T.CODTIPOPER = F.CODTIPOPER
                WHERE
                    F.PROVISAO = 'N' AND
                    F.RECDESP = 1 AND
                    F.DHBAIXA IS NULL AND
                    F.CODPARC = PAR.CODPARC AND
                    T.GRUPO NOT LIKE 'Ajustes'
                HAVING
                    (CASE 
                        WHEN TO_CHAR(DTVENC, 'D') = 7 THEN
                            DTVENC + 2
                        WHEN TO_CHAR(DTVENC, 'D') = 1 THEN
                            DTVENC + 1 
                        WHEN TO_CHAR(DTVENC, 'DD/MM/YYYY') IN 
                            (SELECT TO_CHAR(DTFERIADO, 'DD/MM/YYYY') FROM TSIFER WHERE TO_CHAR(DTFERIADO, 'YYYY') = 2024) AND TO_CHAR(DTVENC, 'D') = 6 THEN
                            DTVENC + 3
                        WHEN TO_CHAR(DTVENC, 'DD/MM/YYYY') IN 
                            (SELECT TO_CHAR(DTFERIADO, 'DD/MM/YYYY') FROM TSIFER WHERE TO_CHAR(DTFERIADO, 'YYYY') = 2024) THEN
                            DTVENC + 1
                        WHEN CODBCO = 33 AND CODTIPTIT = 4 THEN
                            DTVENC + 1 
                        ELSE DTVENC + 1 END) < TRUNC(SYSDATE)
                GROUP BY
                    NUFIN, CODBCO, CODTIPTIT, DTVENC
            ));

/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--ATUALIZA O CAMPO LIMITE CREDITO NOVO NA AD_TGFHLC PARA 0,01 PARA FIM DE RELATÓRIO--*/
    UPDATE AD_TGFHLC SET LIMCREDNOVO = 0.01 WHERE LIMCREDNOVO IS NULL;
END;
/