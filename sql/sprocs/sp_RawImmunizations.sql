USE [green_nault]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************
*Developer: JNault
*Date: 04/24/2026
*Description: Raw Immunizations
exec [dbo].[sp_RawImmunizations]
**************/
CREATE OR ALTER PROCEDURE [dbo].[sp_RawImmunizations]
AS
BEGIN

DROP TABLE IF EXISTS [dbo].[Raw_Immunizations]

CREATE TABLE [dbo].[Raw_Immunizations]
(
    [Date] nvarchar(50)
  , [Recip_State] nvarchar(50)
  , [Administered_Dose1_Recip] nvarchar(50)
  , [Administered_Dose1_Pop_Pct] nvarchar(50)
  , [Series_Complete_Yes] nvarchar(50)
  , [Series_Complete_Pop_Pct] nvarchar(50)
  , [Booster_Doses] nvarchar(50)
  , [Booster_Doses_Vax_Pct] nvarchar(50)
  , [Metro_status] nvarchar(50)
  , [Census2019] nvarchar(50)
)

INSERT INTO [dbo].[Raw_Immunizations]
SELECT
    [Date]
  , CASE WHEN [Recip_State] = 'WA' then 'Washington' end as Recip_State
  , [Administered_Dose1_Recip]
  , [Administered_Dose1_Pop_Pct]
  , [Series_Complete_Yes]
  , [Series_Complete_Pop_Pct]
  , [Booster_Doses]
  , [Booster_Doses_Vax_Pct]
  , [Metro_status]
  , [Census2019]
FROM [green_nault].[dbo].raw_us_vaccinations WITH (NOLOCK)

END
GO