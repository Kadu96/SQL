CREATE OR REPLACE PROCEDURE SANKHYA."AD_EVT_ATUALIZA_FINANCEIRO" (
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
       V_NUNOTA NUMBER;
       V_TIPTITULO NUMBER;
       V_ORIGEM VARCHAR2(2);

BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;

       IF P_TIPOEVENTO = AFTER_INSERT THEN

              V_NUFIN := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUFIN'); 
              SELECT ORIGEM INTO V_ORIGEM FROM TGFFIN WHERE NUFIN = V_NUFIN;

              IF V_ORIGEM = 'E' THEN 
                     SELECT NUNOTA INTO V_NUNOTA FROM TGFFIN WHERE NUFIN = V_NUFIN;
                     SELECT AD_CODTIPTIT INTO V_TIPTITULO FROM TGFCAB WHERE NUNOTA = V_NUNOTA; 
                     SELECT CODTIPTIT INTO V_FINTITULO FROM TGFFIN WHERE NUFIN = V_NUFIN;

                     IF V_TIPTITULO <> V_FINTITULO THEN
                            UPDATE TGFFIN SET CODTIPTIT = V_TIPTITULO WHERE NUFIN = V_NUFIN;
                     END IF;
              END IF;

       END IF;

END;