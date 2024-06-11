CREATE OR REPLACE PROCEDURE "AD_STP_DFX_DESPFIXA" (
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

    P_ID NUMBER;
    P_ATIVO VARCHAR2(1);
    P_NUFIN NUMBER;
    P_NUMNOTA VARCHAR2(100);
    P_VENC DATE;
    P_MES INT := 0;
    P_TEMPO INT := 0;
    P_DTINSERT DATE := SYSDATE;

    V_PARC NUMBER;
    V_EMP NUMBER;
    V_OBS VARCHAR2(4000);
    V_VLR NUMBER;
    V_VENCINI DATE;
    V_VENC DATE;
    V_DHOPER DATE;
    V_DIA INT;
    V_NUMNOTA VARCHAR2(100);
    V_NAT NUMBER;
    V_TOP NUMBER;
    V_PROJ NUMBER;
    V_TIPO VARCHAR2(2);

   
    NEW_TIPO VARCHAR2(4000);
    OLD_TIPO VARCHAR2(4000);
   
    C_DESPFIXA int := 0;

BEGIN

    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;


    IF P_TIPOEVENTO = AFTER_INSERT THEN
        P_ID := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODDESPFIXA');
        UPDATE AD_TGFDFX SET ATIVO = 'S' WHERE CODDESPFIXA = P_ID;

        SELECT ATIVO INTO P_ATIVO FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;

        IF P_ATIVO = 'S' THEN
            SELECT CODPARC INTO V_PARC FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT CODEMP INTO V_EMP FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT NVL(OBSDESP,'') INTO V_OBS FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT VLRDESP INTO V_VLR FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT DTVENCINI INTO V_VENCINI FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT CODNAT INTO V_NAT FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT CODTIPOPER INTO V_TOP FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT CODPROJ INTO V_PROJ FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT TO_CHAR(DTVENCINI, 'YYYYMM') INTO V_NUMNOTA FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT TIPO INTO V_TIPO FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID; 

            SELECT MAX(NUFIN)+1 INTO P_NUFIN FROM TGFFIN;
            SELECT MAX(DHALTER) INTO V_DHOPER FROM TGFTOP WHERE CODTIPOPER = V_TOP;


            INSERT INTO TGFFIN (NUFIN,CODPARC,NUMNOTA,VLRDESDOB,RECDESP,DTNEG,DTVENCINIC,DTVENC,HISTORICO,CODBCO,CODTIPTIT,AD_CODDESPFIXA,AD_DESPFIXA,CODEMP,PROVISAO,CODTIPOPER,DHTIPOPER,DESDOBRAMENTO,CODNAT,DTALTER,DHMOV,CODPROJ)
                VALUES (P_NUFIN,V_PARC,V_NUMNOTA,V_VLR,-1,TO_CHAR(SYSDATE, 'DD/MM/YYYY'),V_VENCINI,TO_CHAR(V_VENCINI, 'DD/MM/YYYY'),V_OBS,1,2,P_ID,'S',V_EMP,'S',V_TOP,V_DHOPER,1,V_NAT,TO_CHAR(SYSDATE, 'DD/MM/YYYY'),SYSDATE,V_PROJ);

            IF V_TIPO = '1' THEN
                P_MES := 12;
                P_TEMPO := 1;
            ELSIF V_TIPO = '2' THEN
                P_MES := 6;
                P_TEMPO := 2;  
            ELSIF V_TIPO = '3' THEN
                P_MES := 4;
                P_TEMPO := 3;
            ELSIF V_TIPO = '6' THEN
                P_MES := 2;
                P_TEMPO := 6;
            ELSIF V_TIPO = '12' THEN
                P_MES := 1;
                P_TEMPO := 12;  
            END IF;

            FOR I IN 2..P_MES
            LOOP
                /*SELECT REPLACE(ADD_MONTHS(DTVENCINI,P_TEMPO),TO_CHAR(ADD_MONTHS(DTVENCINI,I-1),'DD'),TO_CHAR(DTVENCINI,'DD')) INTO V_VENC 
                    FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;*/
                SELECT 
                    (CASE
                        WHEN TO_CHAR((ADD_MONTHS(DTVENCINI,P_TEMPO)), 'MM') = '02' THEN 
                            (CASE 
                                WHEN TO_CHAR(DTVENCINI, 'DD') = '29' THEN
                                    REPLACE(ADD_MONTHS(DTVENCINI,P_TEMPO),TO_CHAR(ADD_MONTHS(DTVENCINI,I-2),'DD'),TO_CHAR(DTVENCINI,'DD'))
                                WHEN TO_CHAR(DTVENCINI, 'DD') = '30' THEN
                                    REPLACE(ADD_MONTHS(DTVENCINI,P_TEMPO),TO_CHAR(ADD_MONTHS(DTVENCINI,I-3),'DD'),TO_CHAR(DTVENCINI,'DD'))
                                WHEN TO_CHAR(DTVENCINI, 'DD') = '31' THEN    
                                    REPLACE(ADD_MONTHS(DTVENCINI,P_TEMPO),TO_CHAR(ADD_MONTHS(DTVENCINI,I-4),'DD'),TO_CHAR(DTVENCINI,'DD'))
                                ELSE REPLACE(ADD_MONTHS(DTVENCINI,P_TEMPO),TO_CHAR(ADD_MONTHS(DTVENCINI,I-1),'DD'),TO_CHAR(DTVENCINI,'DD')) END)
                        ELSE REPLACE(ADD_MONTHS(DTVENCINI,P_TEMPO),TO_CHAR(ADD_MONTHS(DTVENCINI,I-1),'DD'),TO_CHAR(DTVENCINI,'DD')) END) INTO V_VENC 
                    FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;

                SELECT TO_CHAR(V_VENC, 'YYYYMM') INTO P_NUMNOTA FROM DUAL;
                SELECT MAX(NUFIN)+1 INTO P_NUFIN FROM TGFFIN;

                SELECT TO_CHAR(V_VENC, 'D') INTO V_DIA FROM DUAL;

                IF V_DIA = 7 THEN 
                    P_VENC := V_VENC - 1; 
                ELSIF V_DIA = 1 THEN 
                    P_VENC := V_VENC - 2;
                ELSE 
                    P_VENC := V_VENC;
                END IF;

                INSERT INTO TGFFIN (NUFIN,CODPARC,NUMNOTA,VLRDESDOB,RECDESP,DTNEG,DTVENCINIC,DTVENC,HISTORICO,CODBCO,CODTIPTIT,AD_CODDESPFIXA,AD_DESPFIXA,CODEMP,PROVISAO,CODTIPOPER,DHTIPOPER,DESDOBRAMENTO,CODNAT,DTALTER,DHMOV,CODPROJ)
                    VALUES (P_NUFIN,V_PARC,P_NUMNOTA,V_VLR,-1,TO_CHAR(SYSDATE, 'DD/MM/YYYY'),V_VENCINI,TO_CHAR(P_VENC, 'DD/MM/YYYY'),V_OBS,1,2,P_ID,'S',V_EMP,'S',V_TOP,V_DHOPER,I,V_NAT,TO_CHAR(SYSDATE, 'DD/MM/YYYY'),SYSDATE,V_PROJ);

                IF V_TIPO = '1' THEN
                    P_TEMPO := P_TEMPO + 1;
                ELSIF V_TIPO = '2' THEN
                    P_TEMPO := P_TEMPO + 2;  
                ELSIF V_TIPO = '3' THEN
                    P_TEMPO := P_TEMPO + 3;
                ELSIF V_TIPO = '6' THEN
                    P_TEMPO := P_TEMPO + 6;
                ELSIF V_TIPO = '12' THEN
                    P_TEMPO := P_TEMPO + 12;  
                END IF;

            END LOOP;

        END IF;

        UPDATE AD_TGFDFX SET ATIVO = 'S', DESPSTATUS = 'A', USRINSERT = P_CODUSU, DTINSERT = P_DTINSERT, TIPOINSERT = CODEMP||','||TIPO||','||CODPARC||','||DTVENCINI 
            WHERE CODDESPFIXA = P_ID;

    END IF;

/*------------------------------------------------------------------------------------------------------------------------------------------------------*/
    IF P_TIPOEVENTO = BEFORE_DELETE THEN
        P_ID := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODDESPFIXA');
        SELECT COUNT(*) INTO C_DESPFIXA FROM TGFFIN WHERE PROVISAO <> 'S' AND AD_CODDESPFIXA = P_ID AND AD_DESPFIXA = 'S';

        IF C_DESPFIXA > 0 THEN
            raise_application_error(-20101, 'Despesa Fixa não pode ser excluída pois já possuí financeiro real. Caso necessário, usar a opção "Finalizar Despesa" no botão "Ações".');
        ELSE    
            DELETE FROM TGFFIN WHERE PROVISAO = 'S' AND AD_CODDESPFIXA = P_ID AND AD_DESPFIXA = 'S';
        END IF;

    END IF;

/*------------------------------------------------------------------------------------------------------------------------------------------------------*/
    IF P_TIPOEVENTO = BEFORE_UPDATE THEN
        raise_application_error(-20102,'Não é possível atualizar a despesa por esta rotina. Por favor caso necessite alterar algum campo realizar pelo Botão de Ação "Atualizar Despesa"');
    END IF;

/*------------------------------------------------------------------------------------------------------------------------------------------------------*/
    IF P_TIPOEVENTO = AFTER_UPDATE THEN
        P_ID := EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODDESPFIXA');

        SELECT ATIVO INTO P_ATIVO FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;

        IF P_ATIVO = 'S' THEN
            SELECT CODEMP||','||TIPO||','||CODPARC||','||DTVENCINI INTO NEW_TIPO FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;
            SELECT TIPOINSERT INTO OLD_TIPO FROM AD_TGFDFX WHERE CODDESPFIXA = P_ID;

            IF NEW_TIPO <> OLD_TIPO THEN
                raise_application_error(-20102, '"EMPRESA", "TIPO", "PARCEIRO" e "DATA DE VENCIMENTO INICIAL" da Despesa NÃO podem ser Alterados. Caso necessite alterá-los Exclua ou Finalize esta Despesa e lance uma nova com os dados Corretos.');
            END IF;

        END IF;

    END IF;

END;