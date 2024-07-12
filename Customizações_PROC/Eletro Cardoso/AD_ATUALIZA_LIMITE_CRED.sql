CREATE OR REPLACE PROCEDURE "AD_ATUALIZA_LIMITE_CRED" AS
BEGIN
/*--VERIFICA OS PARCEIROS COM TÍTULO VENCIDO (D+1) E COM LIMITE DE CRÉDITO DIFERENTE DE 0,01 E INSERE NA TABELA DE HISTÓRICO (AD_TGFHLC) SE AINDA NÃO ESTIVER*/
    INSERT INTO AD_TGFHLC (CODPARC, LIMCREDANT)
    SELECT CODPARC, LIMCRED 
    FROM TGFPAR
    WHERE 
        LIMCRED > 0.01 AND
        CODPARC NOT IN (SELECT CODPARC FROM AD_TGFHLC) AND
        CODPARC IN (
            SELECT CODPARC FROM AD_TGFATR);   
/*-------------------------------------------------------------------------------------------------------------------------------------------*/
/*--ATUALIZA NA TGFPAR O CAMPO "ÚLTIMO LIMITE APROVADO" COM O VALOR DE LIMITE DE CRÉDITO ANTERIOR--*/
    UPDATE TGFPAR SET AD_ULTLIMCRED = LIMCRED
    WHERE 
        LIMCRED > 0.01 AND 
        CODPARC IN (
            SELECT CODPARC FROM AD_TGFATR);
/*-------------------------------------------------------------------------------------------------------------------------------------------*/ 
/*--ATUALIZA O LIMITE DE CRÉDITO DOS CLIENTES COM ATRASO PARA 0,01--*/     
    UPDATE TGFPAR SET LIMCRED = 0.01 
    WHERE 
        LIMCRED > 0.01 AND 
        CODPARC IN (
            SELECT CODPARC FROM AD_TGFATR);
/*--------------------------------------------------------------------------------------------------------------------------------------------*/
/*--ATUALIZA O CAMPO LIMITE CREDITO NOVO NA AD_TGFHLC PARA 0,01 PARA FIM DE RELATÓRIO--*/
    UPDATE AD_TGFHLC SET LIMCREDNOVO = 0.01, DTALT = SYSDATE WHERE LIMCREDNOVO IS NULL;

END;