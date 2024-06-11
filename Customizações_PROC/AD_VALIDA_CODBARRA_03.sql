CREATE OR REPLACE PROCEDURE "AD_VALIDA_CODBARRA" (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC)
AS
BEGIN
DECLARE

    V_CODBARRAPARC VARCHAR2(100);
    V_CODBARRA VARCHAR2(100);
    C_PROD INT := 0;
    V_PRODUTO NUMBER;
    V_TITULO VARCHAR2(100);
    V_MENSAGEM VARCHAR2(4000);
    V_CONFIRMA VARCHAR2(1);
    
    BEGIN

        IF Stp_Get_Atualizando THEN
            RETURN;
        END IF;

        P_SUCESSO := 'S';

        INSERT INTO AD_TGFREF (NITEM, REFERENCIA)
        WITH TAB_REF AS (
            SELECT 
                NITEM AS SEQ_XML, 
                REF AS REF_XML
            FROM  XMLTable
                (
                '$doc/nfeProc/NFe/infNFe/det'          
                PASSING 
                    (
                    SELECT SYS.XMLTYPE.createXML(MDE.XMLEVENTO) FROM TGFMDELOG MDE
                        WHERE MDE.DESCREVENTO = 'Download NF-e' 
                            AND MDE.CHAVEACESSO = (
                                SELECT CHAVENFE FROM TGFCAB WHERE NUNOTA = P_NUNOTA)
                    ) AS "doc"
                COLUMNS 
                    NITEM varchar2(4000) path './@nItem',
                    REF varchar2(4000) path '//prod/cEAN'
                )
        )
        SELECT
            SEQ_XML,
            REF_XML
        FROM TAB_REF;

        SELECT 
            COUNT(*) INTO C_PROD FROM AD_TGFREF;

        FOR I IN 1 .. C_PROD
        LOOP
            SELECT REFERENCIA INTO V_CODBARRAPARC FROM AD_TGFREF WHERE NITEM = I;
            SELECT CODPROD INTO V_PRODUTO FROM TGFITE WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = I;
            SELECT 
                LENGTH(REFERENCIA) INTO T_REF, 
                CODVOL INTO V_CODVOL,
                REFERENCIA INTO V_CODBARRA
            FROM TGFPRO WHERE CODPROD = V_PRODUTO; 

            IF TRIM(T_REF) = 13 THEN
                INSERT INTO TGFBAR (CODBARRA, CODPROD, DHALTER, CODUSU, CODVOL)
                SELECT REFERENCIA, CODPROD, SYSDATE, 0, CODVOL
                FROM TGFPRO WHERE CODPROD IN (
                    SELECT PROD FROM TAB_REF WHERE SEQ_XML = I);
            END IF;

        END LOOP;

    END;
END;