USE [green_nault]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************************************************************
 * Master ETL driver for COVID + Unemployment star schema
 * - Logs each run to MasterCovidUnemploymentLog
 * - Uses TRY/CATCH with transaction rollback on failure
 * EXEC [dbo].[sp_master_covid_unemployment];


 I would probably place the logging in the sprocs themselves. This was rushed (sorry!)

 **************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[sp_master_covid_unemployment]
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @LogID int;

    --------------------------------------------------------
    -- Insert log row: run started
    --------------------------------------------------------
    INSERT INTO [dbo].[MasterCovidUnemploymentLog]
    (
          RunStartTime
        , Status
    )
    VALUES
    (
          SYSDATETIME()
        , 'Started'
    );

    SET @LogID = SCOPE_IDENTITY();

    BEGIN TRY

        BEGIN TRANSACTION;

        --------------------------------------------------------
        -- Stage 2: Dimensions (built from RAW, not from facts)
        --------------------------------------------------------

        EXEC [dbo].[sp_DimDate];
        EXEC [dbo].[sp_DimState];
        EXEC [dbo].[sp_DimCountry];

        --------------------------------------------------------
        -- Stage 3: Facts (with FK constraints to dims)
        --------------------------------------------------------

        EXEC [dbo].[sp_FactCovid];
        EXEC [dbo].[sp_FactUnemployment];

		
		--EXEC [dbo].[sp_RawImmunizations];
		--EXEC [dbo].[sp_FactImmunizations];

        --------------------------------------------------------
        -- All good: commit and mark log as succeeded
        --------------------------------------------------------
        COMMIT TRANSACTION;

        UPDATE [dbo].[MasterCovidUnemploymentLog]
        SET
              RunEndTime = SYSDATETIME()
            , Status     = 'Succeeded'
            , ErrorNumber    = NULL
            , ErrorSeverity  = NULL
            , ErrorState     = NULL
            , ErrorProcedure = NULL
            , ErrorLine      = NULL
            , ErrorMessage   = NULL
        WHERE LogID = @LogID;

    END TRY
    BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE
          @ErrorNumber    int            = ERROR_NUMBER()
        , @ErrorSeverity  int            = ERROR_SEVERITY()
        , @ErrorState     int            = ERROR_STATE()
        , @ErrorProcedure nvarchar(128)  = ERROR_PROCEDURE()
        , @ErrorLine      int            = ERROR_LINE()
        , @ErrorMessage   nvarchar(4000) = ERROR_MESSAGE()
        , @ThrowMessage   nvarchar(4000);

    -- Update log row first (same as before)
    UPDATE [dbo].[MasterCovidUnemploymentLog]
    SET
          RunEndTime     = SYSDATETIME()
        , Status         = 'Failed'
        , ErrorNumber    = @ErrorNumber
        , ErrorSeverity  = @ErrorSeverity
        , ErrorState     = @ErrorState
        , ErrorProcedure = @ErrorProcedure
        , ErrorLine      = @ErrorLine
        , ErrorMessage   = @ErrorMessage
    WHERE LogID = @LogID;

    -- Build a single error string (CONCAT is supported in 2019)
    SET @ThrowMessage = CONCAT(
          'sp_master_covid_unemployment failed. '
        , 'Error ', @ErrorNumber
        , ' in ', ISNULL(@ErrorProcedure, 'UNKNOWN')
        , ' at line ', @ErrorLine
        , '. Message: ', @ErrorMessage
    );

    -- Rethrow using variable (not CONCATENATE)
    THROW 50001, @ThrowMessage, 1;

END CATCH;

END
GO