USE [green_nault]
GO

/****** Object:  StoredProcedure [dbo].[sp_DimDate]    Script Date: 4/24/2026 4:15:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE or alter PROCEDURE [dbo].[sp_DimDate]
	AS
/**************
*Developer: Tim Pauley
*Date: 04/02/2024
********************/
		BEGIN
		DECLARE @StartDate  date = '20200101'; 
		
		DECLARE @CutoffDate date = GETDATE(); 
		
		DROP TABLE IF EXISTS DimDate
		CREATE TABLE DimDate
		(
		    TheDate date
		    ,TheDay int
		    ,TheDayName nvarchar(100)
		    ,TheWeek  int
		    ,TheISOWeek int
		    ,TheDayOfWeek int
		    ,TheMonth int
		    ,TheMonthName nvarchar(100)
		    ,TheQuarter int
		    ,TheYear int
		    ,TheFirstOfMonth date
		    ,TheLastOfYear date
		    ,TheDayOfYear int
			,CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED (TheDate)
		)
		
		;WITH seq(n) AS 
		(
		  SELECT 0 UNION ALL SELECT n + 1 FROM seq
		  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
		),
		d(d) AS 
		(
		  SELECT DATEADD(DAY, n, @StartDate) FROM seq
		),
		src AS
		(
		  SELECT
		    TheDate         = CONVERT(date, d),
		    TheDay          = DATEPART(DAY,       d),
		    TheDayName      = DATENAME(WEEKDAY,   d),
		    TheWeek         = DATEPART(WEEK,      d),
		    TheISOWeek      = DATEPART(ISO_WEEK,  d),
		    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
		    TheMonth        = DATEPART(MONTH,     d),
		    TheMonthName    = DATENAME(MONTH,     d),
		    TheQuarter      = DATEPART(Quarter,   d),
		    TheYear         = DATEPART(YEAR,      d),
		    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
		    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
		    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
		  FROM d
		)
		
		INSERT INTO DimDate
		SELECT * FROM src
		  ORDER BY TheDate
		  OPTION (MAXRECURSION 0);
	END
GO


