USE [green_nault]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************
*Developer: JNault
*Date: 04/24/2026
*Description: Fact Immunizations sample script
exec [dbo].[sp_FactImmunizations]
**************/
CREATE OR ALTER PROCEDURE [dbo].[sp_FactImmunizations]
AS
BEGIN

DROP TABLE IF EXISTS [dbo].[FactImmunizations]

CREATE TABLE [dbo].[FactImmunizations]
(
    FactImmunizations_Key int IDENTITY (1,1)
  , [Date] date
  , [State] nvarchar(50)
  , [Administered_Dose1_Recip] int
  , [Administered_Dose1_Pop_Pct] float
  , [Series_Complete_Yes] int
  , [Series_Complete_Pop_Pct] float
  , [Booster_Doses] int
  , [Booster_Doses_Vax_Pct] float
  , [Metro_status] nvarchar(50)
  , [Census2019] int
  , CONSTRAINT PK_FactImmunizations PRIMARY KEY CLUSTERED (FactImmunizations_Key)
  , CONSTRAINT FK_FactImmunizations_DimState
      FOREIGN KEY ([State]) REFERENCES [dbo].[DimState]([State])
  , CONSTRAINT FK_FactImmunizations_DimDate
      FOREIGN KEY ([Date]) REFERENCES [dbo].[DimDate]([TheDate])
)

INSERT INTO [dbo].[FactImmunizations]
SELECT
    CAST([Date] as date) as [Date]
  , [Recip_State] as [State]
  , CAST(REPLACE([Administered_Dose1_Recip], ',', '') as int)	as [Administered_Dose1_Recip]
  , CAST([Administered_Dose1_Pop_Pct] as float)					as [Administered_Dose1_Pop_Pct]
  , CAST(REPLACE([Series_Complete_Yes], ',', '') as int)		as [Series_Complete_Yes]
  , CAST([Series_Complete_Pop_Pct] as float)					as [Series_Complete_Pop_Pct]
  , CAST(REPLACE([Booster_Doses], ',', '') as int)				as [Booster_Doses]
  , CAST([Booster_Doses_Vax_Pct] as float)						as [Booster_Doses_Vax_Pct]
  , [Metro_status]
  , CAST(REPLACE([Census2019], ',', '') as int)					as [Census2019]
FROM [green_nault].[dbo].[Raw_Immunizations] RAW WITH (NOLOCK)

END
GO