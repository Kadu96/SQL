CREATE OR REPLACE PROCEDURE "AD_STP_ENVIA_FORM_POSTE" (
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
    I_SEQP INT;
    
    V_STATUSNOTA VARCHAR2(1);
    V_STATUSNFE VARCHAR2(1);
    V_NUMNOTA NUMBER;
    V_NUNOTA NUMBER;
    V_CODFILA INT;
    V_TIPMOV VARCHAR2(2);
    V_PEDIDO NUMBER;


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
        SELECT STATUSNOTA INTO V_STATUSNOTA FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT STATUSNFE INTO V_STATUSNFE FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT TIPMOV INTO V_TIPMOV FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT COUNT(CODPROD) INTO C_POSTE FROM TGFITE 
        WHERE NUNOTA = P_NUNOTA AND
            CODPROD  IN (
                SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
        
        IF C_POSTE > 0 THEN
            IF V_TIPMOV = 'V' AND V_STATUSNFE = 'A' AND V_STATUSNOTA = 'L' THEN

                SELECT NUMNOTA INTO V_NUMNOTA FROM TGFCAB WHERE NUNOTA = P_NUNOTA;

                P_ASSUNTO := 'Entrega de Poste NF-e ' || V_NUMNOTA || ' ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY');
                P_TXTEMAIL := 'Segue em anexo Formulário de Entrega de Poste referente a NF-e ' || V_NUMNOTA;
                P_EMAIL01 := 'everaldo@eletrocardoso.com.br';
                P_EMAIL02 := 'beatris@eletrocardoso.com.br';
                P_EMAIL03 := 'eletrocardoso@eletrocardoso.com.br';

                P_XMLAGEND01 := ''
                || ''
                || 'SELECT '''
                || P_EMAIL01 
                || ''' AS EMAIL,'''
                || P_NUNOTA || ''' AS PK_NUNOTA FROM DUAL'
                || '';

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO,
                    PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(190, 1, SYSDATE, '31/12/2050', P_XMLAGEND01,
                    SYSDATE, 'S', 'Relatorio de Entrega de Poste', P_TXTEMAIL,3); 

                P_XMLAGEND02 := ''
                || ''
                || 'SELECT '''
                || P_EMAIL02 
                || ''' AS EMAIL,'''
                || P_NUNOTA || ''' AS PK_NUNOTA FROM DUAL'
                || '';

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO,
                    PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(190, 2, SYSDATE, '31/12/2050', P_XMLAGEND02,
                    SYSDATE, 'S', 'Relatorio de Entrega de Poste', P_TXTEMAIL,3);

                P_XMLAGEND03 := ''
                || ''
                || 'SELECT '''
                || P_EMAIL03 
                || ''' AS EMAIL,'''
                || P_NUNOTA || ''' AS PK_NUNOTA FROM DUAL'
                || '';

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO,
                    PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(190, 3, SYSDATE, '31/12/2050', P_XMLAGEND03,
                    SYSDATE, 'S', 'Relatorio de Entrega de Poste', P_TXTEMAIL,3);  

                SELECT SEQUENCIA INTO I_SEQ FROM TGFITE 
                    WHERE NUNOTA = P_NUNOTA AND CODPROD  IN (
                        SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
                SELECT NUNOTAORIG INTO V_NUNOTA FROM TGFVAR WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = I_SEQ;
                UPDATE AD_TGFDEP SET NRONOTA = P_NUNOTA, STATUSNFE = 'A' WHERE NUNOTA = V_NUNOTA; 

            END IF;

            IF V_TIPMOV = 'D' AND V_STATUSNFE = 'A' AND V_STATUSNOTA = 'L' THEN

                SELECT SEQUENCIA INTO I_SEQ FROM TGFITE 
                    WHERE NUNOTA = P_NUNOTA AND CODPROD  IN (
                        SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
                SELECT NUNOTAORIG INTO V_NUNOTA FROM TGFVAR WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = I_SEQ;
                SELECT NUMNOTA INTO V_NUMNOTA FROM TGFCAB WHERE NUNOTA = V_NUNOTA;

                P_ASSUNTO := 'CANCELAMENTO - Entrega de Poste NF-e ' || V_NUMNOTA;
                P_TXTEMAIL := 'NF-e ' || V_NUMNOTA || 'Devolvida. Entrega de Poste Cancelada.';
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

                SELECT SEQUENCIA INTO I_SEQP FROM TGFITE 
                    WHERE NUNOTA = V_NUNOTA AND CODPROD  IN (
                        SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
                SELECT NUNOTAORIG INTO V_PEDIDO FROM TGFVAR WHERE NUNOTA = V_NUNOTA AND SEQUENCIA = I_SEQP;
                UPDATE AD_TGFDEP SET STATUSNFE = 'D' WHERE NUNOTA = V_PEDIDO; 

            END IF;
        END IF;
    END IF;

END;