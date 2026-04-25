delete
  FROM [green_nault].[dbo].[Raw_Unemployment]
  where [Filed week ended] = cast('1900-01-01' as date) or [State] is null or [State] = 
'Run Date: 3/22/2024'