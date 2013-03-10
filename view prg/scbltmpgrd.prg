close all

open data 

ThisView = "scblTmpGrd"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW scblTmpGrd; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT 	scblTmpGrd.cuid, scblTmpGrd.cJobType, scblTmpGrd.cEmlCode,  scblTmpGrd.cFaxCode;
 FROM ;
     scblTmpGrd scblTmpGrd 

DBSetProp(ThisView,"View","Comment","Email and Fax Template Conditional Grid")
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
DBSetProp(ThisView,"View","Tables","scblTmpGrd")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".cuid","Field","Caption","ID")
DBSetProp(ThisView+".cuid","Field","DataType","C(15)")
DBSetProp(ThisView+".cuid","Field","UpdateName","scblTmpGrd.CUID")
DBSetProp(ThisView+".cuid","Field","KeyField",.T.)
DBSetProp(ThisView+".cuid","Field","Updatable",.T.)

DBSetProp(ThisView+".cJobType","Field","Caption","Job Type")
DBSetProp(ThisView+".cJobType","Field","DataType","C(10)")
DBSetProp(ThisView+".cJobType","Field","UpdateName","scblTmpGrd.cJobType")
DBSetProp(ThisView+".cJobType","Field","KeyField",.F.)
DBSetProp(ThisView+".cJobType","Field","Updatable",.T.)

DBSetProp(ThisView+".cEmlCode","Field","Caption","Email Template")
DBSetProp(ThisView+".cEmlCode","Field","DataType","C(10)")
DBSetProp(ThisView+".cEmlCode","Field","UpdateName","scblTmpGrd.cEmlCode")
DBSetProp(ThisView+".cEmlCode","Field","KeyField",.F.)
DBSetProp(ThisView+".cEmlCode","Field","Updatable",.T.)

DBSetProp(ThisView+".cFaxCode","Field","Caption","Fax Template")
DBSetProp(ThisView+".cFaxCode","Field","DataType","C(10)")
DBSetProp(ThisView+".cFaxCode","Field","UpdateName","scblTmpGrd.cFaxCode")
DBSetProp(ThisView+".cFaxCode","Field","KeyField",.F.)
DBSetProp(ThisView+".cFaxCode","Field","Updatable",.T.)
