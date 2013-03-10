*!* Email Blaster for Accountmate.
*!* By Alexander Copquin

*!* Add this code to the end of each Crystal Report Prg you want to send to the email batch. (like arinvccr.prg) 
*!* you also need to add a checkbox object in amrftr.dbf and reference it with the llblast variable 
*!* If the code 

*!* BEG ALEX 2012 IF Blast selected, call blast cache generation function
LOCAL llBlast_local
llBlast_local = .f.
IF TYPE("llBlast") <> "L"
	llBlast_local = IIF(llblast = ".t.", .t., .f.)
ELSE
	llBlast_local = llblast
ENDIF

IF llBlast_local
	glReportOK = .f.		&&this so report is not previewed
	*gather parameters and script
	*IMPORTANT! parameters must be in EXACT order as they are defined in report's stored procedure
	*for string parameters start and end with ' and replace single ' with ''
	lcParamString = ""
	lcParamString = lcParamString + ;
					iif(llAlign, "1", "0") + ", " + ;
					iif(llCurrent, "1", "0") + ", " + ;
					iif(llInclItemSpec, "1", "0") + ", " + ;
					iif(plIndividual, "1", "0") + ", " + ;					
					ALLTRIM(STR(lnSortNo)) + ", " + ;										
					"'" + STRTRAN(GetStr(lcFilter1, 2, 1), "'", "''") + "'" + ", " + ;
					"'" + STRTRAN(GetStr(lcFilter1, 2, 2), "'", "''") + "'" + ", " + ;
					"'" + GetStr(oSQLSM.cHistFiles, 2, 1) + "'" + ", " + ;				
					"'" + GetStr(oSQLSM.cHistFiles, 2, 2) + "'" + ", " + ;				
					iif(llInvcLbl1, "1", "0") + ", " + ;		
					iif(llInvcLbl2, "1", "0") + ", " + ;		
					iif(llInvcLbl3, "1", "0") + ", " + ;		
					iif(llInvcLbl4, "1", "0") + ", " + ;		
					iif(llInvcLbl4, "1", "0") + ", " + ;		
					"'" + lcCustLang + "'" + ", " + ;		
					ALLTRIM(STR(llFDesc))
	
	*function is in scclass.prg
	*parameters: report name, SP parameter string, KeyField, Job Name
	*!* Depending on which class you added the code to, change the reference to the object
	*!* in this case, the functions are on the arclass.
	IF !oAR.generate_blast ( "arinvc.rpt", lcParamString, "cInvNo", "INVOICE" )
		=AMMSG("I", "Blast not Generated")		
	ELSE
		=AMMSG("I", "Blast Generated")
	ENDIF
	return
ENDIF
*!* END ALEX 2012
