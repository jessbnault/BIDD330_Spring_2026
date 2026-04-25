USE [green_nault]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE or alter PROCEDURE [dbo].[sp_FactUnemployment]
AS

DROP TABLE IF EXISTS [dbo].[FactUnemployment]

CREATE TABLE [dbo].[FactUnemployment]
(
	FactUnemployment_Key int IDENTITY (1,1) --future Surrogate Key
	, [State] nvarchar(50)
	, [Filed week ended] date
	, [Initial Claims] int
	, [Reflecting Week Ended] date
	, [Continued Claims] int
	, [Covered Employment] int
	, [Insured Unemployment Rate] float
	,CONSTRAINT PK_FactUnemployment PRIMARY KEY CLUSTERED (FactUnemployment_Key)

        ,CONSTRAINT FK_FactUnemployment_DimState
             FOREIGN KEY ([State])
             REFERENCES [dbo].[DimState]([State])

        ,CONSTRAINT FK_FactUnemployment_FiledWeek_DimDate
             FOREIGN KEY ([Filed week ended])
             REFERENCES [dbo].[DimDate](TheDate)

        -- Optional: also tie Reflecting Week to DimDate
        ,CONSTRAINT FK_FactUnemployment_ReflectingWeek_DimDate
             FOREIGN KEY ([Reflecting Week Ended])
             REFERENCES [dbo].[DimDate](TheDate)
)

INSERT INTO [dbo].[FactUnemployment]
SELECT  
	[State]
	, CAST([Filed week ended] as date)				as [Filed week ended]
	, CAST([Initial Claims] as INT)					as [Initial Claims]
	, CAST([Reflecting Week Ended] as date)			as [Reflecting Week Ended]
	, CAST([Continued Claims] as INT)				as [Continued Claims]
	, CAST([Covered Employment] as INT)				as [Covered Employment]
	, CAST([Insured Unemployment Rate] as float)	as [Insured Unemployment Rate]
FROM [green_nault].[dbo].[Raw_Unemployment] RAW WITH (NOLOCK)
GO


