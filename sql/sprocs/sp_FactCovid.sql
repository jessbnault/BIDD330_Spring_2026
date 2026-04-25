USE [green_nault]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/************
*Developer: Tim Pauley
*Date: 03/22/2024
*Description: Fact Covid
exec [dbo].[sp_FactCovid]
****************/
USE green_nault
go
;
CREATE or ALTER PROCEDURE [dbo].[sp_FactCovid]
AS

DROP TABLE IF EXISTS [dbo].[FactCovid]

CREATE TABLE [dbo].[FactCovid]
(
	FactCovid_Key int IDENTITY (1,1) --future Surrogate Key
	,ID INT
	,Updated date
	,Confirmed int
	,Confirmed_Change int
	,Deaths int
	,Deaths_Change int
	,Recovered int
	,Recovered_Change int
	,Latitude nvarchar(50)
	,Longitude nvarchar(50)
	,Iso2 nvarchar(50)
	,Iso3  nvarchar(50)
	,Country nvarchar(50)
	,[State] nvarchar(50)
	,Iso_Subdivision nvarchar(50)
	,Admin_Region_2 nvarchar(50)
	,CONSTRAINT PK_FactCovid PRIMARY KEY CLUSTERED (FactCovid_Key)

        ,CONSTRAINT FK_FactCovid_DimState
             FOREIGN KEY ([State])
             REFERENCES [dbo].[DimState]([State])

        ,CONSTRAINT FK_FactCovid_DimCountry
             FOREIGN KEY (Country)
             REFERENCES [dbo].[DimCountry](Country)

        ,CONSTRAINT FK_FactCovid_DimDate
             FOREIGN KEY (Updated)
             REFERENCES [dbo].[DimDate](TheDate)
)

INSERT INTO [dbo].[FactCovid]
SELECT
 	CAST([id] as INT)
	, CAST([updated] as date)
	, CAST([confirmed] as INT)
	, CAST([confirmed_change] as INT)
	, CAST([deaths] as INT)
	, CAST([deaths_change] as INT)
	, CAST([recovered] as INT)
	, CAST([recovered_change] as INT)
	, [latitude]
	, [longitude]
	, [iso2]
	, [iso3]
	, [country_region] as Country
	, [admin_region_1] as [State]
	, [iso_subdivision]
	, [admin_region_2]
	--, CAST([load_time] as date)
FROM [green_nault].[dbo].[bing-covid-dataset] RAW WITH (NOLOCK)
GO


