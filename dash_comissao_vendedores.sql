/*Consulta para o Dashbboard Comissão Vendedores
REGRAS:
    Usuários do Grupo ADM (9) irão ver tudo de todos os vendedores
    Usuários do Grupo Gerente de Vendas (12) irão ver tudo de todos os vendedores que tem o usuário como gerente
    Usuários do Grupo Vendas (7) só irão ver a comissão de suas próprias vendas
*/
SELECT 
    CAB.DTNEG,
    (CASE   
        WHEN CAB.TIPMOV='V' THEN 'V-Venda'
        WHEN CAB.TIPMOV='D' THEN 'D-Devolução' ELSE CAB.TIPMOV END) AS TIPMOV,
    CAB.NUNOTA,
    CAB.NUMNOTA,
    (CASE 
        WHEN CAB.TIPMOV='V' THEN CAB.VLRNOTA
        WHEN CAB.TIPMOV='D' THEN (-1*CAB.VLRNOTA) ELSE CAB.VLRNOTA END) AS VLRNOTA,
    VEN.CODVEND,
    VEN.APELIDO,
    CAB.CODPARC,
    PAR.NOMEPARC,
    PAR.RAZAOSOCIAL,
    COM.VLRCOM AS VLRCOMISSAO,
    CAB.CODTIPOPER,
    OPE.DESCROPER
FROM TGFCOM COM
    INNER JOIN TGFCAB CAB ON CAB.NUNOTA = COM.NUNOTAORIG
    INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
    INNER JOIN TGFVEN VEN ON VEN.CODVEND = COM.CODVEND AND VEN.TIPVEND = 'V'
    INNER JOIN TGFTOP OPE ON CAB.CODTIPOPER = OPE.CODTIPOPER AND OPE.DHALTER = CAB.DHTIPOPER
WHERE 
    CAB.STATUSNOTA='L'
    AND (CAB.DTNEG >=  TO_DATE('01/05/2024','DD/MM/YYYY') AND  CAB.DTNEG <= TO_DATE('31/05/2024','DD/MM/YYYY'))
    AND (
        ((SELECT CODGRUPO FROM TSIUSU WHERE CODUSU = STP_GET_CODUSULOGADO) = 9 AND 
            VEN.CODVEND IN (SELECT CODVEND FROM TGFVEN WHERE CODVEND > 0)) OR
        ((SELECT CODGRUPO FROM TSIUSU WHERE CODUSU = STP_GET_CODUSULOGADO) = 12 AND VEN.CODVEND IN (SELECT CODVEND FROM TGFVEN WHERE CODGER = (
            SELECT CODVEND FROM TSIUSU WHERE CODUSU = STP_GET_CODUSULOGADO))) OR
        ((SELECT CODGRUPO FROM TSIUSU WHERE CODUSU = STP_GET_CODUSULOGADO) = 7 AND VEN.CODVEND IN (SELECT CODVEND FROM TGFVEN WHERE CODVEND = (
            SELECT CODVEND FROM TSIUSU WHERE CODUSU = STP_GET_CODUSULOGADO)))    
        )
    AND (VEN.TIPVEND = 'V')
    AND CAB.TIPMOV IN ('V','D')
ORDER BY CAB.DTNEG,CAB.CODPARC