*!* Accountmate Email Blaster
*!* By Alexander Copquin
*!* Add these functions to the arclass prg and compile it
*!* Or in any case, any other prg or class of your choice.
*!* These functions are called by the report prg and generate the datasets used by the email blaster forms.

*/ 	Generate_Blast()	*!* ALEX 2012
*/  Create_Blast_Cache_Table() *!* ALEX 2012
*/ 	Populate_Blast_Jobs () *!* ALEX 2012
*/ 	Insert_Blast_Log_Entry () *!* ALEX 2012

* ----------------------------------------------------------------
FUNCTION generate_blast(tcReport, tcParamString, tcKeyField, tcJobType )
	
	IF EMPTY(tcreport)
		=AMMSG("E", "No file parameter passed")
		RETURN .f.
	ENDIF
	IF EMPTY(tcParamString)
		=AMMSG("E", "No SP parameter string passed")
		RETURN .f.
	ENDIF
	
	*Log Beg. of Blast
	OSC.Insert_Blast_Log_Entry(.f., .f., "", " *** GENERATE BLAST START, for Report :" + ALLTRIM(tcReport) + " *** ")

	WAIT WINDOW "Generating Blast Step 1, Please Wait..." NOWAIT
	
	tcReport = ALLTRIM(tcReport)
	*if report is not in rptmod THEN it's in crystal
	lcDir = "rptmod\"
	lcFile = lcDir + "\" + tcReport
	IF !FILE(lcFile)
		lcDir = "crystal\" 
		lcFile = lcDir + LEFT(tcReport, 2) + "\" + tcReport
		IF!FILE(lcFile)
			WAIT CLEAR
			=AMMSG("E", "Report file does not exist")
			OSC.Insert_Blast_Log_Entry(.t., "", .t., " Couldn't locate Report File " + ALLTRIM(lcFile) )	&&LOG ERROR
			RETURN .f.
		ENDIF
	ENDIF
	*Create Report Object
	oCRYSTAL = CREATEOBJECT('CrystalRuntime.Application.11')
	oReport = oCrystal.OpenReport(lcFile)	
	*get report's stored procedure name
	lcRepSotredProc = ALLTRIM(oReport.Database.Tables(1).Location)
	RELEASE oCrystal

	WAIT WINDOW "Generating Blast Step 2, Please Wait..."	 NOWAIT
		
	*****Create alternative stored proc that will get records from cache (if it already exists, re-create so we get latest params)*****
	*stored proc name is same as original + _scublast
	lcRepSotredProc = left(lcRepSotredProc, AT(";", lcRepSotredProc)-1 )
	lcOrigRepSotredProc = lcRepSotredProc
	lcRepSotredProc = lcRepSotredProc + "_scublast "
	OSC.Insert_Blast_Log_Entry(.f., .t., "", " Create Alternate Stored Proc " + ALLTRIM(lcRepSotredProc) )	&&LOG 
	*if exists, drop
	lcSqlCmd =  " IF  exists(select name from sysobjects where objectproperty(id,'IsProcedure ') = 1 " + ;
				"			 and id = object_id('" + lcRepSotredProc + "')) " + ;
				" select 1 as nResult else select 0 as nResult "
	
	IF !GETSQLDATA(lcSqlCmd, "xCurExists")
		WAIT CLEAR
		=AMMSG("E", "SQL ERROR")
		RETURN .f.
	ENDIF

	lnResult = xCurExists.nResult 
	USE IN ("xCurExists")
	IF lnResult  = 1
		lcSQLCmd = " drop procedure " + lcRepSotredProc  
		IF !SETSQLDATA(lcSqlCmd)
			WAIT CLEAR
			=AMMSG("E", "SQL ERROR")
			RETURN .f.
		ENDIF		
	ENDIF

	WAIT WINDOW "Generating Blast Step 3, Please Wait..."  NOWAIT

	*get parameter definition from original stored proc
	lcSqlCmd = 	" " + ;
				" select syscolumns.name, systpe.name as The_type, prec, syscolumns.scale " + ;
				" from syscolumns " + ;
				" inner join sys.types systpe " + ;
				"	on syscolumns.xType = systpe.system_type_id " + ;
				" where id in (	select id " + ;
				"				from sysobjects " + ;
				"				where name = '" + lcOrigRepSotredProc   + "' " + ;
				"			  ) " + ;
				" order by syscolumns.colid "
	IF !GETSQLDATA(lcSqlCmd, "xCurParams")
		WAIT CLEAR
		=AMMSG("E", "SQL ERROR")
		OSC.Insert_Blast_Log_Entry(.t., .t., "", " Can't Get Stored Proc Parameteres for " + ALLTRIM(lcOrigRepSotredProc) )	&&LOG ERROR
		RETURN .f.
	ENDIF
	*loop through values and script definition
	SELECT xCurParams
	GO top
	lcParamDefintion = " " 
	SCAN
		lcParamDefintion = 	lcParamDefintion + " " + ALLTRIM(xCurParams.name) + " " + ALLTRIM(xcurparams.the_type) + ;
							IIF(INLIST(xcurparams.the_type, "int","smallint","datetime"), "", "(" + ALLTRIM(STR(xCurParams.prec)) + ")" ) 
							
		lcParamDefintion  = lcParamDefintion + ","
		lcParamDefintion = lcParamDefintion + CHR(13)
	ENDSCAN
	USE IN ("xCurParams")
	lcParamDefintion = LEFT(lcParamDefintion, AT(",",lcParamDefintion, OCCURS(",", lcParamDefintion)) -  1)	&&TAKE OUT LAST COMMA

	WAIT WINDOW "Generating Blast Step 4, Please Wait..."  NOWAIT
	
	*script generic stored proc definition
	lcSqlCmd = 	" create procedure " + lcRepSotredProc  + ;
				lcParamDefintion + CHR(13) + ;
				" as begin " + CHR(13) + ;
				" declare 	@cTableName char(30), @cDocNumFrom char(30), @cDocNumTo char (30), @cSearchField char(20), " + ;
				" 			@cOrderBy char(20), @lcSqlCmd varchar(1000) " + CHR(13) + ;
				" 	select	@cTableName = cTableName, @cDocNumFrom = cDocNumFrom, @cDocNumTo = cDocNumTo, "  + CHR(13) + ;
				"			@cSearchField = cSearchField, @cOrderBy = cOrderBy " + ;
				" from scblparams "  + CHR(13) + ;
				" set @lcSQlCMd =	'select * ' + "  + CHR(13) + ;
				" 					' from ' + ltrim(rtrim(@cTableName))  + " + ;
				" ' where 1 = 1 ' "  + CHR(13) + ;
				" IF NOT ( LTRIM(RTRIM(@cSearchField)) = '' OR LTRIM(RTRIM(@cDocNumFrom)) = '' OR LTRIM(RTRIM(@cDocNumTO)) = '' ) " + CHR(13) + ;				
				" BEGIN " + CHR(13) + ;
				" 	set @lcSqlCmd = @lcSqlCmd + 	' and ltrim(rtrim(' + ltrim(rtrim(@cSearchField)) + ')) >= ''' + ltrim(rtrim(@cDocNumFrom)) +  '''' "  + CHR(13) + ;
				" 	set @lcSqlCmd = @lcSqlCmd + 	' and ltrim(rtrim(' + ltrim(rtrim(@cSearchField)) + ')) <= ''' + ltrim(rtrim(@cDocNumTo)) +  '''' "  + CHR(13) + ;
				" 	set @lcSqlCmd = @lcSqlCmd + ' order by ' + ltrim(rtrim(@cOrderBy)) "  + CHR(13) + ;
				" END " + CHR(13) + ;
				" execute( @lcSqlCmd) " + ;
				" end "			
	IF !SETSQLDATA(lcSqlCmd)
		WAIT CLEAR
		=AMMSG("E", "SQL ERROR")
		OSC.Insert_Blast_Log_Entry(.t., .t., "", " Can't Script Alternate Stored Proc " + ALLTRIM(lcRepSotredProc) )	&&LOG ERROR
		RETURN .f.
	ENDIF
 
	WAIT WINDOW "Generating Blast Step 5, Please Wait..."  NOWAIT
	
	**Generte Cache Recordset**
	tcReport = ALLTRIM(LEFT(tcReport , AT(".rpt", tcReport ) - 1))		&&remove extension
	lcCacheTableName = OSC.Create_Blast_Cache_Table(tcReport, lcOrigRepSotredProc, tcParamString, tcKeyField, lcRepSotredProc)
	IF LEN(ALLTRIM(lcCacheTableName)) = 0
		WAIT CLEAR
		RETURN .f.
	ENDIF

	WAIT WINDOW "Generating Blast Step 6, Please Wait..."  NOWAIT
	
	**Insert Records in Jobs table**
	IF !OSC.Populate_Blast_Jobs(lcCacheTableName, tcJobType, tcKeyField)
		WAIT CLEAR
		RETURN .f.
	ENDIF

	**Update Generate Date
	lcSQLCmd = " UPDATE scblsys set dLastGenerate = getdate() "
	SETSQLDATA (lcSqlCmd)

	*Log End. of Blast
	OSC.Insert_Blast_Log_Entry(.f., .f., lcCacheTableName,  " *** GENERATE BLAST END *** ")

	WAIT CLEAR
	RETURN .t.

endfunc	

* ----------------------------------------------------------------

FUNCTION Create_Blast_Cache_Table (tcReport, tcOrigStoredProc, tcParamString, tcKeyField, tcStoredProc)
	
	PRIVATE lcReport, lcUID, cTableName, lnRecordNumberCount, lcCacheUID, lcSearchField, lcParamString, lcStoredProc, lcEnterBy

	*cache table name is reportname_UID
	cTableNAme = ALLTRIM(tcReport) + "_" + ALLTRIM(sp_assignuid())
	OSC.Insert_Blast_Log_Entry(.f., .t., cTableNAme, " Create Cache Recordset " + ALLTRIM(cTableNAme) )	&&LOG 
	*get recordset
	lcSqlCmd = " execute " + tcOrigStoredProc + " " +  tcParamString 
	IF !getsqldata(lcSqlCmd, "xCurRecSet")
		IF !USED("xCurRecSet")
			=AMMSG("E", "SQL ERROR")
			OSC.Insert_Blast_Log_Entry(.t., .t., cTableNAme, " Error Getting Report's recordset for stored proc " + ALLTRIM(tcOrigStoredProc) )	&&LOG ERROR
			RETURN ""
		ENDIF
		IF RECCOUNT("xCurRecSet") <= 0
			=AMMSG("I", "No Records Found")
			OSC.Insert_Blast_Log_Entry(.f., .f., cTableNAme, " No Records Found " )	&&LOG for user
			OSC.Insert_Blast_Log_Entry(.f., .f., cTableNAme, " *** GENERATE BLAST END *** ")
			RETURN ""
		ENDIF		
	ENDIF

	SELECT xCurRecSet
	AFIELDS(aReport, "xCurRecSet")

	nArrLen = ALEN(aReport, 1)
	lcSQlCreate = " "

	*loop through array 
	FOR i = 1 TO nArrLen
		*field name
		lcSQlCreate = lcSQlCreate + " " + LOWER(ALLTRIM(aReport(i, 1)))
		*script field type
		DO CASE
			CASE aReport(i, 2) = "C"
				lcFldType = " CHAR ("  + ALLTRIM(STR(areport(i, 3))) + ")"
			CASE aReport(i, 2) = "D"
				lcFldType = " datetime"
			CASE aReport(i, 2) = "T"
				lcFldType = " datetime"
			CASE aReport(i, 2) = "I"
				lcFldType = " smallint" 
			CASE aReport(i, 2) = "N"
				lcFldType = " Numeric ("  + ALLTRIM(STR(areport(i, 3) - 2)) + ", " + ALLTRIM(STR(areport(i, 4))) + ")"
			CASE aReport(i, 2) = "M"
				lcFldType = " text" 
			CASE aReport(i, 2) = "G"
				lcFldType = " image" 
			OTHERWISE
				lcFldType = ""
		ENDCASE

		lcSQlCreate  = lcSQlCreate  + lcFldType 

		IF i <> nArrLen
				lcSQlCreate  = 	lcSQlCreate  + ", "
		ENDIF

	ENDFOR

	*assign table name
	lcSQlCreate  =" CREATE TABLE " + ALLTRIM(cTableNAme) + " (" + lcSqlCreate + ")"
	*create table
	IF !SetSQLdata (lcSqlCreate )
		=AMMSG("E", "SQL ERROR")
		OSC.Insert_Blast_Log_Entry(.t., .t., cTableNAme, " Error Creating Table" + ALLTRIM(cTableName) )	&&LOG ERROR
		RETURN ""	
	ENDIF

	*add index
	lcSqlCreate = " CREATE NONCLUSTERED INDEX x" + ALLTRIM(tcKeyField) + "_" + ALLTRIM(cTableNAme) + "  ON " + ALLTRIM(cTableNAme) + " ( " + ALLTRIM(tcKeyField) + " asc )" 
	IF !SetSQLdata (lcSqlCreate )
		=AMMSG("E", "SQL ERROR")
		OSC.Insert_Blast_Log_Entry(.t., .t., cTableNAme, " Error Adding Index " + ALLTRIM(tcKeyField) )	&&LOG ERROR
		RETURN ""	
	ENDIF

	**CREATE insert script
	OSC.Insert_Blast_Log_Entry(.f., .t., cTableNAme, " Populate Cache Recordset " )	&&LOG 
	lcInsScript = ""
	*loop through array, choose one column	at a time and script
	FOR i = 1 TO nArrLen
		lcSelField = "?xCurRecSet." + ALLTRIM(areport(i, 1))
		lcInsScript = lcInsScript + lcSelField

		IF i <> nArrLen
				lcInsScript = lcInsScript + ", "
		ENDIF
	ENDFOR

	*populate
	SELECT xCurRecSet
	GO top
	lnRecordNumberCount = 1
	SCAN
		lcSqlCmd = 	" INSERT INTO " + ALLTRIM(cTableNAme)  + ;
					"	SELECT "  + ;
					lcInsScript 
		IF !SETSQLDATA(lcSqlCmd )
			=AMMSG("E", "SQL ERROR")
			OSC.Insert_Blast_Log_Entry(.t., .t., cTableNAme, " Error populating " + ALLTRIM(cTableNAme) )	&&LOG ERROR
			RETURN "ERROR"
		ENDIF
	ENDSCAN

	USE IN ("xCurRecSet")	

	*!* add table to cache list table
	lcUID = sp_assignuid()
	lcSearchField = ALLTRIM(tcKeyField)
	lcParamString = tcParamString
	lcReport = tcReport
	lcStoredProc = tcStoredProc
	lcEnterBy = ALLTRIM(oSQLUser.cFullName)
	lcSQLCMD = 	" INSERT into scblCache " + ;
				" SELECT ?lcUID, getdate(), ?cTableNAme, ?lcEnterBy, ?lcParamString , ?lcSearchField, ?lcReport, ?lcStoredProc "
	IF !SETSQLDATA(lcSqlCmd )
		=AMMSG("E", "SQL ERROR")
		OSC.Insert_Blast_Log_Entry(.t., .t., cTableNAme, " Error adding table " + ALLTRIM(cTableNAme) + " to cache list table scblcache  ")	&&LOG ERROR
		RETURN "ERROR"
	ENDIF
				 
	RETURN cTableNAme
	
ENDFUNC

* ----------------------------------------------------------------

FUNCTION Populate_Blast_Jobs(tcCacheTableName, tcJobType, tcKeyField)
	OSC.Insert_Blast_Log_Entry(.f., .t., tcCacheTableName,  " Insert Jobs in List Table scbllist " )	&&LOG 
	PRIVATE lcJobType, lcCacheTableName , cDocNum
	lcJobType = ALLTRIM(tcJobType)
	lcCacheTableName  = tcCacheTableName
	
	*!* Add jobtype to jobtype table if missing.
	lcSqlCmd = " select COUNT(*) as ncount from scbljbTpe where cJobType = ?lcJobType "
	GETSQLDATA(lcSqlCmd, "xCurJobTypeCount")
	lnCount = xCurJobTypeCount.nCount
	USE IN ("xCurJobTypeCount")
	IF lnCount = 0	
		*!* add job
		lcSqlCmd = 	" INSERT into scbljbTpe (CUID, cJobType ) " + ;
					"	Values (left(newid(),8) + right(newid(),7), ?lcJobType) "
		SETSQLDATA	(lcSQLCMD)	
	ENDIF 

	*!* get recordset from cache table and populate Job list table
	lcSqlCmd = " select * from " + ALLTRIM(lcCacheTableName)

	IF !GETSQLDATA(lcSqlCMd, "xCurBlast")
		=AMMSG("E", "SQL ERROR cache table not found")
		OSC.Insert_Blast_Log_Entry(.t., .t., tcCacheTableName, " Error getting records from  " + ALLTRIM(lcCacheTableName) )	&&LOG ERROR
		RETURN .f.
	ENDIF
	IF USED("xCurBlast")	
		SELECT xCurBlast
		lcCacheTableName = LEFT(ALLTRIM(lcCacheTableName), 30)
		GO top
		SCAN
			lScript = "cDocNum = xCurBlast." + ALLTRIM(tcKeyField)
			&lScript
			lcSQLCMd = 	" Insert into scbllist " + ;
						" SELECT left(newid(),8) + right(newid(),7), " + ;
						" getdate(), " + ;
						" ?lcJobType, " + ; 
						" ?cDocNum,  " + ; 
						" ?xCurBlast.cCustNo,  " + ;
						" ?lcCacheTableName, " + ;
						" 'N', " + ;
						" '', " + ;
						" 'NOT SENT' "
			IF !SETSQLDATA (lcSQLCMD)
				=AMMSG("E", "SQL ERROR inserting jobs in list table")
				OSC.Insert_Blast_Log_Entry(.t., .t., tcCacheTableName, " Error inserting records in job list table scbllist " )	&&LOG ERROR
				RETURN .f.
			ENDIF
		
		ENDSCAN
		USE IN ("xCurBlast")
	ENDIF

	RETURN .t.
ENDFUNC

* ----------------------------------------------------------------
FUNCTION Insert_Blast_Log_Entry(tlIsError, tlIsSystem, tcTableName, tcComment)
	*inserts log records into ScBlLog
	* parameters:
	* tlIsError Specifies if this entry is an error
	* tlIsSystem Specifies if this is an internal system entry, or just info for the user
	* tcComment the comments that will go on the log.

	PRIVATE lcUID, llIsError, lIsSystem, lcTableName, lcComment 
	lcUID = sp_AssignUID()
	llIsError = tlIsError
	lIsSystem = tlIsSystem
	lcEnterBy = ALLTRIM(oSQLUser.cFullName)
	lcComment = tcComment
	lcTableName = tcTableName


	lcSqlCmd = 	" insert into scbllog " + ;
				" (cUID, tTimeStamp, cEnterBy, lError, lSystem, cTableName, mComment) " + ;
				" values " + ;
				" (?lcUID, GETDATE(), ?lcEnterBy, ?llIsError, ?lIsSystem, ?lcTableName, ?lcComment   ) "
	IF!SETSQLDATA (lcSqlCmd)
		=AMMSG("E", "SQL error inserting into scbllog")
		RETURN .f.
	ENDIF

	RETURN .t.

ENDFUNC

ENDDEFINE

