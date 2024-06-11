CREATE OR REPLACE PROCEDURE "AD_STP_ACTION_ENVIA_EMAIL" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       FIELD_ID NUMBER;
       V_MSG VARCHAR2(4000);
       V_ASSUNTO VARCHAR2(4000);
       V_IMG BLOB;
       V_ID NUMBER;
       C_PARC INT := 0;
       V_CODFILA NUMBER;
       V_ANEXO NUMBER;
       V_EMAIL VARCHAR2(100);

       BEGIN

-- Os valores informados pelo formulário de parâmetros, podem ser obtidos com as funções:
--     ACT_INT_PARAM
--     ACT_DEC_PARAM
--     ACT_TXT_PARAM
--     ACT_DTA_PARAM
-- Estas funções recebem 2 argumentos:
--     ID DA SESSÃO - Identificador da execução (Obtido através de P_IDSESSAO))
--     NOME DO PARAMETRO - Determina qual parametro deve se deseja obter.

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
       -- Para obter o valor dos campos utilize uma das seguintes funções:
       --     ACT_INT_FIELD (Retorna o valor de um campo tipo NUMÉRICO INTEIRO))
       --     ACT_DEC_FIELD (Retorna o valor de um campo tipo NUMÉRICO DECIMAL))
       --     ACT_TXT_FIELD (Retorna o valor de um campo tipo TEXTO),
       --     ACT_DTA_FIELD (Retorna o valor de um campo tipo DATA)
       -- Estas funções recebem 3 argumentos:
       --     ID DA SESSÃO - Identificador da execução (Obtido através do parâmetro P_IDSESSAO))
       --     NÚMERO DA LINHA - Relativo a qual linha selecionada.
       --     NOME DO CAMPO - Determina qual campo deve ser obtido.
              FIELD_ID := ACT_INT_FIELD(P_IDSESSAO, I, 'ID');
              SELECT NVL(MSG,'') INTO V_MSG FROM AD_TGFINFO WHERE ID = FIELD_ID;
              SELECT IMGINFO INTO V_IMG FROM AD_TGFINFO WHERE ID = FIELD_ID;
              --SELECT TESTE INTO IMG_INFO FROM AD_TGFINFO WHERE ID = FIELD_ID;
              SELECT ASSUNTO INTO V_ASSUNTO FROM AD_TGFINFO WHERE ID = FIELD_ID;

              SELECT NVL(MAX(ID),0) INTO V_ID FROM AD_TGFEMAIL;

              INSERT INTO AD_TGFEMAIL (ID, EMAIL, NOMEPARC)
              WITH TAB_PARC AS (
                     SELECT  
                            (CASE 
                                   WHEN EMAIL IS NULL THEN EMAILNFE
                                   ELSE EMAIL END) AS EMAIL_PARC,
                            RAZAOSOCIAL AS NOME_PARC 
                     FROM TGFPAR WHERE CODPARC = 33907 AND (EMAIL IS NOT NULL OR EMAILNFE IS NOT NULL)
              ) SELECT V_ID + 1, EMAIL_PARC, NOME_PARC FROM TAB_PARC;

              SELECT COUNT(*) INTO C_PARC FROM AD_TGFEMAIL;

              FOR J IN 1 .. C_PARC
              LOOP
                     SELECT MAX(CODFILA) INTO V_CODFILA FROM TMDFMG;
                     SELECT MAX(NUANEXO) INTO V_ANEXO FROM TMDAMG;
                     SELECT EMAILNFE INTO V_EMAIL FROM AD_TGFEMAIL WHERE ID = J;
                     INSERT INTO TMDAMG(NUANEXO,ANEXO,NOMEARQUIVO) 
                     VALUES (V_ANEXO + 1, V_IMG, V_ASSUNTO || '.png');
                     INSERT INTO TMDFMG(CODFILA,CODMSG,DTENTRADA,STATUS,CODCON,TENTENVIO,MENSAGEM,TIPOENVIO,MAXTENTENVIO,NUANEXO,ASSUNTO,EMAIL,MIMETYPE,TIPODOC,CODUSU,NUCHAVE,CODUSUREMET,REENVIAR,MSGERRO,CODSMTP,DHULTTENTA,DBHASHCODE,CODCONTASMS,CELULAR)
                     VALUES (V_CODFILA + 1, null, SYSDATE, 'Pendente', 0, 1, V_MSG, 'E', 3, V_ANEXO + 1, V_ASSUNTO, V_EMAIL, null, null, 0, null, null, 'N', null, null, null, null, null, null);
              END LOOP;

       -- <ESCREVA SEU CÓDIGO AQUI (SERÁ EXECUTADO PARA CADA REGISTRO SELECIONADO)> --

       END LOOP;

       P_MENSAGEM := 'ENVIADO E-MAIL COM SUCESSO PARA ' || C_PARC || ' PARCEIROS!';
       
       DELETE FROM AD_TGFEMAIL; 

END;