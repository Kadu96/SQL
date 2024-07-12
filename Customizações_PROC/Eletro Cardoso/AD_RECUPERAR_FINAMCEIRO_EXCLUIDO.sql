CREATE OR REPLACE PROCEDURE "AD_RECUPERAR_FIN_EXCLUIDO" (
    P_CODUSU NUMBER, -- Código do usuário logado
    P_IDSESSAO VARCHAR2, -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER, -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
    FIELD_NUNOTA NUMBER;
    V_NUMNOTA NUMBER;
    V_MSG VARCHAR2(100);

    C_FIN INT := 0;
    C_FIN_EXC INT := 0;

BEGIN
    FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
    LOOP
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        SELECT NUMNOTA INTO V_NUMNOTA
            FROM TGFCAB WHERE NUNOTA = FIELD_NUNOTA;
        
        SELECT COUNT(NUNOTA) INTO C_FIN
            FROM TGFFIN WHERE NUNOTA = FIELD_NUNOTA;
        
        SELECT COUNT(NUNOTA) INTO C_FIN_EXC
            FROM TGFFIN_EXC WHERE NUNOTA = FIELD_NUNOTA;
        
        IF C_FIN > 0 THEN
            V_MSG := 'Financeiro já existe. Por favor, verifique.';
        ELSIF C_FIN_EXC > 0 THEN

            INSERT INTO TGFFIN F
            (F.NUFIN, F.CODEMP, F.NUMNOTA, F.SERIENOTA, F.DTNEG, F.DESDOBRAMENTO, F.DHMOV, F.DTVENCINIC, F.DTVENC, F.CODPARC, F.CODTIPOPER, F.DHTIPOPER, F.CODBCO, 
                F.CODCTABCOINT, F.CODNAT, F.CODCENCUS, F.CODVEND, F.CODTIPTIT, F.NOSSONUM, F.HISTORICO, F.VLRDESDOB, F.DTALTER, F.ORIGEM, F.NUNOTA, F.RECDESP)
            SELECT 
                TE.NUFIN, TE.CODEMP, TE.NUMNOTA, TE.SERIENOTA, TE.DTNEG, TE.DESDOBRAMENTO, TE.DHMOV, TE.DTVENCINIC, TE.DTVENC, TE.CODPARC, TE.CODTIPOPER, TE.DHTIPOPER, TE.CODBCO, 
                TE.CODCTABCOINT, TE.CODNAT, TE.CODCENCUS, TE.CODVEND, TE.CODTIPTIT, TE.NOSSONUM, TE.HISTORICO, TE.VLRDESDOB, TE.DHMOV, TE.ORIGEM, TE.NUNOTA, TE.RECDESP
            FROM TGFFIN_EXC TE 
            WHERE TE.NUFIN = FIELD_NUNOTA AND TE.NUMNOTA = V_NUMNOTA;

            V_MSG := 'Financeiro Excluído Recuperado.';
        ELSE
            V_MSG := 'Não há financeiro excluído para essa nota.';
        END IF;

    END LOOP;

    P_MENSAGEM := V_MSG;
END;