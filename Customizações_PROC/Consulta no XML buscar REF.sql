SELECT *
FROM  XMLTable
        (
          'for $i in $doc/nfeProc/NFe/infNFe/det/descendant-or-self::*
          return if ($i/@nItem="1") then $i/prod/cEAN else()'             
         PASSING 
            (
             SELECT SYS.XMLTYPE.createXML(MDE.XMLEVENTO) FROM TGFMDELOG MDE
	            WHERE MDE.DESCREVENTO = 'Download NF-e' 
		            AND MDE.CHAVEACESSO = (
					    SELECT CHAVENFE FROM TGFCAB WHERE NUNOTA = 176925)
             ) AS "doc"
         COLUMNS 
            REF varchar2(4000) path '.'
         )