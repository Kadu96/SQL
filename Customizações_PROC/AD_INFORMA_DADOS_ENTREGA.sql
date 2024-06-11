CREATE OR REPLACE PROCEDURE "AD_INFORMA_DADOS_ENTREGA" (
       P_CODUSU NUMBER,        -- Código do usuário logado
       P_IDSESSAO VARCHAR2,    -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
       P_QTDLINHAS NUMBER,     -- Informa a quantidade de registros selecionados no momento da execução.
       P_MENSAGEM OUT VARCHAR2 -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
       PARAM_CONTATO VARCHAR2(4000);
       PARAM_TELEFONE VARCHAR2(4000);
       PARAM_ENDERECO VARCHAR2(4000);
       PARAM_RESPINSTAL VARCHAR2(4000);
       PARAM_DHENTREGA DATE;
       FIELD_NUNOTA NUMBER;
       FIELD_SEQUENCIA NUMBER;
       V_PARCEIRO NUMBER;
       V_USRINSERT VARCHAR2(100);
       V_MSG VARCHAR2(100);
       C_COUNT INT := 0;

BEGIN

       -- Os valores informados pelo formulário de parâmetros, podem ser obtidos com as funções:
       --     ACT_INT_PARAM
       --     ACT_DEC_PARAM
       --     ACT_TXT_PARAM
       --     ACT_DTA_PARAM
       -- Estas funções recebem 2 argumentos:
       --     ID DA SESSÃO - Identificador da execução (Obtido através de P_IDSESSAO))
       --     NOME DO PARAMETRO - Determina qual parametro deve se deseja obter.

       PARAM_CONTATO := ACT_TXT_PARAM(P_IDSESSAO, 'CONTATO');
       PARAM_TELEFONE := ACT_TXT_PARAM(P_IDSESSAO, 'TELEFONE');
       PARAM_ENDERECO := ACT_TXT_PARAM(P_IDSESSAO, 'ENDERECO');
       PARAM_RESPINSTAL := ACT_TXT_PARAM(P_IDSESSAO, 'RESPINSTAL');
       PARAM_DHENTREGA := ACT_DTA_PARAM(P_IDSESSAO, 'DHENTREGA');

       FOR I IN 1..P_QTDLINHAS -- Este loop permite obter o valor de campos dos registros envolvidos na execução.
       LOOP                    -- A variável "I" representa o registro corrente.
           -- Para obter o valor dos campos utilize uma das seguintes funções:
           --     ACT_INT_FIELD (Retorna o valor de um campo tipo NUMÉRICO INTEIRO))
           --     ACT_DEC_FIELD (Retorna o valor de um campo tipo NUMÉRICO DECIMAL))
           --     ACT_TXT_FIELD (Retorna o valor de um campo tipo TEXTO),
           --     ACT_DTA_FIELD (Retorna o valor de um campo tipo DATA)
           -- Estas funções recebem 3 argumentos:
           --     ID DA SESSÃO - Identificador da execução (Obtido através do parâmetro P_IDSESSAO))
           --     NÚMERO DA LINHA - Relativo a qual linha selecionada.
           --     NOME DO CAMPO - Determina qual campo deve ser obtido.
              FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
              FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');

              SELECT CODPARC INTO V_PARCEIRO FROM TGFCAB WHERE NUNOTA = FIELD_NUNOTA;
              SELECT NOMEUSU INTO V_USRINSERT FROM TSIUSU WHERE CODUSU = P_CODUSU;

              SELECT COUNT(*) INTO C_COUNT FROM AD_TGFDEP WHERE NUNOTA = FIELD_NUNOTA;

              IF C_COUNT > 0 THEN
                     V_MSG := 'Já existe dados de entrega informados para essa nota. Verificar.';
              ELSE

                     INSERT INTO AD_TGFDEP (
                            NUNOTA,
                            ENDERECO,
                            CODPARC,
                            CONTATO,
                            TELEFONE,
                            RESPINSTAL,
                            DTINCLUSAO,
                            USRINCLUSAO,
                            DTENTREGA)
                     VALUES (
                            FIELD_NUNOTA,
                            PARAM_ENDERECO,
                            V_PARCEIRO,
                            PARAM_CONTATO,
                            PARAM_TELEFONE,
                            PARAM_RESPINSTAL,
                            SYSDATE,
                            P_CODUSU,
                            PARAM_DHENTREGA);

                     V_MSG := 'Dados para entrega gravados com Sucesso.';
              END IF;

       END LOOP;

       P_MENSAGEM := V_MSG;

END;