close all

open data 

ThisView = "scbljbTpe"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW scbljbTpe; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT 	scbljbTpe.cuid, scbljbTpe.cJobType;
 FROM ;
     scbljbTpe scbljbTpe

DBSetProp(ThisView,"View","Comment","Prism Blaster Job Type List")
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
DBSetProp(ThisView,"View","Tables","scbljbTpe")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".cuid","Field","Caption","ID")
DBSetProp(ThisView+".cuid","Field","DataType","C(15)")
DBSetProp(ThisView+".cuid","Field","UpdateName","scbljbTpe.CUID")
DBSetProp(ThisView+".cuid","Field","KeyField",.T.)
DBSetProp(ThisView+".cuid","Field","Updatable",.T.)

DBSetProp(ThisView+".cJobType","Field","Caption","Job Type")
DBSetProp(ThisView+".cJobType","Field","DataType","C(10)")
DBSetProp(ThisView+".cJobType","Field","UpdateName","scbljbTpe.cJobType")
DBSetProp(ThisView+".cJobType","Field","KeyField",.F.)
DBSetProp(ThisView+".cJobType","Field","Updatable",.T.)

