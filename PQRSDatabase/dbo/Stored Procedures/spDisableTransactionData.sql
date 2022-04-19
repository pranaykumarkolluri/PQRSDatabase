
-- =============================================
-- Author:		prashanth kumar
-- Create date: 19-jul-2014
-- Description:	This process disables previous transaction(exam) in
--				staging tables and delete/archives  in transaxtion tables.
-- =============================================
CREATE PROCEDURE [dbo].[spDisableTransactionData] 
	-- Add the parameters for the stored procedure here
    @prev_TransactionID VARCHAR(20) ,
    @New_TrascationId VARCHAR(20)
AS 
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON ;

    -- Insert statements for procedure here
        SELECT  @prev_TransactionID ,
                @New_TrascationId
    END

