CREATE OR REPLACE PROCEDURE "AD_STP_UPD_TABPRECO2" (
    P_CODUSU NUMBER,        -- Código do usuário logado
    P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
    FIELD_CODPROD NUMBER;
    C_TAB INT := 0;
    V_CODPROD NUMBER;
    V_GRUPOICMS NUMBER;
    V_GRUPOICMS2 NUMBER;
    V_NCM NUMBER;
    V_IDALIQ NUMBER;

BEGIN

    DELETE FROM AD_TGFTABBASE;

    /*ALIMENTA A TABELA INTERMEDIARIA AD_TGFTABBASE COM OS DADOS BASICO DOS PRODUTOS DA TABELA DE PREÇO 2 */

    INSERT INTO AD_TGFTABBASE (SEQUENCIA,CODPROD,GRUPOICMS,GRUPOICMS2,NCM,TOP,VLRUNIT,VLRVENDA,BASEIPI,PERCIPI,VLRIPI)
    WITH TAB_P2 AS (
        SELECT
            ROWNUM AS SEQUENCIA,
            EXC.CODPROD AS CODPROD,
            EXC.VLRVENDA AS VLRVENDA,
            PRO.GRUPOICMS,
            PRO.GRUPOICMS2,
            PRO.NCM,
            1723 AS TOP
    FROM TGFEXC EXC
            INNER JOIN TGFPRO PRO ON PRO.CODPROD = EXC.CODPROD
    WHERE 
            EXC.NUTAB = (SELECT MAX(NUTAB) FROM TGFTAB WHERE CODTAB = 2) AND
            PRO.ATIVO = 'S'
    )
    SELECT
        P2.SEQUENCIA,
        P2.CODPROD,
        P2.GRUPOICMS,
        P2.GRUPOICMS2,
        P2.NCM,
        P2.TOP,
        P2.VLRVENDA AS VLRUNIT,
        PR.VLRVENDA,
        (CASE WHEN P.TEMIPIVENDA = 'S' THEN P2.VLRVENDA ELSE 0 END) AS BASEIPI,
        (CASE WHEN P.TEMIPIVENDA = 'S' THEN NVL(I.PERCENTUAL,0) ELSE 0 END) AS PERCIPI,
        (CASE WHEN P.TEMIPIVENDA = 'S' THEN (P2.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END) AS VLRIPI
    FROM TAB_P2 P2
    INNER JOIN TGFPRO P ON P.CODPROD = P2.CODPROD
    LEFT JOIN AD_TGFTABIPC PR ON PR.CODPROD = P.CODPROD
    LEFT JOIN TGFIPI I ON I.CODIPI = P.CODIPI;

    /*ATUALIZA OS PRODUTOS NA TABELA AD_TGFTABBASE COM O IDALIQICMS*/

    SELECT COUNT(*) INTO C_TAB FROM AD_TGFTABBASE;

    FOR I IN 1..C_TAB
    LOOP
        V_CODPROD := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPROD');
        /*SELECT NVL(GRUPOICMS,'') INTO V_GRUPOICMS FROM AD_TGFTABBASE WHERE CODPROD = FIELD_CODPROD;
        SELECT NVL(GRUPOICMS2,'') INTO V_GRUPOICMS2 FROM AD_TGFTABBASE WHERE CODPROD = FIELD_CODPROD;
        SELECT NVL(NCM,'') INTO V_NCM FROM AD_TGFTABBASE WHERE CODPROD = FIELD_CODPROD;*/
        
        UPDATE AD_TGFTABBASE T
            SET T.ALIQPRIO = (
                WITH TAB_ALIQ AS (
                    SELECT
                        I.IDALIQ, 
                        I.CODTRIB,
                        I.ALIQUOTA,
                        I.ALIQSUBTRIB,
                        I.TIPRESTRICAO, 
                        I.TIPRESTRICAO2, 
                        I.CODRESTRICAO, 
                        I.CODRESTRICAO2,
                        P.PRIORIDADE
                    FROM TGFICM I
                        INNER JOIN TGFPRI P ON I.TIPRESTRICAO = P.TIPRESTRICAO1 AND I.TIPRESTRICAO2 = P.TIPRESTRICAO2 
                    WHERE I.UFORIG = 8 AND I.UFDEST = 8
                ) 
                SELECT MIN(PRIORIDADE) FROM TAB_ALIQ I
                WHERE 
                    (I.CODRESTRICAO = T.GRUPOICMS AND I.CODRESTRICAO2 = 1757) OR
                    (I.CODRESTRICAO = T.NCM AND I.CODRESTRICAO2 = T.GRUPOICMS) OR
                    (I.CODRESTRICAO = 1757 AND I.CODRESTRICAO2 = -1) OR
                    (I.CODRESTRICAO = NVL(T.GRUPOICMS2,'') AND I.CODRESTRICAO2 = T.NCM) OR
                    (I.CODRESTRICAO = NVL(T.GRUPOICMS2,'') AND I.CODRESTRICAO2 = -1) OR
                    (I.CODRESTRICAO = 1757 AND I.CODRESTRICAO2 = 2) OR
                    (I.CODRESTRICAO = -1 AND I.CODRESTRICAO2 = -1))
        WHERE T.CODPROD = V_CODPROD;

        UPDATE AD_TGFTABBASE T
            SET T.IDALIQICMS = (
                WITH TAB_ALIQ AS (
                    SELECT
                            I.IDALIQ, 
                            I.CODTRIB,
                            I.ALIQUOTA,
                            I.ALIQSUBTRIB,
                            I.TIPRESTRICAO, 
                            I.TIPRESTRICAO2, 
                            I.CODRESTRICAO, 
                            I.CODRESTRICAO2,    
                            P.PRIORIDADE
                    FROM TGFICM I, TGFPRI P
                    WHERE I.UFORIG = 8 AND I.UFDEST = 8
                        AND I.TIPRESTRICAO = P.TIPRESTRICAO1
                        AND I.TIPRESTRICAO2 = P.TIPRESTRICAO2
                ) 
                SELECT IDALIQ FROM TAB_ALIQ 
                WHERE 
                    CODRESTRICAO = 
                        (CASE 
                            WHEN T.ALIQPRIO = 604 THEN TO_NUMBER(T.GRUPOICMS)
                            WHEN T.ALIQPRIO = 607 THEN TO_NUMBER(T.NCM)
                            WHEN T.ALIQPRIO = 608 THEN 1757
                            WHEN T.ALIQPRIO = 609 THEN NVL(TO_NUMBER(T.GRUPOICMS2),0)
                            WHEN T.ALIQPRIO = 610 THEN NVL(TO_NUMBER(T.GRUPOICMS2),0)
                            WHEN T.ALIQPRIO = 611 THEN 1757 
                            WHEN T.ALIQPRIO = 612 THEN -1
                        END) AND
                    CODRESTRICAO2 = 
                        (CASE 
                            WHEN T.ALIQPRIO = 604 THEN 1757
                            WHEN T.ALIQPRIO = 607 THEN TO_NUMBER(T.GRUPOICMS)
                            WHEN T.ALIQPRIO = 608 THEN -1
                            WHEN T.ALIQPRIO = 609 THEN TO_NUMBER(T.NCM)
                            WHEN T.ALIQPRIO = 610 THEN -1
                            WHEN T.ALIQPRIO = 611 THEN 2 
                            WHEN T.ALIQPRIO = 612 THEN -1
                        END)
            )
        WHERE T.CODPROD = V_CODPROD;

    END LOOP;

    /*ATUALIZA A TABELA AD_TGFTABBASE COM OS VALORES DE BASESUBST, VLRSUBST, MVA E VLRBASE*/

    UPDATE AD_TGFTABBASE T
    SET
        T.BASESUBST = (
            SELECT 
                (CASE WHEN ICM.ALIQSUBTRIB > 0 THEN (
                    (T.VLRVENDA + 
                        (CASE WHEN P.TEMIPIVENDA = 'S' THEN (T.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END)) * (1 + P.MVAAJUSTADO/100)) 
                    ELSE 0 END)
            FROM TGFPRO P
                LEFT JOIN TGFIPI I ON I.CODIPI = P.CODIPI
                LEFT JOIN TGFICM ICM ON ICM.IDALIQ = T.IDALIQICMS 
                LEFT JOIN TGFPEM PEM ON PEM.CODPROD = P.CODPROD AND PEM.CODEMP = 2
            WHERE P.CODPROD = T.CODPROD
        ),
        T.VLRSUBST = (
            SELECT 
                (CASE WHEN ICM.ALIQSUBTRIB > 0 THEN 
                    (((T.VLRVENDA + (CASE WHEN P.TEMIPIVENDA = 'S' THEN 
                        (T.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END)) * (1 + P.MVAAJUSTADO/100) * ICM.ALIQSUBTRIB/100) - 
                            (T.VLRVENDA * ICM.ALIQUOTA / 100)) ELSE 0 END)
            FROM TGFPRO P
                LEFT JOIN TGFIPI I ON I.CODIPI = P.CODIPI
                LEFT JOIN TGFICM ICM ON ICM.IDALIQ = T.IDALIQICMS 
                LEFT JOIN TGFPEM PEM ON PEM.CODPROD = P.CODPROD AND PEM.CODEMP = 2
            WHERE P.CODPROD = T.CODPROD        
        ),
        T.VLRBASE = (
            SELECT 
                (PR.VLRVENDA/(1+(
                    ((CASE WHEN ICM.ALIQSUBTRIB > 0 THEN 
                        (((T.VLRVENDA + (CASE WHEN P.TEMIPIVENDA = 'S' THEN 
                            (T.VLRVENDA * I.PERCENTUAL / 100) ELSE 0 END)) * (1+P.MVAAJUSTADO/100) * ICM.ALIQSUBTRIB/100) - 
                                (T.VLRVENDA * ICM.ALIQUOTA / 100)) ELSE 0 END)/T.VLRVENDA) +
                    ((CASE WHEN P.TEMIPIVENDA = 'S' THEN NVL(I.PERCENTUAL,0) ELSE 0 END)/100))))
            FROM TGFPRO P
                LEFT JOIN TGFIPI I ON I.CODIPI = P.CODIPI
                LEFT JOIN TGFICM ICM ON ICM.IDALIQ = T.IDALIQICMS 
                LEFT JOIN AD_TGFTABIPC PR ON PR.CODPROD = P.CODPROD
                LEFT JOIN TGFPEM PEM ON PEM.CODPROD = P.CODPROD AND PEM.CODEMP = 2
            WHERE P.CODPROD = T.CODPROD        
        ),
        T.MVA = (SELECT P.MVAAJUSTADO FROM TGFPEM PEM WHERE PEM.CODPROD = T.CODPROD AND PEM.CODEMP = 2) 
            WHERE T.CODPROD > 0;

    /*INSERIR UMA NOVA LINHA NA TABELA DE PREÇO 2*/

    INSERT INTO TGFTAB (NUTAB,CODTAB,DTVIGOR,DTALTER,CODTABORIG,UTILIZADECCUSTO)
       VALUES ((SELECT MAX(NUTAB)+1 FROM TGFTAB),2,SYSDATE-1,SYSDATE,2,'S');

    INSERT INTO TGFEXC (NUTAB,CODPROD,VLRVENDA,TIPO,CODLOCAL)
       SELECT 
              (SELECT MAX(NUTAB) FROM TGFTAB WHERE CODTAB = 2),
              CODPROD,
              VLRBASE,
              'V',
              0
       FROM AD_TGFTABBASE
       WHERE VLRBASE > 0;
    
    P_MENSAGEM := 'Tabela de Preço Atualizada.';

END;