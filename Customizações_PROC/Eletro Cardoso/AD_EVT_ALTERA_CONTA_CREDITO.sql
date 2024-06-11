CREATE OR REPLACE PROCEDURE "AD_EVT_ALTERA_CONTA_CREDITO" (
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

       V_NUFIN INT;
       V_TIPOTITULO INT;
       V_ORIGEM VARCHAR2(2);
       V_CODPARC INT;
       V_NUNOTA INT;
       
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;

/********************************************************************************/


       IF P_TIPOEVENTO = AFTER_INSERT THEN
              V_NUFIN := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUFIN');
              SELECT CODTIPTIT INTO V_TIPOTITULO FROM TGFFIN WHERE NUFIN = V_NUFIN;
              SELECT ORIGEM INTO V_ORIGEM FROM TGFFIN WHERE NUFIN = V_NUFIN;
              SELECT CODPARC INTO V_CODPARC FROM TGFFIN WHERE NUFIN = V_NUFIN;
              SELECT NUNOTA INTO V_NUNOTA FROM TGFFIN WHERE NUFIN = V_NUFIN;

              IF V_TIPOTITULO = 16 THEN 
                     UPDATE TGFFIN SET CODCTABCOINT = '' WHERE NUFIN = V_NUFIN;
              ELSIF V_TIPOTITULO = 17 THEN
                     UPDATE TGFFIN SET CODCTABCOINT = '' WHERE NUFIN = V_NUFIN;
              END IF;

              IF V_ORIGEM = 'E' THEN
                     IF V_CODPARC = 9 THEN 
                            UPDATE TGFFIN SET CODPARC = (
                                   SELECT CODPARC FROM TGFCAB WHERE NUNOTA = V_NUNOTA
                            ) WHERE NUFIN = V_NUFIN;
                     ELSIF V_CODPARC = 10 THEN
                            UPDATE TGFFIN SET CODPARC = (
                                   SELECT CODPARC FROM TGFCAB WHERE NUNOTA = V_NUNOTA
                            ) WHERE NUFIN = V_NUFIN;
                     END IF;
              END IF;

       END IF;

       IF P_TIPOEVENTO = AFTER_UPDATE THEN
              V_NUFIN := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUFIN');
              SELECT CODTIPTIT INTO V_TIPOTITULO FROM TGFFIN WHERE NUFIN = V_NUFIN;
              SELECT ORIGEM INTO V_ORIGEM FROM TGFFIN WHERE NUFIN = V_NUFIN;
              SELECT CODPARC INTO V_CODPARC FROM TGFFIN WHERE NUFIN = V_NUFIN;
              SELECT NUNOTA INTO V_NUNOTA FROM TGFFIN WHERE NUFIN = V_NUFIN;

              IF V_TIPOTITULO = 16 THEN 
                     UPDATE TGFFIN SET CODCTABCOINT = '' WHERE NUFIN = V_NUFIN;
              ELSIF V_TIPOTITULO = 17 THEN
                     UPDATE TGFFIN SET CODCTABCOINT = '' WHERE NUFIN = V_NUFIN;
              END IF;

              IF V_ORIGEM = 'E' THEN
                     IF V_CODPARC = 9 THEN 
                            UPDATE TGFFIN SET CODPARC = (
                                   SELECT CODPARC FROM TGFCAB WHERE NUNOTA = V_NUNOTA
                            ) WHERE NUFIN = V_NUFIN;
                     ELSIF V_CODPARC = 10 THEN
                            UPDATE TGFFIN SET CODPARC = (
                                   SELECT CODPARC FROM TGFCAB WHERE NUNOTA = V_NUNOTA
                            ) WHERE NUFIN = V_NUFIN;
                     END IF;
              END IF;

       END IF;

END;