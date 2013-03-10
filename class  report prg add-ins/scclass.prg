#INCLUDE "sc.h"

*/ Classes:
*/ 	SC
*/ 	SCEudfkey
*/ 	SCEyesno
*/ 	SCEPdlbl

*======================================================================================
DEFINE CLASS SC AS CUSTOM

*/ Methods available for use:
*/  GetCalendarFields()
*/  SccudfError()
*/ 	FillUDFPropArray()
*/ 	UDFGetProp()
*/ 	UDFCount()
*/ 	AmtPicture()
*/ 	CustRushm()
*/	CustGetProp()
*/  FillCustPropArray()
*/  CreateSccudfView()
*/  PreviewTicket()		*!* PRISM AA 04/01/03
*/  GetPVSCaption()		*!* PRISM AA 04/02/03
*/ 	Generate_Blast()	*!* ALEX 2012
*/  Create_Blast_Cache_Table() *!* ALEX 2012
*/ 	Populate_Blast_Jobs () *!* ALEX 2012
*/ 	Insert_Blast_Log_Entry () *!* ALEX 2012

PROTECTED aUDFProps[UDF_SCCUDFCNT, UPROP_ARYCOLS]
PROTECTED aCustProps[1, CPROP_ARYCOLS]
PROTECTED nUDFCount

nUDFCount = 0
* ----------------------------------------------------------------
* - Name		:	GetCalendarFields(tcTable)
* - Programmer	: 	AA
* - Created		: 	03/22/2002
* ----------------------------------------------------------------
*!* beg Prism AA 03/25/2002
FUNCTION GetCalendarFields
LPARAMETERS tcTable
LOCAL lcTable

	lcTable = ALLTRIM(UPPER(tcTable))
	DO CASE
		CASE lcTable == 'SCRCRI'
			lcFieldList = 'cdaysjan ,cdaysfeb ,cdaysmar ,' + ;
			              'cdaysapr ,cdaysmay ,cdaysjun ,' + ; 
			              'cdaysjul ,cdaysaug ,cdayssep ,' + ;
			              'cdaysoct ,cdaysnov ,cdaysdec ,' + ; 
			              'ccodejan ,ccodefeb ,ccodemar ,' + ; 
			              'ccodeapr ,ccodemay ,ccodejun ,' + ;
			              'ccodejul ,ccodeaug ,ccodesep ,' + ;
			              'ccodeoct ,ccodenov ,ccodedec'
		OTHERWISE 
			lcFieldList = ''
	ENDCASE
	RETURN lcFieldList
ENDFUNC
*!* end Prism AA 03/25/2002
* ----------------------------------------------------------------
FUNCTION SccudfError()

llError = .f.
lcOrigErrRtn = on("ERROR")
on error llError = .t.
use (oSQLCompany.cFullDBC+"sccudf") in 0 nodata
if empty(lcOrigErrRtn)
	on error
else
	on error &lcOrigErrRtn	
endif

return llError

* ----------------------------------------------------------------
FUNCTION FillUDFPropArray()

parameters tnDataSessionId

#define UDFERR_NOERR			0
#define UDFERR_MILDERROR		max(lnErrLvl, 1)
#define UDFERR_CRITICALERROR	max(lnErrLvl, 2)

local llSccudfOpen, llScsystOpen, lnFldCnt, lnCtr, lnFldNum, lnErrLvl, ;
	lcLine
local laFlds[1]

if empty(tnDatasessionId) 
	if type("_screen.ActiveForm") = "O"
		set datasession to _screen.ActiveForm.DataSessionID	
	endif	
else
	set datasession to tnDataSessionId
endif	
=Initviewparms()
if used("Sccudf")
	llSccudfOpen = .t.
else
	use (oSQLCompany.cFullDbc + "Sccudf") in 0
	llSccudfOpen = .f.
endif
if used("Scsyst")
	llScsystOpen = .t.
else
	use (oSQLCompany.cFullDbc + "Cmsyst") in 0
	llScsystOpen = .f.
endif
This.aUDFProps = .f.

*/ Error codes:
*/ 0 = no error
*/ 1 = error in UDF definition, but UDF definable
*/ 2 = error in UDF definition; UDF not definable
lnErrLvl = UDFERR_NOERR
lnFldCnt = afields(laFlds, "Sccudf")

for lnCtr = 2 to lnFldCnt
	lnFldNum = val(rightc(laFlds[lnCtr,1], 2))
	This.nUDFCount = lnCtr - 1
	if !between(lnFldNum, 1, UDF_SCCUDFCNT)
		lnErrLvl = UDFERR_CRITICALERROR
		loop
	endif
	lcLine = mline(Scsyst.mUDFInfo, lnFldNum)
	llLookup = .f.
	if "," $ lcLine
		This.aUDFProps[lnFldNum, UPROP_CAPTION] = alltrim(leftc(lcLine, ;
			ratc(",", lcLine) - 1))
		if empty(This.aUDFProps[lnFldNum, UPROP_CAPTION])
			lnErrLvl = UDFERR_CRITICALERROR
			loop
		endif
		if laFlds[lnCtr, 2] = "C"
			local lcTemp
			lcTemp = substrc(lcLine, ratc(",", lcLine) + 1)
			if type(lcTemp) = "L"
				This.aUDFProps[lnFldNum, UPROP_LOOKUP] = evaluate(lcTemp)
			else
				lnErrLvl = UDFERR_MILDERROR
			endif
		endif
	else
		lnErrLvl = UDFERR_MILDERROR
	endif

	This.aUDFProps[lnFldNum, UPROP_FLDNAME] = lower(laFlds[lnCtr, 1])
	This.aUDFProps[lnFldNum, UPROP_TYPE] = laFlds[lnCtr, 2]
	This.aUDFProps[lnFldNum, UPROP_WIDTH] = laFlds[lnCtr, 3]
	This.aUDFProps[lnFldNum, UPROP_DEC] = laFlds[lnCtr, 4]
	
	do case
		case laFlds[lnCtr, 2] = "C"
			This.aUDFProps[lnFldNum, UPROP_IMASK] = ;
				replicate(iif(This.aUDFProps[lnFldNum, UPROP_LOOKUP], "!", ;
				"x"), laFlds[lnCtr, 3])
			This.aUDFProps[lnFldNum, UPROP_EMPTYVAL] = space(laFlds[lnCtr, 3])
		case laFlds[lnCtr, 2] = "D" or laFlds[lnCtr, 2] = "T"
			This.aUDFProps[lnFldNum, UPROP_IMASK] = "99/99/99"
			This.aUDFProps[lnFldNum, UPROP_EMPTYVAL] = {}
		case laFlds[lnCtr, 2] = "L" or laFlds[lnCtr, 2] = "I"
			This.aUDFProps[lnFldNum, UPROP_IMASK] = "Y"
			This.aUDFProps[lnFldNum, UPROP_EMPTYVAL] = "N"
		case laFlds[lnCtr, 2] = "N"
			This.aUDFProps[lnFldNum, UPROP_IMASK] = This.AmtPicture( ;
				laFlds[lnCtr, 3], laFlds[lnCtr, 4])
			This.aUDFProps[lnFldNum, UPROP_EMPTYVAL] = round(0, laFlds[lnCtr, 4])
	endcase
endfor

return lnErrLvl

#undef UDFERR_NOERR
#undef UDFERR_MILDERROR
#undef UDFERR_CRITICALERROR
* ----------------------------------------------------------------

FUNCTION UDFGetProp(tnUDFNo, tnProp)

return This.aUDFProps[tnUDFNo,tnProp]
* ----------------------------------------------------------------

FUNCTION UDFcount()

return This.nUDFCount

ENDFUNC
* ----------------------------------------------------------------

FUNCTION AmtPicture(tnWidth, tnDec)

local lcMask, lnCtr

lcMask = replicate("9", tnWidth - tnDec - iif(tnDec > 0, 1, 0))
for lnCtr = lenc(lcMask) - 2 to 2 step -3
	lcMask = stuffc(lcMask, lnCtr, 0, ",")
endfor

if tnDec > 0
	return lcMask + "." + replicate("9", tnDec)
else
	return lcMask
endif
* ----------------------------------------------------------------

FUNCTION CustRushm(tcField, tcValue)

*/ tcField: name of Arcust.dbf field
*/ tcValue (optional): value to compare, in string form, eg.
*/		"'CUST01'", "{01/01/90 12:00:00 AM}", "3.1416"

*/ Returns a Rushmore-optimizable operand for an Arcust.dbf field, 
*/ if such an operand can be created.  If a Rushmore-optimizable operand
*/ cannot be created, returns the field name as the operand.

*/ The operand returned can be the left-hand side operand or the right-hand 
*/ side operand (e.g., <oper1> >= <oper2>).  If the second parameter is NOT 
*/ specified, returns the left-hand side operand.  If the second parameter 
*/ is specified, returns the right-hand side operand.

*/ Ex: oCM.CustRushm("ARCUST.CLNAME") returns "UPPER(ARCUST.CLNAME+ARCUST.CFNAME)+ARCUST.CCUSTNO"
*/	   oCM.CustRushm("ARCUST.CLNAME", '"Rogers"') returns "UPPER("Rogers")"

local lcOper1, lcOper2
lcOper1 = lower(tcField)
if type("tcValue") = "C"
*	lcOper2 = upper(tcValue)
	lcOper2 = tcValue
endif

do case	
	case tcField = lower("ARCUST.DCREATE")
		if type("tcValue") = "C"
			lcOper2 = OdbcDate(&tcValue)
		endif
	case tcField = lower("ARCUST.tRECALL")
	    lcOper1 = " convert(char(8), trecall, 112) "
		if type("tcValue") = "C"
			lcOper2 = SqlDtos(ttod(&tcValue))
		endif
	case tcField = lower("ARCUST.tMODIFIED")
	    lcOper1 = " convert(char(8), tmodified, 112) "
		if type("tcValue") = "C"
			lcOper2 = SqlDtos(ttod(&tcValue))
		endif
	case tcField = lower("ARCUST.tLCALL")
	    lcOper1 = " convert(char(8), tlcall, 112) "
		if type("tcValue") = "C"
			lcOper2 = SqlDtos(ttod(&tcValue))
		endif
	case tcField = lower("ARCUST.LFINCHG")
		if type("tcValue") = "C"
			lcOper2 = iif(&tcValue = "Y", '1', '0')
		endif
	case tcField = lower("ARCUST.LPRTSTMT")
		if type("tcValue") = "C"
			lcOper2 = iif(&tcValue = "Y", '1', '0')
		endif
	case leftc(tcfield, 2) = "cm" and !empty(tcValue) 
		do case
			case type(tcValue) = "D"
				lcOper2 = odbcDate(&tcValue)			
			case type(tcValue) = "C" 	and inlist(&tcValue, "Y", "N")	
				lcOper2 = iif(&tcValue = "Y", '1', '0')
		endcase 
endcase

return iif(type("tcValue") = "C", lcOper2, lcOper1)
* ----------------------------------------------------------------

FUNCTION CustGetProp(tcField, tnProp)

local lnFldCnt, lnFldNum, lcField

lnFldCnt = alen(This.aCustProps, 1)

if lnFldCnt = 1		&& Lookup table not yet initialized?
	This.FillCustPropArray()
endif

lcField = upper(tcField)
for lnFldNum = 1 to lnFldCnt
	if This.aCustProps[lnFldNum,CPROP_FLDNAME] = lcField
		return This.aCustProps[lnFldNum,tnProp]
	endif
endfor

* ----------------------------------------------------------------
FUNCTION FillCustPropArray()

local llArcustOpen, lnFldCnt, lnFldNum
local laFlds[1]

=Initviewparms()
if used("Arcust")
	llArcustOpen = .t.
else
	use (oSQLCompany.cFullDbc + "Arcust") in 0
	llArcustOpen = .f.
endif

lnFldCnt = afields(laFlds, "Arcust")
for lnFldNum = 1 to lnFldCnt
	dimension This.aCustProps[lnFldNum,CPROP_ARYCOLS]
	This.aCustProps[lnFldNum,CPROP_FLDNAME] = laFlds[lnFldNum,1]
	This.aCustProps[lnFldNum,CPROP_TYPE] = laFlds[lnFldNum,2]		
	This.aCustProps[lnFldNum,CPROP_WIDTH] = laFlds[lnFldNum,3]		
	This.aCustProps[lnFldNum,CPROP_DEC] = laFlds[lnFldNum,4]	
	This.aCustProps[lnFldNum,CPROP_CAPTION]	= AmTran(GetKeyCaption("Arcust." + ;
		laFlds[lnFldNum,1]))
	This.GetIMaskAndEmptyVal(lnFldNum, laFlds[lnFldNum,1], ;
		 laFlds[lnFldNum,3], laFlds[lnFldNum,4])	
endfor

if !llArcustOpen
	use in Arcust
endif

* ----------------------------------------------------------------

PROTECTED FUNCTION GetIMaskAndEmptyVal(tnFldNum, tcCustFld, tnWidth, tnDec)
 
do case
	case tcCustFld = "CCUSTNO"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nCustLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nCustLen)
	case tcCustFld = "CCOMPANY"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CADDR1"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CADDR2"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CCITY"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CSTATE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CZIP"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CCOUNTRY"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CPHONE1"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CPHONE2"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CFAX"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CEMAIL"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("x", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CFNAME"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CLNAME"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CDEAR"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CTITLE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CORDERBY"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CSLPNNO"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nSlpnLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nSlpnLen)
	case tcCustFld = "CSTATUS"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = " "
	case tcCustFld = "CCLASS"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nMiscLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nMiscLen)
	case tcCustFld = "CINDUSTRY"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nMiscLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nMiscLen)
	case tcCustFld = "CTERR"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nMiscLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nMiscLen)
	case tcCustFld = "CWAREHOUSE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nWhseLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nWhseLen)
	case tcCustFld = "CPAYCODE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nPyCdLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nPyCdLen)
	case tcCustFld = "CBILLTONO"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nAddrLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nAddrLen)
	case tcCustFld = "CSHIPTONO"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nAddrLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nAddrLen)
	case tcCustFld = "CTAXCODE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nSTaxLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nSTaxLen)
	case tcCustFld = "CRESALENO"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("x", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CPSTNO"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("x", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CCURRCODE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!", oSQLSM.nCurrLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nCurrLen)
	case tcCustFld = "CPRTSTMT"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = " "
	case tcCustFld = "CARACC"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oSQLSM.cAcctMask
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(lenc(oSQLSM.cAcctMask))
	case tcCustFld = "CRCALACTN"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CLCALACTN"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "!" + replicate("x", tnWidth - 1)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "DCREATE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = {}
	case tcCustFld = "TMODIFIED"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ctot("")
	case tcCustFld = "TRECALL"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ctot("")
	case tcCustFld = "TLCALL"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ctot("")
	case tcCustFld = "LPRTSTMT"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "Y"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = "N"
	case tcCustFld = "LFINCHG"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "Y"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = "N"
	case tcCustFld = "NPRICECD"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, tnDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, tnDec)
	case tcCustFld = "NDISCRATE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, tnDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, tnDec)
	case tcCustFld = "NATDSAMT"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NCRLIMIT"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NSOBOAMT"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NOPENCR"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NBALANCE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oCM.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "MNOTEPAD"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ""

*-begin	1/2000 - rtp
	case tcCustFld = "CREVNCODE"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("!",oSQLSM.nRevnLen)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(oSQLSM.nRevnLen)
	case tcCustFld = "CPASSWD"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("x", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CECSTATUS"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("x", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "CECADDRESS"
		This.aCustProps[tnFldNum,CPROP_IMASK] = replicate("x", tnWidth)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = space(tnWidth)
	case tcCustFld = "LIOCUST"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "Y"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = .f.
	case tcCustFld = "LUSECUSITM"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "Y"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = .f.
	case tcCustFld = "MIMPTSORD"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ""
	case tcCustFld = "MIMPTSTRS"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ""
	case tcCustFld = "MIMPTINVC"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ""
	case tcCustFld = "MIMPTITRS"
		This.aCustProps[tnFldNum,CPROP_IMASK] = ""
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = ""
	case tcCustFld = "NCURRENT"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oSC.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NAGE30"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oSC.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NAGE60"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oSC.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "NAGE90"
		This.aCustProps[tnFldNum,CPROP_IMASK] = oSC.AmtPicture(tnWidth, oSQLSM.nAmtDec)
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = round(0, oSQLSM.nAmtDec)
	case tcCustFld = "LPRTINVC"
		This.aCustProps[tnFldNum,CPROP_IMASK] = "Y"
		This.aCustProps[tnFldNum,CPROP_EMPTYVAL] = .f.
*-end	1/2000 - rtp

endcase

* ----------------------------------------------------------------
FUNCTION CreateSccudfView()

	if type("_screen.ActiveForm") = "O"
		set datasession to _screen.ActiveForm.DataSessionID	
	endif	

*-begin	1/2000 - rtp - bug fix (database container not set)
	if dbused(oSQLCompany.cDBName)
		set data to (oSQLCompany.cDBName)
	endif
*-end	1/2000 - rtp - bug fix (database container not set)

	if indbc("sccudf", "view")
		delete view sccudf
	endif	

	*/Create Sql View
	lcFldList = "ccustno, "
	lnRecCount = reccount("CurNewUdf")
	if lnRecCount > 0
		select CurNewUdf
		scan for recno("CurNewUdf") < (lnRecCount - 1)
			lcFldList = lcFldList + lower(alltrim(CurNewUdf.cField)) + ","
		endscan
		select CurNewUdf
		locate for recno("CurNewUdf") = lnRecCount
		lcFldList = lcFldList + lower(alltrim(CurNewUdf.cField)) + ","
		locate for recno("CurNewUdf") = lnRecCount -1
		lcFldList = lcFldList + lower(alltrim(CurNewUdf.cField)) 
	endif
	lcFldList = alltrim(lcFldList)
	if rightc(lcFldList, 1) = ","
		lcFldList = substr(lcFldList, 1, lenc(lcFldList) -1)	
	endif
	lcFldList = lcFldList + " "
	
	create sql view sccudf remote connection AMCONNECT share as select &lcFldList from sccudf where ccustno = ?gckey1

	*/ Set View Properties
	DBSetProp('Sccudf','View', 'Comment', 'Contact File')
	DBSetProp('Sccudf','View', 'UpdateType', 1)
	DBSetProp('Sccudf', 'View', 'WhereType', 3)
	DBSetProp('Sccudf', 'View', 'FetchMemo', .T.)
	DBSetProp('Sccudf', 'View', 'SendUpdates', .T.)
	DBSetProp('Sccudf', 'View', 'UseMemoSize', 255)
	DBSetProp('Sccudf', 'View', 'FetchSize', -1)
	DBSetProp('Sccudf', 'View', 'MaxRecords', -1)
	DBSetProp('Sccudf', 'View', 'Tables', 'sccudf')
	DBSetProp('Sccudf', 'View', 'Prepared', .F.)
	DBSetProp('Sccudf', 'View', 'CompareMemo', .T.)
	DBSetProp('Sccudf', 'View', 'FetchAsNeeded', .F.)
	DBSetProp('Sccudf', 'View', 'BatchUpdateCount', 1)
	DBSetProp('Sccudf', 'View', 'ShareConnection',.t.)	
	
    */Set fields updatable
    */Always Key
	DBSetProp('sccudf.ccustno', 'Field', 'KeyField', .T.)
	DBSetProp('sccudf.ccustno', 'Field', 'Updatable', .T.)
	DBSetProp('sccudf.ccustno', 'Field', 'UpdateName', 'sccudf.ccustno')
	DBSetProp('sccudf.ccustno', 'Field', 'DataType', "C(10)")
	DBSetProp('sccudf.ccustno', 'Field', 'Caption', GetKeyCaption("Arcust.cCustNo"))
	
	select CurNewUdf
	scan
		lcField = 'sccudf.'+lower(alltrim(CurNewUdf.cField))
		DBSetProp(lcField , 'Field', 'Updatable', .T.)
		DBSetProp(lcField, 'Field', 'UpdateName', lcField)
		DBSetProp(lcField, 'Field', 'DataType', CurNewUdf.cType)
		DBSetProp(lcField, 'Field', 'Caption', CurNewUdf.cCaption)
	endscan
	
ENDFUNC
* ----------------------------------------------------------------

* ----------------------------------------------------------------
FUNCTION PreviewTicket(tlPreview, tcSoNo, tcTicketType)

InitSessionObject()
if type("tcSoNo") <> "C"
	tcSoNo = Sosord.cSoNo
endif
if !ValidTicket(tcSoNo)
	ReleaseSessionObject()
	return .f.
endif

set decimals to 8

*- BEG PRISM AA 06/16/03 - BESCO CUSTOM REPORT TO SPECIFIC PRINTER
IF (oSQLApp.Prism_clientcode == 'BE' OR oSQLApp.Prism_clientcode == 'BSC') and type('lcBesco') = 'U'
	lnBescoOpt = oSQLApp.domodalform('\sctrpt.scx')
	DO CASE
		CASE lnBescoOpt = 1 
			lcBesco = "(BATTLECREEK)"
		CASE lnBescoOpt = 2 
			lcBesco = "(LANSING)"
		CASE lnBescoOpt = 3 
			lcBesco = "(GRANDRAPID)"
		otherwise
			lcBesco = ""	
	ENDCASE
ELSE
	lcBesco = ""
ENDIF
*- END PRISM AA 06/16/03 - BESCO CUSTOM REPORT TO SPECIFIC PRINTER

*/ common report variables
lcSoNo = "(scsord.csono = '"+tcSONo+"')"
lcFilter1 = "scsord.csono = " + odbcString(tcSoNo)
*!* lcFilter1h = "scsordh.csono = " + odbcString(tcSoNo)
llAlign = ".f."
llInclItemSpec = ".t."
llVoid = ".t."
llRequest = ".f."
llInclTime = .t.
llInclUser = .t.
llSalesQuote = .f.
llSendToPrinter = !tlPreview
llPrintedForm = ""
lnSortNo = 2	&& Ticket #   
llSuppressCardNo = ".f."  && .10002818 .11/11/00
plIndividual = .t.
llDetail = .t.
llSuppColor = .f.

if oSQLApp.Prism_clientcode == 'CP'
	llPrintZero = .F.
endif

local lcCmdOpts
lcCmdOpts = iif(tlPreview, OUTPUT_TO_PREVIEW, OUTPUT_TO_PRINTER_PROMPT)
plAborted = .f.

If tcTicketType = 'DEL'
	=DoRptForm("SC_PRINTWT", lcCmdOpts)
endif

if tcTicketType = 'SVC'
	=DoRptForm("SC_PRINTST", lcCmdOpts)
endif

ReleaseSessionObject()

ENDFUNC

* ----------------------------------------------------------------

FUNCTION GetPVSCaption(tcTable, tcField)

local lcfield, lcTable

lcTable= UPPER(alltrim(tcTable))
lcField = UPPER(alltrim(tcField))

	do case 
		case lcTable == 'ARCADR' or lcTable == 'ARCADRH'
			do case
				case lcField == 'CSEDIMENT'
					return 'Sed/Sulphur'
				case lcField == 'CNITRATE'
					return 'Nitrate/Tannin'
				case lcField == 'COCCUPANTS'					
					return 'Occup/Well Depth'
				case lcField == 'CBTSIZE'	
					return 'Gal/Minute'								
				otherwise
					return alltrim(tcField)
			endcase
		otherwise
			return alltrim(tcField)
	endcase
endfunc

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


*======================================================================================
DEFINE CLASS SCEudfkey AS Emisckey

FUNCTION Init(tnUDFNo)

local lcFldName

lcFldName = oSC.UDFGetProp(tnUDFNo, UPROP_TYPE) + "UDF" + transform(tnUDFNo, "@L 99")

with This
	.PrimaryKeyValue = padr(lcFldName, UDF_MISCKEYTYPELEN)
	.KeyCaption = oSC.UDFGetProp(tnUDFNo, UPROP_CAPTION)
	
	.Text.ControlSource = "Sccudf." + lcFldName
	.Text.InputMask = oSc.UDFGetProp(tnUDFNo, UPROP_IMASK)

	.CmdSrh.Left = .Text.Width - 1
	.Width = .CmdSrh.Width + .Text.Width
endwith

ENDFUNC
* ----------------------------------------------------------------

FUNCTION Text.KeyPress(nKeyCode, nShiftAltCtrl)

if nKeyCode = F4_KEY
	This.Parent.CmdSrh.Click()
	nodefault
	return
endif

if inlist(nKeyCode, TAB, ENTER)
	do case
		case !RefreshSqlView("Scmisc", This.Parent.PrimaryKeyValue ,This.Value)
			This.ErrorMessage()
			nodefault
			This.SetFocus()
			return .f.
	endcase
endif

ENDFUNC
* ----------------------------------------------------------------

FUNCTION CmdSrh.Click()

local lnRecNo

with This.Parent
	lcKeyId = oSQLApp.DoModalForm("SCSMISC.SCX", .Text.Value, .PrimaryKeyValue, ;
		.KeyCaption)
	if type("lcKeyId") = "C"
		.Text.Value = lcKeyId
	endif	
	.Text.SetFocus()
endwith

ENDFUNC
* ----------------------------------------------------------------

ENDDEFINE

*======================================================================================

DEFINE CLASS SCEyesno AS Ecbo

#define EYESNO_YES "Yes"
#define EYESNO_NO  "No"

dimension aYesNo[2]

aYesNo[1] = EYESNO_YES
aYesNo[2] = EYESNO_NO

cCtrlSource = ""
RowSourceType = 5	&& Array
RowSource = "This.aYesNo"
Value = ""
Width = 45

BoundColumn = 2
DisplayValue = 1

* ----------------------------------------------------------------

FUNCTION Init()
	
	dimension This.aYesNo[2,2]

	This.aYesNo[1,1] = AmTran(EYESNO_YES)
	This.aYesNo[2,1] = AmTran(EYESNO_NO)
	This.aYesNo[1,2] = EYESNO_YES
	This.aYesNo[2,2] = EYESNO_NO
				
ENDFUNC
* ----------------------------------------------------------------


FUNCTION InteractiveChange()
	if (upper(This.Value) = upper(EYESNO_YES)) <> IsTrue(evaluate(This.cCtrlSource))
		replace (This.cCtrlSource) with LogicalToInt(IsTrue(upper(This.Value) = upper(EYESNO_YES))) ;
			in (leftc(This.cCtrlSource, at_c(".", This.cCtrlSource) - 1))
	endif
ENDFUNC
* ----------------------------------------------------------------

FUNCTION ProgrammaticChange()
	This.InteractiveChange()
ENDFUNC
* ----------------------------------------------------------------

FUNCTION Refresh()
	Ecbo::Refresh()
	This.Requery()
ENDFUNC
* ----------------------------------------------------------------

FUNCTION Requery()
	if 	IsTrue(evaluate(This.cCtrlSource))
		if upper(This.Value) <> upper(EYESNO_YES)
			This.Value = EYESNO_YES
		endif
	else
		if upper(This.Value) <> upper(EYESNO_NO)
			This.Value = EYESNO_NO
		endif
	endif
ENDFUNC
* ----------------------------------------------------------------
ENDDEFINE

#undef EYESNO_YES
#undef EYESNO_NO
*======================================================================================

DEFINE CLASS SCEPdlbl AS Edlbl

PROTECTED cType

cType = ""

FUNCTION Init(tcType)
	dodefault()
	This.cType = tcType
ENDFUNC

FUNCTION drilldown()
	oSQLApp.DoModalForm("SCMMISC.SCX", This.cType)
ENDFUNC




ENDDEFINE

*======================================================================================
