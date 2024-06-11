CREATE OR REPLACE PROCEDURE SANKHYA."AD_EVT_ATUALIZA_TIT_FIN" (
       P_TIPOEVENTO INT,    -- Identifica o tipo de evento
       P_IDSESSAO VARCHAR2, -- Identificador da execuÃ¿Â§Ã¿Â£o. Serve para buscar informaÃ¿Â§Ã¿Âµes dos campos da execuÃ¿Â§Ã¿Â£o.
       P_CODUSU INT         -- CÃ¿Â³digo do usuÃ¿Â¡rio logado
) AS
       BEFORE_INSERT INT;
       AFTER_INSERT  INT;
       BEFORE_DELETE INT;
       AFTER_DELETE  INT;
       BEFORE_UPDATE INT;
       AFTER_UPDATE  INT;
       BEFORE_COMMIT INT;

       V_NUFIN NUMBER;
       V_NUNOTA NUMBER;
       V_TIPTITULO NUMBER;
       V_FINTITULO NUMBER;
       C_NUFIN INT;

BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;

	IF P_TIPOEVENTO = AFTER_UPDATE THEN

		V_NUNOTA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA'); 
              SELECT TIPMOV INTO V_TIPMOV FROM TGFCAB WHERE NUNOTA = V_NUNOTA;
		SELECT COUNT(*) INTO C_NUFIN FROM TGFFIN WHERE NUNOTA = V_NUNOTA;
            
              IF V_TIPMOV = 'V' THEN
                     IF C_NUFIN > 0 THEN 
                            SELECT AD_CODTIPTIT INTO V_TIPTITULO FROM TGFCAB WHERE NUNOTA = V_NUNOTA;
                            UPDATE TGFFIN SET CODTIPTIT = V_TIPTITULO WHERE NUNOTA = V_NUNOTA;
                     END IF;
              END IF;

	END IF;

END;