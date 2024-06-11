CREATE OR REPLACE PROCEDURE "AD_STP_AVISA_CANCELAMENTO" (
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

       P_NUNOTA NUMBER;
       P_ASSUNTO VARCHAR2(4000);
       P_TXTEMAIL VARCHAR2(4000);
       P_EMAIL01 VARCHAR2(4000);
       P_EMAIL02 VARCHAR2(4000);
       P_EMAIL03 VARCHAR2(4000);
       P_XMLAGEND01 VARCHAR2(4000);
       P_XMLAGEND02 VARCHAR2(4000);
       P_XMLAGEND03 VARCHAR2(4000);

       C_POSTE INT := 0;
       I_SEQ INT;

       V_STATUSNOTA VARCHAR2(1);
       V_STATUSNFE VARCHAR2(1);
       V_NUMNOTA NUMBER;
       V_NUNOTA NUMBER;
       V_CODFILA INT;
       V_TIPMOV VARCHAR2(2);

BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;


        IF P_TIPOEVENTO = AFTER_INSERT THEN
                P_NUNOTA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
                SELECT STATUSNOTA INTO V_STATUSNOTA FROM TGFCAB_EXC WHERE NUNOTA = P_NUNOTA;
                SELECT STATUSNFE INTO V_STATUSNFE FROM TGFCAB_EXC WHERE NUNOTA = P_NUNOTA;
                SELECT TIPMOV INTO V_TIPMOV FROM TGFCAB_EXC WHERE NUNOTA = P_NUNOTA;
                SELECT COUNT(CODPROD) INTO C_POSTE FROM TGFITE_EXC 
                        WHERE NUNOTA = P_NUNOTA AND
                        CODPROD  IN (
                                SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
                
                IF C_POSTE > 0 THEN
                        IF V_TIPMOV = 'V' AND V_STATUSNFE = 'A' AND V_STATUSNOTA = 'L' THEN

                                SELECT NUMNOTA INTO V_NUMNOTA FROM TGFCAB WHERE NUNOTA = V_NUNOTA;

                                P_ASSUNTO := 'CANCELAMENTO - Entrega de Poste NF-e ' || V_NUMNOTA;
                                P_TXTEMAIL := 'NF-e ' || V_NUMNOTA || 'Cancelada. Entrega de Poste Cancelada.';
                                P_EMAIL01 := 'everaldo@eletrocardoso.com.br';
                                P_EMAIL02 := 'beatris@eletrocardoso.com.br';
                                P_EMAIL03 := 'eletrocardoso@eletrocardoso.com.br';
                                
                                SELECT MAX(CODFILA) INTO V_CODFILA FROM TMDFMG;

                                INSERT INTO TMDFMG(CODFILA,CODMSG,DTENTRADA,STATUS,CODCON,TENTENVIO,MENSAGEM,TIPOENVIO,MAXTENTENVIO,NUANEXO,ASSUNTO,EMAIL,MIMETYPE,TIPODOC,CODUSU,NUCHAVE,CODUSUREMET,REENVIAR,MSGERRO,CODSMTP,DHULTTENTA,DBHASHCODE,CODCONTASMS,CELULAR)
                                    VALUES (V_CODFILA + 1, null, SYSDATE, 'Pendente', 0, 1, P_TXTEMAIL, 'E', 3, null, P_ASSUNTO, P_EMAIL01, 'text/html', null, 0, null, null, 'N', null, null, null, null, null, null);

                                INSERT INTO TMDFMG(CODFILA,CODMSG,DTENTRADA,STATUS,CODCON,TENTENVIO,MENSAGEM,TIPOENVIO,MAXTENTENVIO,NUANEXO,ASSUNTO,EMAIL,MIMETYPE,TIPODOC,CODUSU,NUCHAVE,CODUSUREMET,REENVIAR,MSGERRO,CODSMTP,DHULTTENTA,DBHASHCODE,CODCONTASMS,CELULAR)
                                    VALUES (V_CODFILA + 1, null, SYSDATE, 'Pendente', 0, 1, P_TXTEMAIL, 'E', 3, null, P_ASSUNTO, P_EMAIL02, 'text/html', null, 0, null, null, 'N', null, null, null, null, null, null);
                                
                                INSERT INTO TMDFMG(CODFILA,CODMSG,DTENTRADA,STATUS,CODCON,TENTENVIO,MENSAGEM,TIPOENVIO,MAXTENTENVIO,NUANEXO,ASSUNTO,EMAIL,MIMETYPE,TIPODOC,CODUSU,NUCHAVE,CODUSUREMET,REENVIAR,MSGERRO,CODSMTP,DHULTTENTA,DBHASHCODE,CODCONTASMS,CELULAR)
                                    VALUES (V_CODFILA + 1, null, SYSDATE, 'Pendente', 0, 1, P_TXTEMAIL, 'E', 3, null, P_ASSUNTO, P_EMAIL03, 'text/html', null, 0, null, null, 'N', null, null, null, null, null, null);

                                SELECT SEQUENCIA INTO I_SEQ FROM TGFITE 
                                    WHERE NUNOTA = P_NUNOTA AND CODPROD  IN (
                                        SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
                                SELECT NUNOTAORIG INTO V_NUNOTA FROM TGFVAR WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = I_SEQ;
                                UPDATE AD_TGFDEP SET STATUSNFE = 'C' WHERE NUNOTA = V_NUNOTA;

                        END IF;
                END IF;
        END IF;

END;