CREATE OR REPLACE PROCEDURE TESTE."AD_ATUALIZA_STATUS_INSERCAO" (
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
      	
      	P_NUNOTA NUMBER;
      	V_TOP NUMBER;
		V_STATUSNOTA VARCHAR2(1);
        V_PEDORIG NUMBER;

        C_NROITENS INT;
        C_PEDIDO INT;
       
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;
       
/*******************************************************************************
   É possível obter o valor dos campos através das Functions:
   
  EVP_GET_CAMPO_DTA(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS DE DATA
  EVP_GET_CAMPO_INT(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS NUMÉRICOS INTEIROS
  EVP_GET_CAMPO_DEC(P_IDSESSAO, 'NOMECAMPO') -- PARA CAMPOS NUMÉRICOS DECIMAIS
  EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'NOMECAMPO')   -- PARA CAMPOS TEXTO
  
  O primeiro argumento é uma chave para esta execução. O segundo é o nome do campo.
  
  Para os eventos BEFORE UPDATE, BEFORE INSERT e AFTER DELETE todos os campos estarão disponíveis.
  Para os demais, somente os campos que pertencem à PK
  
  * Os campos CLOB/TEXT serão enviados convertidos para VARCHAR(4000)
  
  Também é possível alterar o valor de um campo através das Stored procedures:
  
  EVP_SET_CAMPO_DTA(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UMA DATA
  EVP_SET_CAMPO_INT(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UM NÚMERO INTEIRO
  EVP_SET_CAMPO_DEC(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UM NÚMERO DECIMAL
  EVP_SET_CAMPO_TEXTO(P_IDSESSAO,  'NOMECAMPO', VALOR) -- VALOR DEVE SER UM TEXTO
********************************************************************************/

	IF P_TIPOEVENTO = AFTER_INSERT THEN
		P_NUNOTA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');
		SELECT CODTIPOPER INTO V_TOP FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
		SELECT STATUSNOTA INTO V_STATUSNOTA FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
        SELECT COUNT(CODPROD) INTO C_NROITENS FROM TGFITE WHERE NUNOTA = P_NUNOTA;
       
		IF V_TOP = 2000 OR V_TOP = 2005 THEN --Aguardando Liberação Financeira	
			IF V_STATUSNOTA = 'A' THEN	
				UPDATE TGFCAB SET AD_STATUS = '1' WHERE NUNOTA = P_NUNOTA;
			
				INSERT INTO TSIAVI (NUAVISO, TITULO, DESCRICAO, SOLUCAO, IDENTIFICADOR, IMPORTANCIA, CODUSU, CODGRUPO, TIPO, DHCRIACAO, CODUSUREMETENTE, NUAVISOPAI, DTEXPIRACAO, DTNOTIFICACAO, ORDEM) 
				VALUES((SELECT MAX(NUAVISO)+1 FROM TSIAVI), 'NOTIFICAÇÃO ORÇAMENTO', 'ORÇAMENTO NRO: ' || P_NUNOTA || 'AGUARDANDO LIBERAÇÃO FINANCEIRA', '', 'PERSONALIZADO', 3 , 38, NULL, 'P' , SYSDATE , 1 , NULL, '', '', NULL);
		   	END IF;

		END IF;
	
		IF V_TOP = 2006 THEN --Instalação em andamento	
			IF V_STATUSNOTA = 'A' THEN	
				UPDATE TGFCAB SET AD_STATUS = '3' WHERE NUNOTA = P_NUNOTA;

		   	END IF;

		END IF;
	
	END IF;

END;