close all

open data 

ThisView = "scbllist"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW scbllist; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT 	scbllist.Cuid, scbllist.tTimeStamp, scbllist.cjobType, scbllist.cDocNum, scbllist.cCustNo, scbllist.cEnterBy, ;
   				arcust.cCompany, arcust.cEmail, arcust.cFax, arcust.cPdfType, ;
   				CASE 	WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'F' THEN 'Fax Only' ;
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'E' THEN 'Email Only' ;
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'P' THEN 'Print Only' ;	
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'B' THEN 'Email and Fax Only' ;		   					   					
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'V' THEN 'Email and Print Only' ;		   					   						   					
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'Y' THEN 'Print and Fax Only' ;
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'T' THEN 'All Three' ;	  
	   					WHEN LTRIM(RTRIM(arcust.cPdfType)) = 'N' THEN 'None' ;	
	   					ELSE '' ; 	   					 							   					   						   						   					
   				END as cPdfTypeText, ;
   				scbllist.cTableName, ;
   				0 as lSelected ;
 FROM ;
     scbllist scbllist ;
     inner join arcust arcust ;
     	on scbllist.cCustNo = arcust.cCustNo 
* WHERE  sccmiss.cRep = ( ?gcKey1 )

DBSetProp(ThisView,"View","Comment","Email Blast Job List")
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
DBSetProp(ThisView,"View","Tables","sccmiss, arcust")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".cuid","Field","Caption","ID")
DBSetProp(ThisView+".cuid","Field","DataType","C(15)")
DBSetProp(ThisView+".cuid","Field","UpdateName","scbllist.CUID")
DBSetProp(ThisView+".cuid","Field","KeyField",.T.)
DBSetProp(ThisView+".cuid","Field","Updatable",.T.)

DBSetProp(ThisView+".tTimeStamp","Field","Caption","time Stamp")
DBSetProp(ThisView+".tTimeStamp","Field","DataType","T")
DBSetProp(ThisView+".tTimeStamp","Field","UpdateName","scbllist.tTimeStamp")
DBSetProp(ThisView+".tTimeStamp","Field","KeyField",.F.)
DBSetProp(ThisView+".tTimeStamp","Field","Updatable",.T.)

DBSetProp(ThisView+".cjobType","Field","Caption","Job Type")
DBSetProp(ThisView+".cjobType","Field","DataType","C(15)")
DBSetProp(ThisView+".cjobType","Field","UpdateName","scbllist.cjobType")
DBSetProp(ThisView+".cjobType","Field","KeyField",.F.)
DBSetProp(ThisView+".cjobType","Field","Updatable",.T.)

DBSetProp(ThisView+".cDocNum","Field","Caption","Document Number")
DBSetProp(ThisView+".cDocNum","Field","DataType","C(10)")
DBSetProp(ThisView+".cDocNum","Field","UpdateName","scbllist.cDocNum")
DBSetProp(ThisView+".cDocNum","Field","KeyField",.F.)
DBSetProp(ThisView+".cDocNum","Field","Updatable",.T.)

DBSetProp(ThisView+".cCustNo","Field","Caption","Customer Number")
DBSetProp(ThisView+".cCustNo","Field","DataType","C(10)")
DBSetProp(ThisView+".cCustNo","Field","UpdateName","scbllist.cCustNo")
DBSetProp(ThisView+".cCustNo","Field","KeyField",.F.)
DBSetProp(ThisView+".cCustNo","Field","Updatable",.T.)

DBSetProp(ThisView+".cEnterBy","Field","Caption","Entered by")
DBSetProp(ThisView+".cEnterBy","Field","DataType","C(30)")
DBSetProp(ThisView+".cEnterBy","Field","UpdateName","scbllist.cEnterBy")
DBSetProp(ThisView+".cEnterBy","Field","KeyField",.F.)
DBSetProp(ThisView+".cEnterBy","Field","Updatable",.T.)

DBSetProp(ThisView+".cCompany","Field","Caption","Company")
DBSetProp(ThisView+".cCompany","Field","DataType","C(40)")
DBSetProp(ThisView+".cCompany","Field","UpdateName","arcust.cCompany")
DBSetProp(ThisView+".cCompany","Field","KeyField",.F.)
DBSetProp(ThisView+".cCompany","Field","Updatable",.F.)

DBSetProp(ThisView+".cEmail","Field","Caption","Email")
DBSetProp(ThisView+".cEmail","Field","DataType","V(250)")
DBSetProp(ThisView+".cEmail","Field","UpdateName","arcust.cEmail")
DBSetProp(ThisView+".cEmail","Field","KeyField",.F.)
DBSetProp(ThisView+".cEmail","Field","Updatable",.F.)

DBSetProp(ThisView+".cFax","Field","Caption","Fax")
DBSetProp(ThisView+".cFax","Field","DataType","C(20)")
DBSetProp(ThisView+".cFax","Field","UpdateName","arcust.cFax")
DBSetProp(ThisView+".cFax","Field","KeyField",.F.)
DBSetProp(ThisView+".cFax","Field","Updatable",.F.)

DBSetProp(ThisView+".cPdfType","Field","Caption","Pdf Flag")
DBSetProp(ThisView+".cPdfType","Field","DataType","C(1)")
DBSetProp(ThisView+".cPdfType","Field","UpdateName","arcust.cPdfType")
DBSetProp(ThisView+".cPdfType","Field","KeyField",.F.)
DBSetProp(ThisView+".cPdfType","Field","Updatable",.F.)

DBSetProp(ThisView+".cPdfTypeText","Field","Caption","Pdf Flag Descript")
DBSetProp(ThisView+".cPdfTypeText","Field","DataType","C(30)")
DBSetProp(ThisView+".cPdfTypeText","Field","UpdateName","arcust.cPdfType")
DBSetProp(ThisView+".cPdfTypeText","Field","KeyField",.F.)
DBSetProp(ThisView+".cPdfTypeText","Field","Updatable",.F.)

DBSetProp(ThisView+".cTableName","Field","Caption","Cache Table Name")
DBSetProp(ThisView+".cTableName","Field","DataType","C(30)")
DBSetProp(ThisView+".cTableName","Field","UpdateName","scbllist.cTableName")
DBSetProp(ThisView+".cTableName","Field","KeyField",.F.)
DBSetProp(ThisView+".cTableName","Field","Updatable",.T.)

DBSetProp(ThisView+".lSelected","Field","Caption","Record Selected")
DBSetProp(ThisView+".lSelected","Field","DataType","I")
DBSetProp(ThisView+".lSelected","Field","DefaultValue","0")
DBSetProp(ThisView+".lSelected","Field","UpdateName","")
DBSetProp(ThisView+".lSelected","Field","KeyField",.F.)
DBSetProp(ThisView+".lSelected","Field","Updatable",.F.)