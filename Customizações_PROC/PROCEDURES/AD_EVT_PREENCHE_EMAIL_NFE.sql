CREATE OR REPLACE PROCEDURE "AD_EVT_PREENCHE_EMAIL_NFE" (
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

       V_PARCEIRO NUMBER;
       V_EMAIL VARCHAR2(100);
       V_EMAILNFE VARCHAR2(200);

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

       IF P_TIPOEVENTO = AFTER_INSERT THEN
              V_PARCEIRO := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPARC');
              SELECT CASE WHEN EMAIL IS NULL THEN '0' ELSE EMAIL INTO V_EMAIL FROM TGFPAR WHERE CODPARC = V_PARCEIRO;
              SELECT CASE WHEN EMAILNFE IS NULL THEN '0' ELSE EMAILNFE INTO V_EMAILNFE FROM TGFPAR WHERE CODPARC = V_PARCEIRO;

              IF V_EMAIL <> '0' THEN
                     IF V_EMAILNFE = '0' THEN
                            UPDATE TGFPAR SET EMAILNFE = V_EMAIL WHERE CODPARC = V_PARCEIRO;
                     ELSE
                            UPDATE TGFPAR SET EMAILNFE = V_EMAILNEFE || ';' || V_EMAIL WHERE CODPARC = V_PARCEIRO;
                     END IF;
              END IF;
              
       END IF;

END;