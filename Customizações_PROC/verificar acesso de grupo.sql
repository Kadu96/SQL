SELECT ACESSO.CODUSU,
    ACESSO.NOMEUSU,
    ACESSO.NOMEGRUPO,
    ACESSO.CODGRUPO,
    ACESSO.IDACESSO,
    ACESSO.PATH,
    CASE
        WHEN ACESSO.ACESSO_USU IS NULL THEN 'NÃO'
        ELSE 'SIM'
    END ACESSO_USU,
    CASE
        WHEN ACESSO.ACESSO_GRU IS NULL THEN 'NÃO'
        ELSE 'SIM'
    END ACESSO_GRU,
    (
        SELECT CASE
                WHEN COUNT(1) > 0 THEN 'SIM'
                ELSE 'NÃO'
            END
        FROM TRDPCO P,
            TSIBTA BTA
        WHERE P.VALOR = BTA.NOMEINSTANCIA
            AND NOME = 'entityName'
            AND P.NUCONTROLE = ACESSO.NUCONTROLE
    ) OUTROS_ACESSOS
FROM (
        SELECT USU.CODUSU,
            USU.NOMEUSU,
            CON.NUCONTROLE,
            GRU.NOMEGRUPO,
            GRU.CODGRUPO,
            PER.IDACESSO,
            MONTA_PATH_CONTROLE(CON.NUCONTROLE, NULL) AS PATH,
            MAX(
                CASE
                    WHEN PER.CODUSU > 0 THEN PER.ACESSO
                    ELSE NULL
                END
            ) ACESSO_USU,
            MAX(
                CASE
                    WHEN PER.CODGRUPO > 0 THEN PER.ACESSO
                    ELSE NULL
                END
            ) ACESSO_GRU
        FROM TDDPER PER,
            TSIUSU USU,
            TSIGRU GRU,
            (
                SELECT C.DESCRCONTROLE,
                    C.NUCONTROLE,
                    CAST(P.VALOR AS VARCHAR(100)) RESOURCEID
                FROM TRDCON C,
                    TRDPCO P
                WHERE C.TIPOCONTROLE = 'MN'
                    AND P.NUCONTROLE = C.NUCONTROLE
                    AND P.NOME = 'resourceID'
                    AND C.NUCONTROLE = (
                        SELECT MAX(C2.NUCONTROLE)
                        FROM TRDCON C2
                        WHERE C2.TIPOCONTROLE = 'MN'
                            AND EXISTS(
                                SELECT 1
                                FROM TRDPCO P2
                                WHERE P2.NUCONTROLE = C2.NUCONTROLE
                                    AND P2.NOME = 'resourceID'
                                    AND CAST(P2.VALOR AS VARCHAR(100)) = CAST(P.VALOR AS VARCHAR(100))
                                    AND EXISTS(
                                        SELECT 1
                                        FROM TRDFCO FCO
                                        WHERE C2.NUCONTROLE = FCO.NUCONTROLEFILHO
                                    )
                            )
                    )
            ) CON
        WHERE CON.RESOURCEID = PER.IDACESSO
            AND GRU.CODGRUPO = USU.CODGRUPO
            AND (
                (
                    PER.CODGRUPO > 0
                    AND PER.CODGRUPO = GRU.CODGRUPO
                )
                OR (
                    PER.CODUSU > 0
                    AND PER.CODUSU = USU.CODUSU
                )
            )
        GROUP BY USU.CODUSU,
            USU.NOMEUSU,
            GRU.NOMEGRUPO,
            GRU.CODGRUPO,
            PER.IDACESSO,
            CON.DESCRCONTROLE,
            CON.NUCONTROLE
    ) ACESSO
WHERE NVL(:GERADASH, 'N') = 'S'
    AND (
        (:CODUSU IS NULL)
        OR (CODUSU = :CODUSU)
    )
    AND (
        (:CODGRUPO IS NULL)
        OR (CODGRUPO = :CODGRUPO)
    )
    AND (
        (:CAMINHO IS NULL)
        OR (UPPER(PATH) LIKE '%' || :CAMINHO || '%')
    )
ORDER BY ACESSO.PATH,
    ACESSO.NOMEUSU