CREATE OR REPLACE PROCEDURE "AD_VALIDA_VENDEDOR_DEV" (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC)
AS
BEGIN
DECLARE
  
  V_VENDEDOR NUMBER;
  V_VENDDEV NUMBER;
  V_NOTAORIG NUMBER;
  V_VENDSTATUS VARCHAR2(1);
  V_TIPMOV VARCHAR2(1);

  BEGIN

    IF Stp_Get_Atualizando THEN
        RETURN;
    END IF;

    P_SUCESSO := 'S';

    SELECT TIPMOV INTO V_TIPMOV FROM TGFCAB WHERE NUNOTA = P_NUNOTA;

    IF V_TIPMOV = 'D' THEN

      SELECT CODVEND INTO V_VENDDEV FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
      SELECT DISTINCT NUNOTAORIG INTO V_NOTAORIG FROM TGFVAR WHERE NUNOTA = P_NUNOTA;
      SELECT CODVEND INTO V_VENDEDOR FROM TGFCAB WHERE NUNOTA = V_NOTAORIG;
      SELECT ATIVO INTO V_VENDSTATUS FROM TGFVEN WHERE CODVEND = V_VENDEDOR;      

      IF V_VENDSTATUS <> 'S' THEN
        IF V_VENDDEV <> 999 THEN
          P_SUCESSO := 'N';
          P_MENSAGEM := 'Vendedor ' || V_VENDEDOR || ' da Nota de Origem N° Único ' || V_NOTAORIG || ' não está Ativo. Por favor informar o Código 999 para Vendedor desta Devolução.';
        END IF;
      ELSE
        IF V_VENDDEV = 999 THEN
          P_SUCESSO := 'N';
          P_MENSAGEM := 'Vendedor ' || V_VENDEDOR || ' da Nota de Origem N° Único ' || V_NOTAORIG || ' está Ativo. Não pode ser usado Vendedor 999 na Nota de Devolução. Por favor, informar o Código do Vendedor da Nota de Origem.';
        END IF;
      END IF;
    END IF;
  END;
END;