USE [master]
GO
/****** Object:  Database [Events]    Script Date: 5/06/2014 4:40:51 PM ******/
CREATE DATABASE [Events]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Events', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Events.mdf' , SIZE = 12288KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Events_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Events_log.ldf' , SIZE = 76736KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Events] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Events].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Events] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Events] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Events] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Events] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Events] SET ARITHABORT OFF 
GO
ALTER DATABASE [Events] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Events] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Events] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Events] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Events] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Events] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Events] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Events] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Events] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Events] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Events] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Events] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Events] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Events] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Events] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Events] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Events] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Events] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Events] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Events] SET  MULTI_USER 
GO
ALTER DATABASE [Events] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Events] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Events] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Events] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Events]
GO
/****** Object:  UserDefinedTableType [dbo].[Dict_Int_Date]    Script Date: 5/06/2014 4:40:52 PM ******/
CREATE TYPE [dbo].[Dict_Int_Date] AS TABLE(
	[Key] [int] NULL,
	[Value] [datetime] NULL
)
GO
/****** Object:  StoredProcedure [dbo].[AddAlert]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[AddAlert]
(@EventLevelValue int,
@PeriodValue int,
@PeriodType smallint,
@Value int,
@NotificationType smallint,
@Target varchar(255),
@AppId bigint
)
as

insert into Alerts (EventLevelValue, PeriodValue, PeriodType, Value, NotificationType, [Target], AppId)
values (@EventLevelValue, @PeriodValue, @PeriodType, @Value, @NotificationType, @Target,@AppId)

select CAST(SCOPE_IDENTITY() AS INT) AS Id

GO
/****** Object:  StoredProcedure [dbo].[AddAppUser]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AddAppUser]
@appId bigint,
@userId bigint,
@roleId int
as

insert into [AppUser]  (AppId, UserId, RoleId) 
values (@appId, @userId,@roleId)


GO
/****** Object:  StoredProcedure [dbo].[ConfirmUser]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[ConfirmUser]
@activationKey varchar(100)
as

	update [user] 
	set active =1
	where activationkey = @activationKey

	select * from [user] 
	where activationkey = @activationKey

GO
/****** Object:  StoredProcedure [dbo].[CreateApplication]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CreateApplication]
@name varchar(100),
@appKey varchar(16),
@retentionDays int,
@fatals int,
@errors int,
@warnings int,
@active bit = 1
as

insert into Applications (AppName, AppKey, [Enabled], DefaultRetainPeriodDays, MaxFatalErrors, [MaxErrors], MaxWarnings)
values (@name, @appKey, @active, @retentionDays, @fatals, @errors, @warnings)

select CAST(SCOPE_IDENTITY() as bigint) as Id, @name as AppName, @appKey as AppKey, @active as Enabled, @retentionDays as DefaultRetainPeriodDays, @fatals as MaxFatalErrors, @errors as MaxErrors, @warnings as MaxWarnings

GO
/****** Object:  StoredProcedure [dbo].[CreateUser]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CreateUser]

@UserName varchar(100),
@Password varchar(100),
@ActivationKey varchar(100),
@PasswordSalt varchar(100)
as

  insert into [user]
  (username, [password], [PasswordSalt], [active], activationKey)
  values
  (@UserName, @Password, @PasswordSalt, 0, @ActivationKey)

  select SCOPE_IDENTITY()

GO
/****** Object:  StoredProcedure [dbo].[GetAlerts]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetAlerts]
@appId bigint
as

	select Id , EventLevelValue, PeriodValue, PeriodType, Value, [Target], NotificationType, AppId , LastExecutionTime
	
	from Alerts
	with (nolock)
	where AppId=@appId
	order by id

GO
/****** Object:  StoredProcedure [dbo].[GetAllApps]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetAllApps]
as

	select   Id, AppName,AppKey, Enabled, DefaultRetainPeriodDays, MaxFatalErrors, MaxErrors, MaxWarnings
	from Applications
	with (nolock)

GO
/****** Object:  StoredProcedure [dbo].[GETAPPEVENTS]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GETAPPEVENTS]
(
@APPID BIGINT,
@PAGENUMBER int, 
@PAGESIZE int,
@KEYWORD VARCHAR(100) = NULL,
@Fdate DateTime,
@ToDate DateTime,
@EVENTLEVEL  INT 
)
AS

	DECLARE @EventLeveTypes TABLE
	(
		Id int
	)

	insert into @EventLeveTypes
	select [Id] from EventLevel as E where @EVENTLEVEL & [Id] = [Id]
	

	set @KEYWORD = dbo.Base64Decode(isnull(@KEYWORD,''))
	DECLARE @DailyRetainPeriodDays int

	SELECT @DailyRetainPeriodDays = A.DefaultRetainPeriodDays
	FROM APPLICATIONS AS A WITH (NOLOCK) WHERE ID = @APPID AND A.Enabled=1
	

	DECLARE @CURRENTDATE DATETIME = GetUtcDate()
	DECLARE @FROMDATE DATETIME = DATEADD(DAY, -1*@DailyRetainPeriodDays, @CURRENTDATE);

	-- The FROM DATE cannot be before the date retention date. Like if we keep the data for 30 days only, we cannot get events since 60 days ago.
	IF @FDATE < @FROMDATE
	BEGIN
		SET @Fdate = @FROMDATE
	END

	SELECT   TOP 5 [MESSAGE], COUNT(1) AS CNT FROM EVENTS
	WITH (NOLOCK)
	WHERE  ApplicationId=@APPID AND TimeCreated >= @FROMDATE  and EventLevel=1
	GROUP BY [MESSAGE];


WITH CTE AS
	(
		SELECT ROW_NUMBER() OVER (ORDER BY ID) AS ROWNUMBER,* FROM EVENTS AS E
		WITH (NOLOCK)
		WHERE  E.ApplicationId=@APPID AND TimeCreated >= @FROMDATE AND E.PARENTID IS NULL 
		AND (ISNULL(@KEYWORD,'')=''  OR (E.Message LIKE '%' +@KEYWORD+'%'  OR E.Description LIKE '%' +@KEYWORD+'%'))
		AND eventlevel in (select distinct Id from  @EventLeveTypes)
		AND e.TimeCreated >=@Fdate AND e.TimeCreated <=@ToDate
	)
	SELECT * FROM CTE
	WHERE ROWNUMBER BETWEEN @PAGENUMBER*@PAGESIZE  AND (@PAGENUMBER+1)*@PAGESIZE
	ORDER BY [Id] DESC
	


GO
/****** Object:  StoredProcedure [dbo].[GetApplication]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetApplication]
@AppKey varchar(36)
as
	select top 1 * from Applications
	where [AppKey]=@AppKey

GO
/****** Object:  StoredProcedure [dbo].[GetApplicationById]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetApplicationById]
@Id varchar(36)
as
	select top 1 * from Applications
	where [Id]=@id

GO
/****** Object:  StoredProcedure [dbo].[GetAppStatus]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetAppStatus]
@AppId int
as

	DECLARE @retainDays int
	SELECT @retainDays = [DefaultRetainPeriodDays] 
	From Applications
	WHERE Id=@AppId

	
	DECLARE @FatalCount int
	DECLARE @ErrorCount int
	DECLARE @WarningCount int

	select @FatalCount = count(1)  from Events as E where ApplicationId = @AppId and EventLevel = 1  and DateAdd(day, -1*@retainDays,getutcdate()) <=  E.TimeCreated

	select @ErrorCount = count(1)  from Events as E where ApplicationId = @AppId and EventLevel = 2 and DateAdd(day, -1*@retainDays,getutcdate()) <=  E.TimeCreated

	select @WarningCount=count(1)  from Events as E where ApplicationId = @AppId and EventLevel = 4 and DateAdd(day, -1*@retainDays,getutcdate()) <=  E.TimeCreated

	Select @FatalCount as FatalCount, @ErrorCount as ErrorCount, @WarningCount as WarningCount, MaxFatalErrors, [MaxErrors], MaxWarnings, DefaultRetainPeriodDays
	From Applications
	WHERE Id=@AppId

GO
/****** Object:  StoredProcedure [dbo].[GetAppUser]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetAppUser] 
@appId bigint
as
	select U.id as UserId, AU.RoleId from AppUser as AU
	inner join  [User] as U
	on AU.UserId = U.id 
	where AU.AppId = @Appid

GO
/****** Object:  StoredProcedure [dbo].[GetChildEvents]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetChildEvents]
@Id bigint
as
begin
  SELECT TOP 1 [Id]
      ,[ProviderName]
      ,[EventLevel]
      ,[Keywords]
      ,[TimeCreated]
      ,[ParentId]
      ,[ComputerName]
      ,[IpAddress]
      ,[UserAgent]
      ,[Message]
      ,[Description]
      ,[ExtendedInformation]
      ,[ApplicationId]
  FROM [events].[dbo].[Events]
  WHERE [ParentId] = @Id
end
GO
/****** Object:  StoredProcedure [dbo].[GetEventById]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetEventById]
@Id bigint
as
begin
  SELECT TOP 1 [Id]
      ,[ProviderName]
      ,[EventLevel]
      ,[Keywords]
      ,[TimeCreated]
      ,[ParentId]
      ,[ComputerName]
      ,[IpAddress]
      ,[UserAgent]
      ,[Message]
      ,[Description]
      ,[ExtendedInformation]
      ,[ApplicationId]
  FROM [events].[dbo].[Events]
  WHERE [Id] = @Id
end
GO
/****** Object:  StoredProcedure [dbo].[GetEventTrendOfApp]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[GetEventTrendOfApp]
@AppId int
as

	DECLARE @retainDays int
	SELECT @retainDays = [DefaultRetainPeriodDays] 
	From Applications
	WHERE Id=@AppId

	SELECT  [TimeCreated] , Count(1) as FatalCount
	from Events as E 
	where ApplicationId = @AppId and EventLevel =1
	and DateAdd(day, -1*@retainDays,getutcdate()) <=  E.TimeCreated
		group by [TimeCreated]
	order by [TimeCreated]


	SELECT  [TimeCreated] , Count(1) as ErrorCount
	from Events as E 
	where ApplicationId = @AppId and EventLevel = 2
	and DateAdd(day, -1*@retainDays,getutcdate()) <=  E.TimeCreated
	group by [TimeCreated]
	order by [TimeCreated]


	SELECT  [TimeCreated] , Count(1) as WarningCount
	from Events as E 
	where ApplicationId = @AppId and EventLevel = 4
	and DateAdd(day, -1*@retainDays,getutcdate()) <=  E.TimeCreated
	group by [TimeCreated]
	order by [TimeCreated]


GO
/****** Object:  StoredProcedure [dbo].[GETUSERBYID]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GETUSERBYID]
@ID BIGINT
AS

 SELECT TOP 1 ID, USERNAME, [PASSWORD], [PASSWORDSALT], ACTIVE, ACTIVATIONKEY
 FROM [USER]
 WITH (NOLOCK)
 WHERE ID=@ID


GO
/****** Object:  StoredProcedure [dbo].[GETUSERBYNAME]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[GETUSERBYNAME]
@USERNAME varchar(100)
AS

 SELECT TOP 1 ID, USERNAME, [PASSWORD], [PASSWORDSALT], ACTIVE, ACTIVATIONKEY
 FROM [USER]
 WITH (NOLOCK)
 WHERE USERNAME=@USERNAME


GO
/****** Object:  StoredProcedure [dbo].[RegisterEvent]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[RegisterEvent]
(
@Providername varchar(100),
@EventLevel smallint,
@Keywords varchar(100),
@ParentId bigint = null,
@ComputerName varchar(100),
@IpAddress varchar(100),
@UserAgent varchar(200),
@Message varchar(100),
@Description varchar(max),
@ExtendedInformation varchar(max),
@ApplicationId bigint
)

as

	INSERT INTO EVENTS
	(Providername, EventLevel, Keywords, ParentId, ComputerName, IpAddress, UserAgent, [Message], [Description],
	ExtendedInformation, ApplicationId, TimeCreated)
	values (@Providername, @EventLevel, @Keywords, @ParentId, @ComputerName, @IpAddress, @UserAgent, @Message, 
	@Description, @ExtendedInformation, @ApplicationId, getutcdate())

	SELECT SCOPE_IDENTITY()


GO
/****** Object:  StoredProcedure [dbo].[UpdateAlertExecTimes]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  proc [dbo].[UpdateAlertExecTimes]
@updateTimes  Dict_Int_Date READONLY
as

select * from alerts

Update A
SET A.LastExecutionTime = B.Value
From @updateTimes as B
Inner Join Alerts as A
On A.id = B.[Key]

GO
/****** Object:  StoredProcedure [dbo].[UpdateApplication]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[UpdateApplication]
@name varchar(100),
@appKey varchar(16),
@retentionDays int,
@fatals int,
@errors int,
@warnings int,
@active int = 1
as

declare @id bigint 
select @id = id from Applications where AppKey=@appKey

if @id is not null
begin
	update Applications
	set AppName = @name, [Enabled]=@active, DefaultRetainPeriodDays= @retentionDays, MaxFatalErrors=@fatals, MaxErrors= @errors, MaxWarnings=@warnings 
	where id =@id
end

	select top 1 * from Applications where id=@id

GO
/****** Object:  UserDefinedFunction [dbo].[Base64Decode]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Base64Decode] ( @Input NVARCHAR(MAX) )

RETURNS VARCHAR(MAX)
BEGIN

DECLARE @DecodedOutput VARCHAR(MAX)

set @DecodedOutput = CAST(CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@Input"))', 'varbinary(max)') AS NVARCHAR(MAX))

RETURN @DecodedOutput

END


GO
/****** Object:  Table [dbo].[Alerts]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Alerts](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[EventLevelValue] [int] NOT NULL,
	[PeriodValue] [int] NOT NULL,
	[PeriodType] [smallint] NOT NULL,
	[Value] [int] NOT NULL,
	[Target] [varchar](255) NOT NULL,
	[NotificationType] [smallint] NOT NULL,
	[AppId] [bigint] NOT NULL,
	[LastExecutionTime] [datetime] NULL,
 CONSTRAINT [PK_Alerts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Applications]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Applications](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[AppName] [varchar](100) NOT NULL,
	[AppKey] [varchar](36) NULL,
	[Enabled] [bit] NULL,
	[DefaultRetainPeriodDays] [int] NULL,
	[MaxFatalErrors] [int] NULL,
	[MaxErrors] [int] NULL,
	[MaxWarnings] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppUser]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser](
	[AppId] [bigint] NOT NULL,
	[UserId] [bigint] NOT NULL,
	[RoleId] [int] NULL,
 CONSTRAINT [PK_AppUser] PRIMARY KEY CLUSTERED 
(
	[AppId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EventLevel]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EventLevel](
	[Id] [smallint] NOT NULL,
	[Name] [varchar](20) NOT NULL,
 CONSTRAINT [PK_EventType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Events]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Events](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ProviderName] [varchar](100) NOT NULL,
	[EventLevel] [smallint] NOT NULL,
	[Keywords] [varchar](100) NULL,
	[TimeCreated] [smalldatetime] NOT NULL,
	[ParentId] [bigint] NULL,
	[ComputerName] [varchar](100) NULL,
	[IpAddress] [varchar](40) NULL,
	[UserAgent] [varchar](200) NULL,
	[Message] [varchar](100) NULL,
	[Description] [varchar](max) NULL,
	[ExtendedInformation] [varchar](max) NULL,
	[ApplicationId] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Roles](
	[id] [int] NOT NULL,
	[RoleName] [varchar](100) NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[User]    Script Date: 5/06/2014 4:40:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[User](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[username] [varchar](100) NOT NULL,
	[password] [varchar](100) NOT NULL,
	[active] [bit] NOT NULL,
	[activationKey] [varchar](100) NOT NULL,
	[passwordSalt] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [IX_Events_ParentId]    Script Date: 5/06/2014 4:40:52 PM ******/
CREATE NONCLUSTERED INDEX [IX_Events_ParentId] ON [dbo].[Events]
(
	[ParentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IDX_USER_USERNAME]    Script Date: 5/06/2014 4:40:52 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_USER_USERNAME] ON [dbo].[User]
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT ((30)) FOR [DefaultRetainPeriodDays]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT ((20)) FOR [MaxFatalErrors]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT ((100)) FOR [MaxErrors]
GO
ALTER TABLE [dbo].[Applications] ADD  DEFAULT ((100)) FOR [MaxWarnings]
GO
ALTER TABLE [dbo].[User] ADD  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [FK_AppUser_Applications] FOREIGN KEY([AppId])
REFERENCES [dbo].[Applications] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [FK_AppUser_Applications]
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [FK_AppUser_Roles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([id])
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [FK_AppUser_Roles]
GO
ALTER TABLE [dbo].[AppUser]  WITH CHECK ADD  CONSTRAINT [FK_AppUser_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[User] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AppUser] CHECK CONSTRAINT [FK_AppUser_User]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[Applications] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_Applications]
GO
ALTER TABLE [dbo].[Events]  WITH CHECK ADD  CONSTRAINT [FK_Events_EventLevel] FOREIGN KEY([EventLevel])
REFERENCES [dbo].[EventLevel] ([Id])
GO
ALTER TABLE [dbo].[Events] CHECK CONSTRAINT [FK_Events_EventLevel]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0= Hour, 1= Day, 2=Week' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Alerts', @level2type=N'COLUMN',@level2name=N'id'
GO
USE [master]
GO
ALTER DATABASE [Events] SET  READ_WRITE 
GO
