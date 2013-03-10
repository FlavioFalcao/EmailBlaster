close all

open data 

ThisView = "scbllog"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW scbllog; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT 	scbllog.cUid, scbllog.tTimeStamp, scbllog.cjobType, scbllog.cPdfType, ;
   				CASE 	WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'F' THEN 'Fax Only' ;
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'E' THEN 'Email Only' ;
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'P' THEN 'Print Only' ;	
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'B' THEN 'Email and Fax Only' ;		   					   					
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'V' THEN 'Email and Print Only' ;		   					   						   					
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'Y' THEN 'Print and Fax Only' ;
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'T' THEN 'All Three' ;	  
	   					WHEN LTRIM(RTRIM(scbllog.cPdfType)) = 'X' THEN 'None' ;	
	   					ELSE '' ; 	   					 							   					   						   						   					
   				END as cPdfTypeText, ;
   				scbllog.cDocNum, scbllog.cCustNo, ; 
				scbllog.cEmail, scbllog.cFax, scbllog.cEnterBy, scbllog.lError, scbllog.lSystem, ;
				scbllog.cTableName, scbllog.mComment, ;
				left (cast(mcomment as varchar (5000)), 250) + CASE WHEN LEN(LTRIM(RTRIM(cast(mcomment as varchar (5000))))) > 250 THEN '...' ELSE '' END as cComment ;
 FROM ;
     scbllog scbllog

DBSetProp(ThisView,"View","Comment","Email Blast Job Log")
DBSetProp(ThisView,"View","SendUpdates",.T.)
DBSetProp(ThisView,"View","BatchUpdateCount",1)
DBSetProp(ThisView,"View","CompareMemo",.T.)
DBSetProp(ThisView,"View","FetchAsNeeded",.F.)
DBSetProp(ThisView,"View","FetchMemo",.F.)
DBSetProp(ThisView,"View","FetchSize",-1)
DBSetProp(ThisView,"View","MaxRecords",-1)
DBSetProp(ThisView,"View","Prepared",.F.)
DBSetProp(ThisView,"View","ShareConnection",.T.)
DBSetProp(ThisView,"View","AllowSimultaneousFetch",.F.)
DBSetProp(ThisView,"View","UpdateType",1)
DBSetProp(ThisView,"View","UseMemoSize",255)
DBSetProp(ThisView,"View","Tables","scbllog")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".cuid","Field","Caption","ID")
DBSetProp(ThisView+".cuid","Field","DataType","C(15)")
DBSetProp(ThisView+".cuid","Field","UpdateName","scbllog.CUID")
DBSetProp(ThisView+".cuid","Field","KeyField",.T.)
DBSetProp(ThisView+".cuid","Field","Updatable",.F.)

DBSetProp(ThisView+".tTimeStamp","Field","Caption","time Stamp")
DBSetProp(ThisView+".tTimeStamp","Field","DataType","T")
DBSetProp(ThisView+".tTimeStamp","Field","UpdateName","scbllog.tTimeStamp")
DBSetProp(ThisView+".tTimeStamp","Field","KeyField",.F.)
DBSetProp(ThisView+".tTimeStamp","Field","Updatable",.F.)

DBSetProp(ThisView+".cjobType","Field","Caption","Job Type")
DBSetProp(ThisView+".cjobType","Field","DataType","C(15)")
DBSetProp(ThisView+".cjobType","Field","UpdateName","scbllog.cjobType")
DBSetProp(ThisView+".cjobType","Field","KeyField",.F.)
DBSetProp(ThisView+".cjobType","Field","Updatable",.F.)

DBSetProp(ThisView+".cPdfType","Field","Caption","PDF Type")
DBSetProp(ThisView+".cPdfType","Field","DataType","C(1)")
DBSetProp(ThisView+".cPdfType","Field","UpdateName","scbllog.cPdfType")
DBSetProp(ThisView+".cPdfType","Field","KeyField",.F.)
DBSetProp(ThisView+".cPdfType","Field","Updatable",.F.)

DBSetProp(ThisView+".cPdfTypeText","Field","Caption","Pdf Flag Descript")
DBSetProp(ThisView+".cPdfTypeText","Field","DataType","C(30)")
DBSetProp(ThisView+".cPdfTypeText","Field","UpdateName","scbllog.cPdfType")
DBSetProp(ThisView+".cPdfTypeText","Field","KeyField",.F.)
DBSetProp(ThisView+".cPdfTypeText","Field","Updatable",.F.)

DBSetProp(ThisView+".cDocNum","Field","Caption","Document Number")
DBSetProp(ThisView+".cDocNum","Field","DataType","C(10)")
DBSetProp(ThisView+".cDocNum","Field","UpdateName","scbllog.cDocNum")
DBSetProp(ThisView+".cDocNum","Field","KeyField",.F.)
DBSetProp(ThisView+".cDocNum","Field","Updatable",.F.)

DBSetProp(ThisView+".cCustNo","Field","Caption","Customer Number")
DBSetProp(ThisView+".cCustNo","Field","DataType","C(10)")
DBSetProp(ThisView+".cCustNo","Field","UpdateName","scbllog.cCustNo")
DBSetProp(ThisView+".cCustNo","Field","KeyField",.F.)
DBSetProp(ThisView+".cCustNo","Field","Updatable",.F.)

DBSetProp(ThisView+".cEmail","Field","Caption","Email")
DBSetProp(ThisView+".cEmail","Field","DataType","C(250)")
DBSetProp(ThisView+".cEmail","Field","UpdateName","scbllog.cEmail")
DBSetProp(ThisView+".cEmail","Field","KeyField",.F.)
DBSetProp(ThisView+".cEmail","Field","Updatable",.F.)

DBSetProp(ThisView+".cFax","Field","Caption","Fax")
DBSetProp(ThisView+".cFax","Field","DataType","C(20)")
DBSetProp(ThisView+".cFax","Field","UpdateName","scbllog.cFax")
DBSetProp(ThisView+".cFax","Field","KeyField",.F.)
DBSetProp(ThisView+".cFax","Field","Updatable",.F.)

DBSetProp(ThisView+".cEnterBy","Field","Caption","Entered By")
DBSetProp(ThisView+".cEnterBy","Field","DataType","C(30)")
DBSetProp(ThisView+".cEnterBy","Field","UpdateName","scbllog.cEnterBy")
DBSetProp(ThisView+".cEnterBy","Field","KeyField",.F.)
DBSetProp(ThisView+".cEnterBy","Field","Updatable",.F.)

DBSetProp(ThisView+".lError","Field","Caption","Is Error")
DBSetProp(ThisView+".lError","Field","DataType","I")
DBSetProp(ThisView+".lError","Field","DefaultValue","0")
DBSetProp(ThisView+".lError","Field","UpdateName","scbllog.lError")
DBSetProp(ThisView+".lError","Field","KeyField",.F.)
DBSetProp(ThisView+".lError","Field","Updatable",.F.)

DBSetProp(ThisView+".lSystem","Field","Caption","Is System Entry")
DBSetProp(ThisView+".lSystem","Field","DataType","I")
DBSetProp(ThisView+".lSystem","Field","DefaultValue","0")
DBSetProp(ThisView+".lSystem","Field","UpdateName","scbllog.lSystem")
DBSetProp(ThisView+".lSystem","Field","KeyField",.F.)
DBSetProp(ThisView+".lSystem","Field","Updatable",.F.)

DBSetProp(ThisView+".cTableName","Field","Caption","Cache Table for this Job")
DBSetProp(ThisView+".cTableName","Field","DataType","C(30)")
DBSetProp(ThisView+".cTableName","Field","UpdateName","scbllog.cTableName")
DBSetProp(ThisView+".cTableName","Field","KeyField",.F.)
DBSetProp(ThisView+".cTableName","Field","Updatable",.F.)

DBSetProp(ThisView+".mComment","Field","Caption","Comment")
DBSetProp(ThisView+".mComment","Field","DataType","M")
DBSetProp(ThisView+".mComment","Field","UpdateName","scbllog.mComment")
DBSetProp(ThisView+".mComment","Field","KeyField",.F.)
DBSetProp(ThisView+".mComment","Field","Updatable",.F.)

DBSetProp(ThisView+".cComment","Field","Caption","Comment")
DBSetProp(ThisView+".cComment","Field","DataType","C(254)")
DBSetProp(ThisView+".cComment","Field","UpdateName","scbllog.cComment")
DBSetProp(ThisView+".cComment","Field","KeyField",.F.)
DBSetProp(ThisView+".cComment","Field","Updatable",.F.)

