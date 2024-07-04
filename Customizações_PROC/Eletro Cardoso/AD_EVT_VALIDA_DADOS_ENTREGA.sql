CREATE OR REPLACE PROCEDURE AD_EVT_VALIDA_DADOS_ENTREGA (
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

    P_SEQUENCIA   INT;
    P_NUNOTA      INT;
    P_CODPROD     INT;
       
BEGIN
    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;


    IF P_TIPOEVENTO = BEFORE_INSERT THEN
        P_NUNOTA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
        P_SEQUENCIA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'SEQUENCIA');
        P_CODPROD := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPROD');
        
        SELECT TIPMOV INTO V_TIPMOV FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT (CASE WHEN CODGRUPOPROD = 134003 THEN 'S' ELSE 'N' END) INTO V_POSTE 
            FROM TGFPRO WHERE CODPROD = P_CODPROD;
        SELECT NVL(NUNOTAORIGEM, 0) INTO V_ORIGEM 
            FROM TGFVAR WHERE NUNOTA = P_NUNOTA AND CODPROD = P_CODPROD AND SEQUENCIA = P_SEQUENCIA;

        IF V_TIPMOV = 'P' THEN
            IF V_POSTE = 'S' THEN
                IF V_ORIGEM > 0 THEN       
                    SELECT COUNT(*) INTO C_COUNT FROM AD_TGFDEP WHERE NUNOTA = V_ORIGEM;
                    IF C_COUNT > 0 THEN
                        INSERT INTO AD_TGFDEP (
                            NUNOTA,
                            ENDERECO,
                            CODPARC,
                            CONTATO,
                            TELEFONE,
                            RESPINSTAL,
                            DTINCLUSAO,
                            USRINCLUSAO,
                            DTENTREGA)
                        SELECT (
                            P_NUNOTA,
                            ENDERECO,
                            CODPARC,
                            CONTATO,
                            TELEFONE,
                            RESPINSTAL,
                            SYSDATE,
                            P_CODUSU,
                            DTENTREGA)
                        FROM AD_TGFDEP WHERE NUNOTA = V_ORIGEM;
                        DELETE FROM AD_TGFDEP WHERE NUNOTA = V_ORIGEM;
                END IF;
            END IF;
        END IF;

    END IF;
    
END;