CREATE OR REPLACE PROCEDURE "AD_STP_DFX_ATUALIZAR" (
    P_CODUSU NUMBER,        -- Código do usuário logado
    P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
    PARAM_NEWVLRDESP FLOAT;
    PARAM_NEWCODNAT VARCHAR2(4000);
    PARAM_NEWCODTIPOPER VARCHAR2(4000);
    PARAM_NEWCODPROJ VARCHAR2(4000);
    PARAM_NEWOBSDESP VARCHAR2(4000);
    FIELD_CODDESPFIXA NUMBER;

    V_OBS VARCHAR2(4000);
    V_VLR NUMBER;
    V_NAT NUMBER;
    V_TOP NUMBER;
    V_PROJ NUMBER;

    N_OBS VARCHAR2(4000);
    N_VLR NUMBER;
    N_NAT NUMBER;
    N_TOP NUMBER;
    N_PROJ NUMBER;
    N_DHOPER DATE;

    V_TITULO VARCHAR(4000);
    V_MENSAGEM VARCHAR(4000);
    V_INCLUIR BOOLEAN;

BEGIN

    PARAM_NEWVLRDESP := ACT_DEC_PARAM(P_IDSESSAO, 'NEWVLRDESP');
    PARAM_NEWCODNAT := ACT_TXT_PARAM(P_IDSESSAO, 'NEWCODNAT');
    PARAM_NEWCODTIPOPER := ACT_TXT_PARAM(P_IDSESSAO, 'NEWCODTIPOPER');
    PARAM_NEWCODPROJ := ACT_TXT_PARAM(P_IDSESSAO, 'NEWCODPROJ');
    PARAM_NEWOBSDESP := ACT_TXT_PARAM(P_IDSESSAO, 'NEWOBSDESP');

    FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
    LOOP   

        FIELD_CODDESPFIXA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODDESPFIXA');
        
        SELECT NVL(OBSDESP,'') INTO V_OBS FROM AD_TGFDFX WHERE CODDESPFIXA = FIELD_CODDESPFIXA;
        SELECT VLRDESP INTO V_VLR FROM AD_TGFDFX WHERE CODDESPFIXA = FIELD_CODDESPFIXA;
        SELECT CODNAT INTO V_NAT FROM AD_TGFDFX WHERE CODDESPFIXA = FIELD_CODDESPFIXA;
        SELECT CODTIPOPER INTO V_TOP FROM AD_TGFDFX WHERE CODDESPFIXA = FIELD_CODDESPFIXA;
        SELECT CODPROJ INTO V_PROJ FROM AD_TGFDFX WHERE CODDESPFIXA = FIELD_CODDESPFIXA;


        V_TITULO := 'ATENÇÃO!!!';
        V_MENSAGEM := 'Ao confirmar as informações alteradas AQUI serão alteradas nas Provisões pendentes. Deseja Continuar?';
        V_INCLUIR  := ACT_ESCOLHER_SIMNAO(V_TITULO, V_MENSAGEM, P_IDSESSAO, I) = 'S';

        IF V_INCLUIR THEN

            IF PARAM_NEWCODTIPOPER IS NULL THEN
                N_TOP := V_TOP;
            ELSE N_TOP := PARAM_NEWCODTIPOPER;    
            END IF;
            IF PARAM_NEWCODNAT IS NULL THEN
                N_NAT := V_NAT;
            ELSE N_NAT := PARAM_NEWCODNAT;    
            END IF;
            IF PARAM_NEWCODPROJ IS NULL THEN
                N_PROJ := V_PROJ;
            ELSE N_PROJ := PARAM_NEWCODPROJ;    
            END IF;
            IF PARAM_NEWOBSDESP IS NULL THEN
                N_OBS := V_OBS;
            ELSE N_OBS := PARAM_NEWOBSDESP;    
            END IF;
            IF PARAM_NEWVLRDESP IS NULL THEN
                N_VLR := V_VLR;
            ELSE N_VLR := PARAM_NEWVLRDESP;    
            END IF;

            SELECT MAX(DHALTER) INTO N_DHOPER FROM TGFTOP WHERE CODTIPOPER = N_TOP;
            UPDATE TGFFIN SET   
                VLRDESDOB = N_VLR,
                CODNAT = N_NAT,
                CODTIPOPER = N_TOP,
                DHTIPOPER = N_DHOPER,
                CODPROJ = N_PROJ,
                HISTORICO = N_OBS
            WHERE PROVISAO = 'S' AND AD_CODDESPFIXA = FIELD_CODDESPFIXA AND AD_DESPFIXA = 'S';   

            UPDATE AD_TGFDFX SET   
                VLRDESP = N_VLR,
                CODNAT = N_NAT,
                CODTIPOPER = N_TOP,
                CODPROJ = N_PROJ,
                OBSDESP = N_OBS,
                USRALTER = P_CODUSU,
                DTALTER = SYSDATE
            WHERE CODDESPFIXA = FIELD_CODDESPFIXA;

            P_MENSAGEM := 'Provisões Atualizadas com sucesso!!';
        END IF;

    END LOOP;

END;