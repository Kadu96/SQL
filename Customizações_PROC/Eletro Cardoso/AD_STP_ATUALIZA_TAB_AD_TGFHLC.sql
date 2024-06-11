CREATE OR REPLACE PROCEDURE "AD_STP_ATUALIZA_TAB_AD_TGFHLC" AS
BEGIN
/*--VERIFICA OS PARCEIROS QUE ESTÃO NA AD_TGFHLC E NÃO POSSUEM MAIS TÍTULO EM ATRASO E REMOVE-OS--*/
    DELETE FROM AD_TGFHLC WHERE CODPARC IN (
        SELECT PAR.CODPARC
        FROM TGFPAR PAR
        WHERE
            PAR.CLIENTE = 'S' AND PAR.USUARIO <> 'S' AND
            PAR.CODPARC NOT IN (0,1,7,9) AND
            PAR.CODPARC NOT IN (
                SELECT CODPARC
                FROM TGFFIN
                WHERE
                    PROVISAO = 'N' AND
                    RECDESP = 1 AND
                    DHBAIXA IS NULL
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
                    CODPARC, CODBCO, CODTIPTIT, DTVENC
            ));
END;