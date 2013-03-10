close all

open data 

ThisView = "scblFTemp"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW scblFTemp; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT 	scblFTemp.cuid, scblFTemp.cSubcode, scblFTemp.cSubDescr,  scblFTemp.mBody ;
 FROM ;
     scblFTemp scblFTemp ;
WHERE  scblFTemp.cSubcode = ( ?gcKey1 ) ;
order by scblFTemp.cSubCode


DBSetProp(ThisView,"View","Comment","Email Blast Fax Cover Sheet Templates")
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
DBSetProp(ThisView,"View","Tables","scblFTemp")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".cuid","Field","Caption","ID")
DBSetProp(ThisView+".cuid","Field","DataType","C(15)")
DBSetProp(ThisView+".cuid","Field","UpdateName","scblFTemp.CUID")
DBSetProp(ThisView+".cuid","Field","KeyField",.T.)
DBSetProp(ThisView+".cuid","Field","Updatable",.T.)

DBSetProp(ThisView+".cSubcode","Field","Caption","Subject Code")
DBSetProp(ThisView+".cSubcode","Field","DataType","C(10)")
DBSetProp(ThisView+".cSubcode","Field","UpdateName","scblFTemp.cSubcode")
DBSetProp(ThisView+".cSubcode","Field","KeyField",.F.)
DBSetProp(ThisView+".cSubcode","Field","Updatable",.T.)

DBSetProp(ThisView+".cSubDescr","Field","Caption","Description")
DBSetProp(ThisView+".cSubDescr","Field","DataType","C(254)")
DBSetProp(ThisView+".cSubDescr","Field","UpdateName","scblFTemp.cSubDescr")
DBSetProp(ThisView+".cSubDescr","Field","KeyField",.F.)
DBSetProp(ThisView+".cSubDescr","Field","Updatable",.T.)

DBSetProp(ThisView+".mBody","Field","Caption","Notepad")
DBSetProp(ThisView+".mBody","Field","DataType","M")
DBSetProp(ThisView+".mBody","Field","UpdateName","scblFTemp.mBody")
DBSetProp(ThisView+".mBody","Field","KeyField",.F.)
DBSetProp(ThisView+".mBody","Field","Updatable",.T.)
