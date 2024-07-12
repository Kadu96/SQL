CREATE OR REPLACE PROCEDURE "AD_STP_ATUALIZA_TAB_AD_TGFHLC" AS
BEGIN
/*--VERIFICA OS PARCEIROS QUE ESTÃO NA AD_TGFHLC E NÃO POSSUEM MAIS TÍTULO EM ATRASO E REMOVE-OS--*/
    DELETE FROM AD_TGFHLC 
    WHERE CODPARC NOT IN (
                SELECT CODPARC FROM AD_TGFATR);
END;