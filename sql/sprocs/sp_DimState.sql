USE [green_nault]
GO

/****** Object:  StoredProcedure [dbo].[sp_DimState]    Script Date: 4/24/2026 4:14:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

USE [green_nault]
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_DimDate]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StartDate  date;
    DECLARE @CutoffDate date;

    -- Compute min/max across BOTH Filed and Reflecting week dates
    SELECT
        @StartDate  = MIN(MinDate),
        @CutoffDate = MAX(MaxDate)
    FROM
    (
        SELECT
            MIN(CAST([Filed week ended]        AS date)) AS MinDate,
            MAX(CAST([Filed week ended]        AS date)) AS MaxDate
        FROM [green_nault].[dbo].[Raw_Unemployment] WITH (NOLOCK)

        UNION ALL

        SELECT
            MIN(CAST([Reflecting Week Ended]   AS date)) AS MinDate,
            MAX(CAST([Reflecting Week Ended]   AS date)) AS MaxDate
        FROM [green_nault].[dbo].[Raw_Unemployment] WITH (NOLOCK)
    ) d;

    -- Safety buffer (optional)
    SET @StartDate  = DATEADD(DAY, -7, @StartDate);
    SET @CutoffDate = DATEADD(DAY,  7, @CutoffDate);

    DROP TABLE IF EXISTS [dbo].[DimDate];

    CREATE TABLE [dbo].[DimDate]
    (
         TheDate        date          NOT NULL
        ,TheDay         int           NULL
        ,TheDayName     nvarchar(100) NULL
        ,TheWeek        int           NULL
        ,TheISOWeek     int           NULL
        ,TheDayOfWeek   int           NULL
        ,TheMonth       int           NULL
        ,TheMonthName   nvarchar(100) NULL
        ,TheQuarter     int           NULL
        ,TheYear        int           NULL
        ,TheFirstOfMonth date         NULL
        ,TheLastOfYear   date         NULL
        ,TheDayOfYear    int          NULL
        ,CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (TheDate)
    );

    ;WITH seq(n) AS
    (
        SELECT 0
        UNION ALL
        SELECT n + 1
        FROM seq
        WHERE n <= DATEDIFF(DAY, @StartDate, @CutoffDate)
    ),
    d(d) AS
    (
        SELECT DATEADD(DAY, n, @StartDate) FROM seq
    ),
    src AS
    (
        SELECT
             TheDate        = CONVERT(date, d)
            ,TheDay         = DATEPART(DAY, d)
            ,TheDayName     = DATENAME(WEEKDAY, d)
            ,TheWeek        = DATEPART(WEEK, d)
            ,TheISOWeek     = DATEPART(ISO_WEEK, d)
            ,TheDayOfWeek   = DATEPART(WEEKDAY, d)
            ,TheMonth       = DATEPART(MONTH, d)
            ,TheMonthName   = DATENAME(MONTH, d)
            ,TheQuarter     = DATEPART(Quarter, d)
            ,TheYear        = DATEPART(YEAR, d)
            ,TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1)
            ,TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31)
            ,TheDayOfYear    = DATEPART(DAYOFYEAR, d)
        FROM d
    )

    INSERT INTO [dbo].[DimDate]
    SELECT *
    FROM src
    ORDER BY TheDate
    OPTION (MAXRECURSION 0);

END
GO
--CREATE or alter  PROCEDURE [dbo].[sp_DimState]
--AS
--/************
--*Developer: Tim Pauley
--*Date: 04/02/2024
--*Description: Store Procedure for Dim State
--***************/

--DROP TABLE IF EXISTS [dbo].[DimState]

--CREATE TABLE [dbo].[DimState]
--(
--	DimState_Key int IDENTITY (1,1) --future Surrogate Key
--	,State nvarchar(50)
--	,CONSTRAINT PK_DimState PRIMARY KEY CLUSTERED ([State])
--)


--INSERT INTO [dbo].[DimState]
--SELECT DISTINCT 
--	[State]
--FROM [green_nault].[dbo].[Raw_Unemployment] WITH (NOLOCK)
--UNION
--    SELECT DISTINCT RAW.[admin_region_1] AS [State]
--    FROM [green_nault].[dbo].[bing-covid-dataset] RAW WITH (NOLOCK)
--    WHERE RAW.[admin_region_1] IS NOT NULL; 

--GO


