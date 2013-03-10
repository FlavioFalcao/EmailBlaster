/*2012-03-12 Accountmate Email Blaster new tables*/
--Job List Table
--drop table scbllist
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scbllist'))   
CREATE TABLE scbllist(
	cuid char(15)  not null default '',
	tTimeStamp datetime ,	
	cJobType char(15) not null default  '',
	cDocNum char (10) not null default '',
	cCustNo char(10) not null default '',
	cTableName char(30) not null default '',
	cStatus char(1) not null default '',
	cFileName char(150) not null default '',
	cStatMsg char(60) not null default ''      
 CONSTRAINT PK_scbllist PRIMARY KEY CLUSTERED 
(
      cuid ASC,
      tTimeStamp ASC
)
) 

--trigger for deleted record get rid of on other tables
--drop trigger scbllist_delete
CREATE TRIGGER scbllist_delete ON scbllist
FOR DELETE
AS
begin
	/*if no records left in scbllist for that table, then delete record in scblcache  */
	/*therefore deleting also cache table */
	delete scblcache 
	where cTableName not in (select cTableName from scbllist)

END


--Log Table
--drop table scbllog
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scbllog'))   
CREATE TABLE scbllog(
	cuid char(15)  NOT NULL DEFAULT '',
	tTimeStamp datetime ,	
	cJobType char(15) NOT NULL DEFAULT '',
	cPdfType char(1) NOT NULL DEFAULT '',
	cDocNum char (10) NOT NULL Default '',
	cCustNo char(10) NOT NULL Default '',
	cEmail varchar(250) NOT NULL Default '',
	cFax char(20) NOT NULL Default '',
	cEnterBy char(30) not null default '',
	lError smallint NOT NULL DEFAULT 0,
	lSystem smallint NOT NULL DEFAULT 0,
	cTableName char(30) not null default '',	
	mComment text NULL
 CONSTRAINT PK_scbllog PRIMARY KEY CLUSTERED 
(
      cuid ASC,
      tTimeStamp ASC
)
) 


--Config Table
--drop table scblsys
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scblsys'))
CREATE TABLE scblsys(
	csmtp char(150)  NOT NULL DEFAULT '',
	cSmtpUsr char(150)NOT NULL DEFAULT '',
	cSmtpPwd char(150)NOT NULL DEFAULT '',
	cSmtpPort Numeric (5,0) NOT NULL DEFAULT 0,
	lSmtpUseAuth smallint NOT NULL DEFAULT 0,
	lSmtpUseSSL smallint NOT NULL DEFAULT 0,
	cESubCode char(10) NULL DEFAULT '',
	cFSubCode char(10) NULL DEFAULT '',
	cPathPdf char(100) NOT NULL DEFAULT '',
	dLastGenerate datetime,
	dLastSend datetime,
	lCombine smallint NOT NULL DEFAULT 0,
	cCombineField char(10) NOT NULL DEFAULT '',
	cFromCompany char(40) NOT NULL DEFAULT '',
	cFromName char (40) NOT NULL DEFAULT '',
	cFromEmail char(200) NOT NULL DEFAULT '',
	cFaxEmail char(200) NOT NULL DEFAULT '',
	lCCUser smallint NOT NULL DEFAULT 0,
	nKeepLog numeric(3,0) NOT NULL DEFAULT 0,
	lUseTempGrid smallint NOT NULL DEFAULT 0,
	nThrottle numeric(2,0) NOT NULL DEFAULT 0,
	cPrinter char(100) NOT NULL DEFAULT ''
)  
insert into scblsys (csmtp, nKeepLog) values ('this.server.com', 60)  


--Email Template Table
--drop table scblETemp
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scblESub'))
CREATE TABLE scblETemp(
	cuid char(15)  NOT NULL DEFAULT '',
	cSubCode char(10)  NOT NULL DEFAULT '',
	cSubDescr char(254) NOT NULL DEFAULT '',
	mBody	text null
 CONSTRAINT PK_scblESub PRIMARY KEY CLUSTERED 
(
      cuid ASC,
      cSubCode ASC
)
)       

--Fax Template Table
--drop table scblFTemp
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scblFTemp'))
CREATE TABLE scblFTemp(
	cuid char(15)  NOT NULL DEFAULT '',
	cSubCode char(10)  NOT NULL DEFAULT '',
	cSubDescr char(254) NOT NULL DEFAULT '',
	mBody	text null
 CONSTRAINT PK_scblFSub PRIMARY KEY CLUSTERED 
(
      cuid ASC,
      cSubCode ASC
)
)  

--Recordset Stored Proc Parameters System Table
--drop table scblParams
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scblParams'))
CREATE TABLE scblParams(
	cTableName char(30) default '',
	cDocNumFrom char(30) default '', 
	cDocNumTo char(30) default '', 
	cSearchField char(20) default '',
	cOrderBy char(20) default ''
)  

--cached data table
--drop table scblCache
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scblCache'))
CREATE TABLE scblCache(
	cuid char(15) NOT NULL,
	dCreate datetime NULL,
	cTableName char(30) NOT NULL,
	cEnterBy char(30) not null default '',
	cParameters Varchar(2000) NOT NULL,
	cSearchField char(20) default '',
	cReport char(20) default '',
	cStoredProc char(30) default ''
	)
GO
--trigger for deleted record get rid of table
--drop trigger scblCache_delete
CREATE TRIGGER scblCache_delete ON scblcache
FOR DELETE
AS
begin
	/*if record is deleted from scblcache drop cache table*/
	declare @lcSqlCmd varchar(1000), @lcTableName char(30), @curCache cursor
	set @lcSqlCMD = ''

	set @curCache = cursor fast_forward for
		select cTableName
		from deleted
	open @curCache

	fetch next from @curCache into @lcTableName
	while @@fetch_status = 0
	BEGIN	
		set @lcSqlCMD = ' drop table ' + ltrim(rtrim(@lcTableName))
		execute (@lcSqlCmd)
		
		fetch next from @curCache into @lcTableName
	END
	close @curCache
	deallocate @curcache
END
GO

--Email and Fax template conditional grid
--drop table scblTmpGrd
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scblTmpGrd'))
CREATE TABLE scblTmpGrd(
	cuid char(15)  NOT NULL DEFAULT '',
	cJobType char (15) NOT NULL Default '',
	cEmlCode char(10)  NOT NULL DEFAULT '',
	cFaxCode char(10)  NOT NULL DEFAULT ''
	)  
	
--Job type List
--drop table scbljbTpe
IF not exists(select name from sysobjects where objectproperty(id,'istable') = 1 and objectproperty(id,'isusertable') = 1 
   and id = object_id('scbljbTpe'))
CREATE TABLE scbljbTpe(
	cuid char(15)  NOT NULL DEFAULT '',
	cJobType char (15) NOT NULL Default ''
	)  	