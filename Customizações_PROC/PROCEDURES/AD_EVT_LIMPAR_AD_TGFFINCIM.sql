CREATE OR REPLACE PROCEDURE "AD_EVT_LIMPAR_AD_TGFFINCIM" (
       P_TIPOEVENTO INT,    -- Identifica o tipo de evento
       P_IDSESSAO VARCHAR2, -- Identificador da execução. Serve para buscar informações dos campos da execução.
       P_CODUSU INT         -- Código do usuário logado
) AS
    BEFORE_INSERT INT;
    AFTER_INSERT  INT;
    BEFORE_DELETE INT;
    AFTER_DELETE  INT;
    BEFORE_UPDATE INT;
    AFTER_UPDATE  INT;
    BEFORE_COMMIT INT;

    V_NUFIN NUMBER;

BEGIN
    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;
       
/*******************************************************************************
   É possível obter o valor dos campos através das Functions:
   
  EVP_GET_CAMPO_DTA(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS DE DATA
  EVP_GET_CAMPO_INT(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS NUMÉRICOS INTEIROS
  EVP_GET_CAMPO_DEC(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS NUMÉRICOS DECIMAIS
  EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'NOMECAMPO')   -- PARA CAMPOS TEXTO
  
********************************************************************************/

    IF P_TIPOEVENTO = BEFORE_DELETE THEN
        V_NUFIN := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUFIN');

        DELETE FROM AD_TGFFINCIM WHERE NUFIN = V_NUFIN;

    END IF;


END;