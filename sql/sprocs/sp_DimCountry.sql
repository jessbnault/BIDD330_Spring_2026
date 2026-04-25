USE [green_nault]
GO

/****** Object:  StoredProcedure [dbo].[sp_DimCountry]    Script Date: 4/24/2026 4:15:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE or alter PROCEDURE [dbo].[sp_DimCountry]
	AS
/************
*Developer: Tim Pauley
*Date: 04/02/2024
*Description: Store Procedure for Dim Country
*	4/2 - We use Fact Covid to capture a unique list of Countrys
* exec [dbo].[sp_DimCountry]
*
***************/
		BEGIN
		--step 1: build the table
		DROP TABLE IF EXISTS [dbo].[DimCountry]
		CREATE TABLE [dbo].[DimCountry]
		(
			DimID int IDENTITY (1,1) --add out own idenity column for future slow changing dimensions
			,Country nvarchar(50)
			,CONSTRAINT PK_DimCountry PRIMARY KEY CLUSTERED (Country)
		)
		
		--Step 2: Insert int our own table
		INSERT INTO [dbo].[DimCountry]
		SELECT DISTINCT
		--TOP 10 --We do not select the IDENTITY column
			[Country_Region]
		FROM [green_nault].[dbo].[bing-covid-dataset] WITH (NOLOCK)
	END
GO


