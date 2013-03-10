close all

open data 

ThisView = "scblsys"

IF INDBC(ThisView,"VIEW")
	DROP VIEW &ThisView
ENDIF

CREATE SQL VIEW Scblsys; 
   REMOTE CONNECT "AMCONNECT" ; 
   AS SELECT  Scblsys.csmtp, Scblsys.cSmtpUsr, Scblsys.cSmtpPwd,;
			  Scblsys.cSmtpPort, Scblsys.lSmtpUseAuth, Scblsys.lSmtpUseSSL, ;
			  Scblsys.cEsubCode, Scblsys.cFsubCode, ;
			  Scblsys.cPathPdf ;
 FROM ;
     scblsys Scblsys

DBSetProp(ThisView,"View","Comment","Email Blast Configuration")
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
DBSetProp(ThisView,"View","Tables","Scblsys")
DBSetProp(ThisView,"View","WhereType",3)

DBSetProp(ThisView+".csmtp","Field","Caption","SMTP Server")
DBSetProp(ThisView+".csmtp","Field","DataType","C(150)")
DBSetProp(ThisView+".csmtp","Field","UpdateName","scblsys.csmtp")
DBSetProp(ThisView+".csmtp","Field","KeyField",.T.)
DBSetProp(ThisView+".csmtp","Field","Updatable",.T.)

DBSetProp(ThisView+".csmtpusr","Field","Caption","SMTP User")
DBSetProp(ThisView+".csmtpusr","Field","DataType","C(150)")
DBSetProp(ThisView+".csmtpusr","Field","UpdateName","scblsys.cSmtpUsr")
DBSetProp(ThisView+".csmtpusr","Field","KeyField",.F.)
DBSetProp(ThisView+".csmtpusr","Field","Updatable",.T.)

DBSetProp(ThisView+".csmtppwd","Field","Caption","SMTP Password")
DBSetProp(ThisView+".csmtppwd","Field","DataType","C(150)")
DBSetProp(ThisView+".csmtppwd","Field","UpdateName","scblsys.cSmtpPwd")
DBSetProp(ThisView+".csmtppwd","Field","KeyField",.F.)
DBSetProp(ThisView+".csmtppwd","Field","Updatable",.T.)

DBSetProp(ThisView+".csmtpport","Field","Caption","SMTP Port")
DBSetProp(ThisView+".csmtpport","Field","DataType","N(5)")
DBSetProp(ThisView+".csmtpport","Field","UpdateName","scblsys.cSmtpPort")
DBSetProp(ThisView+".csmtpport","Field","KeyField",.F.)
DBSetProp(ThisView+".csmtpport","Field","Updatable",.T.)

DBSetProp(ThisView+".lSmtpUseAuth","Field","Caption","Use Authentication")
DBSetProp(ThisView+".lSmtpUseAuth","Field","DataType","I")
DBSetProp(ThisView+".lSmtpUseAuth","Field","DefaultValue","0")
DBSetProp(ThisView+".lSmtpUseAuth","Field","UpdateName","scblsys.lSmtpUseAuth")
DBSetProp(ThisView+".lSmtpUseAuth","Field","KeyField",.F.)
DBSetProp(ThisView+".lSmtpUseAuth","Field","Updatable",.T.)

DBSetProp(ThisView+".lSmtpUseSSL","Field","Caption","Use SSL/TLS")
DBSetProp(ThisView+".lSmtpUseSSL","Field","DataType","I")
DBSetProp(ThisView+".lSmtpUseSSL","Field","DefaultValue","0")
DBSetProp(ThisView+".lSmtpUseSSL","Field","UpdateName","scblsys.lSmtpUseSSL")
DBSetProp(ThisView+".lSmtpUseSSL","Field","KeyField",.F.)
DBSetProp(ThisView+".lSmtpUseSSL","Field","Updatable",.T.)

DBSetProp(ThisView+".cEsubCode","Field","Caption","Default Email Subject")
DBSetProp(ThisView+".cEsubCode","Field","DataType","C(10)")
DBSetProp(ThisView+".cEsubCode","Field","UpdateName","scblsys.cEsubCode")
DBSetProp(ThisView+".cEsubCode","Field","KeyField",.F.)
DBSetProp(ThisView+".cEsubCode","Field","Updatable",.T.)

DBSetProp(ThisView+".cFsubCode","Field","Caption","Default Fax Subject")
DBSetProp(ThisView+".cFsubCode","Field","DataType","C(10)")
DBSetProp(ThisView+".cFsubCode","Field","UpdateName","scblsys.cFsubCode")
DBSetProp(ThisView+".cFsubCode","Field","KeyField",.F.)
DBSetProp(ThisView+".cFsubCode","Field","Updatable",.T.)

DBSetProp(ThisView+".cPathPdf","Field","Caption","Pdf File Directory")
DBSetProp(ThisView+".cPathPdf","Field","DataType","C(100)")
DBSetProp(ThisView+".cPathPdf","Field","UpdateName","scblsys.cPathPdf")
DBSetProp(ThisView+".cPathPdf","Field","KeyField",.F.)
DBSetProp(ThisView+".cPathPdf","Field","Updatable",.T.)