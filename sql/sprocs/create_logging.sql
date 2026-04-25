USE [green_nault]
GO

/*******************************************************
 * Logging table for sp_master_covid_unemployment runs
 *******************************************************/
IF OBJECT_ID('[dbo].[MasterCovidUnemploymentLog]', 'U') IS NOT NULL
    DROP TABLE [dbo].[MasterCovidUnemploymentLog];
GO

CREATE TABLE [dbo].[MasterCovidUnemploymentLog]
(
      LogID            int IDENTITY(1,1)   NOT NULL
    , RunStartTime     datetime2(3)        NOT NULL
    , RunEndTime       datetime2(3)        NULL
    , Status           varchar(20)         NOT NULL  -- 'Started', 'Succeeded', 'Failed'
    , ErrorNumber      int                 NULL
    , ErrorSeverity    int                 NULL
    , ErrorState       int                 NULL
    , ErrorProcedure   nvarchar(128)       NULL
    , ErrorLine        int                 NULL
    , ErrorMessage     nvarchar(4000)      NULL

    , CONSTRAINT PK_MasterCovidUnemploymentLog
          PRIMARY KEY CLUSTERED (LogID)
);
GO