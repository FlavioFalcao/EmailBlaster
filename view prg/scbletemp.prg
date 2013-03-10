close all

open data 

ThisView = "scblETemp"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW scblETemp; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT 	scblETemp.cuid, scblETemp.cSubcode, scblETemp.cSubDescr,  scblETemp.mBody ;
 FROM ;
     scblETemp scblETemp ;
WHERE  scblETemp.cSubcode = ( ?gcKey1 ) ;
order by scblETemp.cSubCode


DBSetProp(ThisView,"View","Comment","Email Blast Email Templates")
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
DBSetProp(ThisView,"View","Tables","scblETemp")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".cuid","Field","Caption","ID")
DBSetProp(ThisView+".cuid","Field","DataType","C(15)")
DBSetProp(ThisView+".cuid","Field","UpdateName","scblETemp.CUID")
DBSetProp(ThisView+".cuid","Field","KeyField",.T.)
DBSetProp(ThisView+".cuid","Field","Updatable",.T.)

DBSetProp(ThisView+".cSubcode","Field","Caption","Subject Code")
DBSetProp(ThisView+".cSubcode","Field","DataType","C(10)")
DBSetProp(ThisView+".cSubcode","Field","UpdateName","scblETemp.cSubcode")
DBSetProp(ThisView+".cSubcode","Field","KeyField",.F.)
DBSetProp(ThisView+".cSubcode","Field","Updatable",.T.)

DBSetProp(ThisView+".cSubDescr","Field","Caption","Description")
DBSetProp(ThisView+".cSubDescr","Field","DataType","C(254)")
DBSetProp(ThisView+".cSubDescr","Field","UpdateName","scblETemp.cSubDescr")
DBSetProp(ThisView+".cSubDescr","Field","KeyField",.F.)
DBSetProp(ThisView+".cSubDescr","Field","Updatable",.T.)

DBSetProp(ThisView+".mBody","Field","Caption","Notepad")
DBSetProp(ThisView+".mBody","Field","DataType","M")
DBSetProp(ThisView+".mBody","Field","UpdateName","scblETemp.mBody")
DBSetProp(ThisView+".mBody","Field","KeyField",.F.)
DBSetProp(ThisView+".mBody","Field","Updatable",.T.)
