CREATE OR REPLACE PROCEDURE "AD_ATUALIZA_LIMITE_CRED" AS
BEGIN
    INSERT INTO AD_TGFHLC (CODPARC, LIMCREDANT) 
        SELECT P.CODPARC, P.LIMCRED FROM TGFPAR P
        WHERE P.CODPARC IN (        
            SELECT PAR.CODPARC 
            FROM TGFPAR PAR
            WHERE
                PAR.CLIENTE = 'S' AND
                EXISTS (
                    SELECT 
                        NUFIN
                    FROM TGFFIN
                    WHERE
                        PROVISAO = 'N' AND
                        RECDESP = 1 AND
                        DHBAIXA IS NULL AND
                        CODPARC = PAR.CODPARC
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
                            ELSE DTVENC END) < TRUNC( SYSDATE )
                    GROUP BY
                        NUFIN, DTVENC
                ));
    UPDATE TGFPAR SET LIMCRED = 0.01 WHERE CODPARC IN (
        SELECT PAR.CODPARC
        FROM TGFPAR PAR
        WHERE
            PAR.CLIENTE = 'S' AND
            EXISTS (
                SELECT 
                    NUFIN
                FROM TGFFIN
                WHERE
                    PROVISAO = 'N' AND
                    RECDESP = 1 AND
                    DHBAIXA IS NULL AND
                    CODPARC = PAR.CODPARC
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
                        ELSE DTVENC END) < TRUNC( SYSDATE )
                GROUP BY
                    NUFIN, DTVENC
            ));
    UPDATE AD_TGFHLC SET LIMCREDNOVO = 0.01 WHERE CODPARC IN (    
        SELECT PAR.CODPARC
        FROM TGFPAR PAR
        WHERE
            PAR.CLIENTE = 'S' AND
            EXISTS (
                SELECT 
                    NUFIN
                FROM TGFFIN
                WHERE
                    PROVISAO = 'N' AND
                    RECDESP = 1 AND
                    DHBAIXA IS NULL AND
                    CODPARC = PAR.CODPARC
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
                        ELSE DTVENC END) < TRUNC( SYSDATE )
                GROUP BY
                    NUFIN, DTVENC
            ));
END;
/