CREATE OR REPLACE PROCEDURE "AD_STP_ACTION_ENVIA_EMAIL" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_FAIXA_PARC VARCHAR2(4000);
       FIELD_ID NUMBER;
       V_MSG VARCHAR2(4000);
       V_ASSUNTO VARCHAR2(4000);
       V_IMG BLOB;
       V_ID NUMBER;
       C_PARC INT := 0;
       C_EMAILS INT := 0;
       V_CODFILA NUMBER;
       V_ANEXO NUMBER;
       V_EMAIL VARCHAR2(1000);
       FXA_INI NUMBER;
       FXA_FIM NUMBER;

BEGIN
       PARAM_FAIXA_PARC := ACT_TXT_PARAM(P_IDSESSAO, 'faixa_parc');
       IF PARAM_FAIXA_PARC = '1' THEN
              FXA_INI := 5000;
              FXA_FIM := 9999;
       ELSIF PARAM_FAIXA_PARC = '2' THEN
              FXA_INI := 10000;
              FXA_FIM := 14999;
       ELSIF PARAM_FAIXA_PARC = '3' THEN
              FXA_INI := 15000;
              FXA_FIM := 19999;
       ELSIF PARAM_FAIXA_PARC = '4' THEN
              FXA_INI := 20000;
              FXA_FIM := 24999;
       ELSIF PARAM_FAIXA_PARC = '5' THEN
              FXA_INI := 25000;
              FXA_FIM := 29999;
       ELSIF PARAM_FAIXA_PARC = '6' THEN
              FXA_INI := 30000;
              FXA_FIM := 100000;
       END IF;

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
       
              FIELD_ID := ACT_INT_FIELD(P_IDSESSAO, I, 'ID');
              SELECT NVL(MSG,'Segue Informativo em Anexo') INTO V_MSG FROM AD_TGFINFO WHERE ID = FIELD_ID;
              SELECT IMGINFO INTO V_IMG FROM AD_TGFINFO WHERE ID = FIELD_ID;
              SELECT ASSUNTO INTO V_ASSUNTO FROM AD_TGFINFO WHERE ID = FIELD_ID;

              execute immediate 'ALTER TABLE AD_TGFEMAILS MODIFY(ID GENERATED AS IDENTITY (START WITH 1))';
              
             /* INSERT INTO AD_TGFEMAILS (CODPARC,EMAILS)
              WITH TAB_EMAILS AS (
                     SELECT
                            CODPARC,
                            EMAILNFE
                     FROM TGFPAR WHERE CLIENTE = 'S' AND EMAILNFE IS NOT NULL AND CODPARC >= FXA_INI AND CODPARC <= FXA_FIM
              )SELECT
                     CODPARC,
                     REGEXP_SUBSTR(EMAILNFE,'[^;]+',1,LEVEL) AS EMAILS
              FROM TAB_EMAILS 
                     CONNECT BY REGEXP_SUBSTR(EMAILNFE,'[^;]+',1,LEVEL) IS NOT NULL;*/

              INSERT INTO AD_TGFEMAILS (EMAILS, CODPARC)
                     SELECT EMAILNFE, CODPARC 
                     FROM TGFPAR WHERE CLIENTE = 'S' AND EMAILNFE IS NOT NULL AND CODPARC >= FXA_INI AND CODPARC <= FXA_FIM;

              SELECT COUNT(*) INTO C_PARC FROM AD_TGFEMAILS;

              SELECT MAX(NUANEXO) + 1 INTO V_ANEXO FROM TMDAMG;
              INSERT INTO TMDAMG(NUANEXO,ANEXO,NOMEARQUIVO,TIPO) 
                     VALUES (V_ANEXO, V_IMG, 'informativo.png','image/png');

              FOR J IN 1 .. C_PARC
              LOOP
                     SELECT REGEXP_COUNT(EMAILS,'[^;]+',1) INTO C_EMAILS FROM AD_TGFEMAILS WHERE ID = J;

                     FOR K IN 1 .. C_EMAILS
                     LOOP
                            SELECT REGEXP_SUBSTR(EMAILS,'[^;]+',1,K) INTO V_EMAIL FROM AD_TGFEMAILS WHERE ID = J;
                            SELECT MAX(CODFILA) INTO V_CODFILA FROM TMDFMG;

                            INSERT INTO TMDFMG(CODFILA,CODMSG,DTENTRADA,STATUS,CODCON,TENTENVIO,MENSAGEM,TIPOENVIO,MAXTENTENVIO,NUANEXO,ASSUNTO,EMAIL,MIMETYPE,TIPODOC,CODUSU,NUCHAVE,CODUSUREMET,REENVIAR,MSGERRO,CODSMTP,DHULTTENTA,DBHASHCODE,CODCONTASMS,CELULAR)
                                   VALUES (V_CODFILA + 1, null, SYSDATE, 'Pendente', 0, 1, V_MSG, 'E', 3, V_ANEXO, V_ASSUNTO, V_EMAIL, 'text/html', null, 0, null, null, 'N', null, null, null, null, null, null);
                     END LOOP;

              END LOOP;

       END LOOP;

       P_MENSAGEM := 'ENVIADO E-MAIL PARA ' || C_PARC || ' PARCEIROS!';

       DELETE FROM AD_TGFEMAILS; 

END;