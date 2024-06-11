CREATE OR REPLACE PROCEDURE "AD_STP_DFX_FINALIZAR" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       FIELD_CODDESPFIXA NUMBER;
BEGIN


       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP 
       
              FIELD_CODDESPFIXA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODDESPFIXA');
              
              DELETE FROM TGFFIN WHERE PROVISAO = 'S' AND AD_DESPFIXA = 'S' AND AD_CODDESPFIXA = FIELD_CODDESPFIXA;
              UPDATE AD_TGFDFX SET DESPSTATUS = 'F', ATIVO = 'N' WHERE CODDESPFIXA = FIELD_CODDESPFIXA;

       END LOOP;

       P_MENSAGEM := 'Despesa Fixa Finalizada. Provisionamento excluído da Movimentação Financeira.';

END;