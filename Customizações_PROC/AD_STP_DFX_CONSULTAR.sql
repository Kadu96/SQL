CREATE OR REPLACE PROCEDURE "AD_STP_DFX_CONSULTAR" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       FIELD_CODDESPFIXA NUMBER;
       V_QDT INT := 0;
       V_TITULOS VARCHAR2(4000);
BEGIN

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP  

              FIELD_CODDESPFIXA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODDESPFIXA');
              SELECT COUNT(*) INTO V_QDT FROM TGFFIN WHERE PROVISAO = 'S' AND AD_CODDESPFIXA = FIELD_CODDESPFIXA;
              SELECT LISTAGG(NUFIN, ',') WITHIN GROUP (ORDER BY NUFIN) INTO V_TITULOS FROM TGFFIN WHERE PROVISAO = 'S' AND AD_CODDESPFIXA = FIELD_CODDESPFIXA;
       END LOOP;

       P_MENSAGEM := 'Esta Despesa possui ' || V_QDT || ' Provisão(ões) restantes. Segue a lista de NUFIN: ' || V_TITULOS;
END;