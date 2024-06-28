CREATE OR REPLACE PROCEDURE "AD_VALIDA_CODBARRA" (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC)
AS
BEGIN
DECLARE

    V_SEQ INT := 0;
    V_CODBARRAPARC VARCHAR2(4000);
    V_PRODUTO NUMBER;
    V_CODBARRA VARCHAR2(4000);
    T_REFPROD INT := 0;
    V_ATUAL VARCHAR2(1);
    C_PROD INT := 0;
    C_REF INT := 0;
    
    BEGIN

        IF Stp_Get_Atualizando THEN
            RETURN;
        END IF;

        P_SUCESSO := 'S';

        INSERT INTO AD_TGFREF (NITEM, REFERENCIA, CODPROD, REF_PRODUTO, TAM_REFPROD, ATUAL_REF)
        WITH TAB_REF AS (
                SELECT 
                    NITEM AS SEQ_XML, 
                    REF AS REF_XML, 
                    (SELECT CODPROD FROM TGFITE WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = NITEM) AS PROD, 
                    (SELECT NVL(REFERENCIA,0) FROM TGFPRO WHERE CODPROD = (
                        SELECT CODPROD FROM TGFITE WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = NITEM)) AS REF_PROD,
                    (CASE 
                        WHEN REF <> (SELECT NVL(REFERENCIA,0) FROM TGFPRO WHERE CODPROD = (
                        SELECT CODPROD FROM TGFITE WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = NITEM)) AND REF NOT LIKE '%SEM GTIN%' THEN 'S'
                        ELSE 'N'
                    END) AS ATUAL_REF
                FROM  XMLTable
                    (
                    '$doc/nfeProc/NFe/infNFe/det'          
                    PASSING 
                        (
                        SELECT SYS.XMLTYPE.createXML(XML) FROM TGFIXN WHERE NUNOTA = P_NUNOTA 
                        ) AS "doc"
                    COLUMNS 
                        NITEM varchar2(4000) path './@nItem',
                        REF varchar2(4000) path '//prod/cEAN'
                    )
            )
            SELECT
                SEQ_XML,
                REF_XML,
                PROD,
                REF_PROD,
                LENGTH(REF_PROD),
                ATUAL_REF
            FROM TAB_REF;

        SELECT COUNT(*) INTO C_PROD FROM TGFITE WHERE NUNOTA = P_NUNOTA;

        FOR I IN 1 .. C_PROD
        LOOP

            --SELECT NITEM INTO V_SEQ FROM AD_TGFREF WHERE NITEM = I; 
            SELECT REFERENCIA INTO V_CODBARRAPARC FROM AD_TGFREF WHERE NITEM = I; 
            SELECT CODPROD INTO V_PRODUTO FROM AD_TGFREF WHERE NITEM = I; 
            SELECT REF_PRODUTO INTO V_CODBARRA FROM AD_TGFREF WHERE NITEM = I; 
            SELECT TAM_REFPROD INTO T_REFPROD FROM AD_TGFREF WHERE NITEM = I; 
            SELECT ATUAL_REF INTO V_ATUAL FROM AD_TGFREF WHERE NITEM = I;
            SELECT COUNT(CODPROD) INTO C_REF FROM TGFPRO;

            IF V_ATUAL = 'S' THEN
                IF V_CODBARRAPARC NOT LIKE '%SEM GTIN%' THEN
                    IF C_REF = 0 THEN
                        IF T_REFPROD = 13 AND V_CODBARRA NOT LIKE '%SEM GTIN%' THEN
                            UPDATE TGFPRO SET REFERENCIA = V_CODBARRAPARC WHERE CODPROD = V_PRODUTO;
                            INSERT INTO TGFBAR (CODBARRA, CODPROD, DHALTER, CODUSU, CODVOL)
                                SELECT V_CODBARRA, CODPROD, SYSDATE, 0, CODVOL FROM TGFPRO WHERE CODPROD = V_PRODUTO;
                        ELSE
                            UPDATE TGFPRO SET REFERENCIA = V_CODBARRAPARC WHERE CODPROD = V_PRODUTO; 
                        END IF;
                    ELSE
                        UPDATE TGFPRO SET COMPLDESC = ' | ' || V_CODBARRAPARC WHERE CODPROD = V_PRODUTO;
                    END IF;
                END IF;
            END IF;

        END LOOP;

        DELETE FROM AD_TGFREF;

    END;
END;