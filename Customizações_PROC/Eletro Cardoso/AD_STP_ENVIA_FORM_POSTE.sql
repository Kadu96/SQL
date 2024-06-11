CREATE OR REPLACE PROCEDURE "AD_STP_ENVIA_FORM_POSTE" (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC)
AS
BEGIN
DECLARE

    P_ASSUNTO VARCHAR2(4000);
    P_TXTEMAIL VARCHAR2(4000);
    P_EMAIL01 VARCHAR2(4000);
    P_EMAIL02 VARCHAR2(4000);
    P_EMAIL03 VARCHAR2(4000);

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

        IF Stp_Get_Atualizando THEN
            RETURN;
        END IF;

        P_SUCESSO := 'S';

        SELECT STATUSNOTA INTO V_STATUSNOTA FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT STATUSNFE INTO V_STATUSNFE FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT TIPMOV INTO V_TIPMOV FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT COUNT(CODPROD) INTO C_POSTE FROM TGFITE 
        WHERE NUNOTA = P_NUNOTA AND
            CODPROD  IN (
                SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
        
        IF C_POSTE > 0 THEN
            IF V_TIPMOV = 'V' THEN 

                SELECT NUMNOTA INTO V_NUMNOTA FROM TGFCAB WHERE NUNOTA = P_NUNOTA;

                P_ASSUNTO := 'Entrega de Poste ' || ' ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY');
                P_TXTEMAIL := 'Segue em anexo Formulário de Entrega de Poste';

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO, PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(
                    190, 
                    (SELECT NVL(MAX(SEQUENCIA),0)+1 FROM TSIARF WHERE NURFE = 190), 
                    SYSDATE, 
                    '31/12/2050', '<agendamento nuRfe="190" sequencia="8"><hora horas="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'HH') FROM DUAL)||'" min="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'MI') FROM DUAL)||'" /><dias todoDia="true" /><meses todosMeses="true" /><sql>SELECT ''eletrocardoso@eletrocardoso.com.br'' AS EMAIL, '|| P_NUNOTA ||' AS PK_NUNOTA FROM DUAL</sql><camposObrigatorios><parametro classe="java.math.BigDecimal" descricao="PK_NUNOTA" nome="PK_NUNOTA" pesquisa="false" requerido="false" /></camposObrigatorios></agendamento>', 
                    SYSDATE + 10/1440, 'S', P_ASSUNTO, '<EMAIL><ASSUNTO>'||P_ASSUNTO||'</ASSUNTO><MSG>'||P_TXTEMAIL||'</MSG></EMAIL>',3); 
                
                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO, PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(
                    3, 
                    (SELECT NVL(MAX(SEQUENCIA),0)+1 FROM TSIARF WHERE NURFE = 190), 
                    SYSDATE, 
                    '31/12/2050', '<agendamento nuRfe="3" sequencia="8"><hora horas="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'HH') FROM DUAL)||'" min="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'MI') FROM DUAL)||'" /><dias todoDia="true" /><meses todosMeses="true" /><sql>SELECT ''eletrocardoso@eletrocardoso.com.br'' AS EMAIL, '|| P_NUNOTA ||' AS NUNOTA FROM DUAL</sql><camposObrigatorios><parametro classe="java.math.BigDecimal" descricao="PK_NUNOTA" nome="PK_NUNOTA" pesquisa="false" requerido="false" /></camposObrigatorios></agendamento>', 
                    SYSDATE + 10/1440, 'S', P_ASSUNTO, '<EMAIL><ASSUNTO>'||P_ASSUNTO||'</ASSUNTO><MSG>'||P_TXTEMAIL||'</MSG></EMAIL>',3); 

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO, PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(
                    190, 
                    (SELECT NVL(MAX(SEQUENCIA),0)+1 FROM TSIARF WHERE NURFE = 190), 
                    SYSDATE, 
                    '31/12/2050', '<agendamento nuRfe="190" sequencia="8"><hora horas="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'HH') FROM DUAL)||'" min="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'MI') FROM DUAL)||'" /><dias todoDia="true" /><meses todosMeses="true" /><sql>SELECT ''everaldo@eletrocardoso.com.br'' AS EMAIL, '|| P_NUNOTA ||' AS PK_NUNOTA FROM DUAL</sql><camposObrigatorios><parametro classe="java.math.BigDecimal" descricao="PK_NUNOTA" nome="PK_NUNOTA" pesquisa="false" requerido="false" /></camposObrigatorios></agendamento>', 
                    SYSDATE + 10/1440, 'S', P_ASSUNTO, '<EMAIL><ASSUNTO>'||P_ASSUNTO||'</ASSUNTO><MSG>'||P_TXTEMAIL||'</MSG></EMAIL>',3);
                
                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO, PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(
                    3, 
                    (SELECT NVL(MAX(SEQUENCIA),0)+1 FROM TSIARF WHERE NURFE = 190), 
                    SYSDATE, 
                    '31/12/2050', '<agendamento nuRfe="3" sequencia="8"><hora horas="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'HH') FROM DUAL)||'" min="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'MI') FROM DUAL)||'" /><dias todoDia="true" /><meses todosMeses="true" /><sql>SELECT ''everaldo@eletrocardoso.com.br'' AS EMAIL, '|| P_NUNOTA ||' AS NUNOTA FROM DUAL</sql><camposObrigatorios><parametro classe="java.math.BigDecimal" descricao="PK_NUNOTA" nome="PK_NUNOTA" pesquisa="false" requerido="false" /></camposObrigatorios></agendamento>', 
                    SYSDATE + 10/1440, 'S', P_ASSUNTO, '<EMAIL><ASSUNTO>'||P_ASSUNTO||'</ASSUNTO><MSG>'||P_TXTEMAIL||'</MSG></EMAIL>',3);

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO, PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(
                    190, 
                    (SELECT NVL(MAX(SEQUENCIA),0)+1 FROM TSIARF WHERE NURFE = 190), 
                    SYSDATE, 
                    '31/12/2050', '<agendamento nuRfe="190" sequencia="8"><hora horas="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'HH') FROM DUAL)||'" min="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'MI') FROM DUAL)||'" /><dias todoDia="true" /><meses todosMeses="true" /><sql>SELECT ''beatris@eletrocardoso.com.br'' AS EMAIL, '|| P_NUNOTA ||' AS PK_NUNOTA FROM DUAL</sql><camposObrigatorios><parametro classe="java.math.BigDecimal" descricao="PK_NUNOTA" nome="PK_NUNOTA" pesquisa="false" requerido="false" /></camposObrigatorios></agendamento>', 
                    SYSDATE + 10/1440, 'S', P_ASSUNTO, '<EMAIL><ASSUNTO>'||P_ASSUNTO||'</ASSUNTO><MSG>'||P_TXTEMAIL||'</MSG></EMAIL>',3);  

                INSERT INTO TSIARF (NURFE, SEQUENCIA, DHINI, DHFIM, AGENDAMENTO, PROXEXEC, EXECUNICA, DESCRICAO, EMAILMANUAL,CODSMTP)
                VALUES(
                    3, 
                    (SELECT NVL(MAX(SEQUENCIA),0)+1 FROM TSIARF WHERE NURFE = 190), 
                    SYSDATE, 
                    '31/12/2050', '<agendamento nuRfe="3" sequencia="8"><hora horas="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'HH') FROM DUAL)||'" min="'||(SELECT TO_CHAR(SYSDATE + 10/1440,'MI') FROM DUAL)||'" /><dias todoDia="true" /><meses todosMeses="true" /><sql>SELECT ''beatris@eletrocardoso.com.br'' AS EMAIL, '|| P_NUNOTA ||' AS NUNOTA FROM DUAL</sql><camposObrigatorios><parametro classe="java.math.BigDecimal" descricao="PK_NUNOTA" nome="PK_NUNOTA" pesquisa="false" requerido="false" /></camposObrigatorios></agendamento>', 
                    SYSDATE + 10/1440, 'S', P_ASSUNTO, '<EMAIL><ASSUNTO>'||P_ASSUNTO||'</ASSUNTO><MSG>'||P_TXTEMAIL||'</MSG></EMAIL>',3); 

                SELECT SEQUENCIA INTO I_SEQ FROM TGFITE 
                    WHERE NUNOTA = P_NUNOTA AND CODPROD  IN (
                        SELECT CODPROD FROM TGFPRO WHERE CODGRUPOPROD = 134003);
                SELECT NUNOTAORIG INTO V_NUNOTA FROM TGFVAR WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = I_SEQ;
                UPDATE AD_TGFDEP SET NRONOTA = P_NUNOTA, STATUSNFE = 'A' WHERE NUNOTA = V_NUNOTA; 
            END IF;

            IF V_TIPMOV = 'D' THEN 

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
        
    END;
END;
	