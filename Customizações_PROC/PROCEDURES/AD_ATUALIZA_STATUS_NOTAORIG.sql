CREATE OR REPLACE PROCEDURE TESTE."AD_ATUALIZA_STATUS_NOTAORIG" (
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
 		V_NOTAORIG NUMBER;
      	V_TOP NUMBER;
		V_STATUSNOTA VARCHAR2(1);
		V_STATUS VARCHAR2(1);
      
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
		SELECT AD_STATUS INTO V_STATUS FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
		SELECT CODTIPOPER INTO V_TOP FROM TGFCAB WHERE NUNOTA = P_NUNOTA;
		SELECT STATUSNOTA INTO V_STATUSNOTA FROM TGFCAB WHERE NUNOTA = P_NUNOTA;

		IF V_TOP = 2006 OR V_TOP = 2003 OR V_TOP = 2013 OR V_TOP = 2012 OR V_TOP = 2026 THEN --Instalação em andamento	
			SELECT DISTINCT NUNOTAORIG INTO V_NOTAORIG FROM TGFVAR WHERE NUNOTA = P_NUNOTA;
			IF V_STATUSNOTA = 'A' THEN	
				UPDATE TGFCAB SET AD_STATUS = V_STATUS WHERE NUNOTA = V_NOTAORIG;
		   	END IF;

		END IF;
	
	END IF;

END;