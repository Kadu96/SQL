CREATE OR REPLACE PROCEDURE "AD_STP_UPD_LIMCRED_ULTVND_60D+" AS
BEGIN

--ATUALIZA O CAMPO Histórico Alteração Automática de Limite no Cadastro do Parceiro
    UPDATE TGFPAR SET AD_HSTLIMCRED = 'Limite de Crédito Alterado no dia '||TO_CHAR(SYSDATE,'DD/MM/YYYY')||' via rotina automática de ajuste de limite, pois não há registro de venda para este cliente nos últimos 60 dias. Limite anterior era: '||LIMCRED 
    WHERE LIMCRED <> 0.01 AND CODPARC IN (
        WITH TAB_NOTAS AS (
            SELECT 
                C.DTNEG,
                C.CODPARC
            FROM TGFCAB C
                LEFT JOIN TGFTOP T ON T.CODTIPOPER = C.CODTIPOPER
                LEFT JOIN TGFPAR PAR ON PAR.CODPARC = C.CODPARC
            WHERE
                T.GRUPO NOT LIKE 'Ajustes' AND C.TIPMOV = 'V' AND 
                PAR.LIMCRED <> 0.01 AND PAR.CLIENTE = 'S' AND 
                PAR.USUARIO <> 'S' AND PAR.CODPARC NOT IN (0,1,7,9,21452)
        )
        SELECT CODPARC FROM TAB_NOTAS
        HAVING 
            MAX(DTNEG) <= SYSDATE - 60
        GROUP BY CODPARC
    );

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
--ATUALIZA O CAMPO Limite de Crédito
    UPDATE TGFPAR SET LIMCRED = 0.01
    WHERE LIMCRED <> 0.01 AND CODPARC IN (
        WITH TAB_NOTAS AS (
            SELECT 
                C.DTNEG,
                C.CODPARC
            FROM TGFCAB C
                LEFT JOIN TGFTOP T ON T.CODTIPOPER = C.CODTIPOPER
                LEFT JOIN TGFPAR PAR ON PAR.CODPARC = C.CODPARC
            WHERE
                T.GRUPO NOT LIKE 'Ajustes' AND C.TIPMOV = 'V' AND 
                PAR.LIMCRED <> 0.01 AND PAR.CLIENTE = 'S' AND 
                PAR.USUARIO <> 'S' AND PAR.CODPARC NOT IN (0,1,7,9,21452)
        )
        SELECT CODPARC FROM TAB_NOTAS
        HAVING 
            MAX(DTNEG) <= SYSDATE - 60
        GROUP BY CODPARC
    );
END;