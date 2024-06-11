CREATE OR REPLACE PROCEDURE "AD_STP_ACAO_AGENDADA_01" AS
BEGIN
    UPDATE TGFPAR SET AD_BLOQUEARABRIROS = 'S' WHERE CODPARC IN (
        SELECT DISTINCT
            Parceiro.CODPARC
        FROM
            TGFPAR Parceiro
            INNER JOIN TGFFIN Financeiro ON
                Parceiro.CODPARC = Financeiro.CODPARC
        WHERE
            Parceiro.CLIENTE = 'S' AND
            (
                Parceiro.AD_BLOQUEARABRIROS IS NULL OR
                Parceiro.AD_BLOQUEARABRIROS = 'N'
            ) AND
            Financeiro.PROVISAO = 'N' AND
            Financeiro.RECDESP = 1 AND
            Financeiro.DHBAIXA IS NULL AND
            TRUNC( Financeiro.DTVENC ) < TRUNC( SYSDATE )
    );

    UPDATE TGFPAR SET AD_BLOQUEARABRIROS = 'N' WHERE CODPARC IN (
        SELECT
            Parceiro.CODPARC
        FROM
            TGFPAR Parceiro
        WHERE
            Parceiro.CLIENTE = 'S' AND
            Parceiro.AD_BLOQUEARABRIROS = 'S' AND
            NOT EXISTS (
                SELECT
                    NUFIN
                FROM
                    TGFFIN
                WHERE
                    PROVISAO = 'N' AND
                    RECDESP = 1 AND
                    DHBAIXA IS NULL AND
                    TRUNC( DTVENC ) < TRUNC( SYSDATE ) AND
                    CODPARC = Parceiro.CODPARC
            )
    );
END;