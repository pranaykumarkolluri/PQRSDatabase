-- =============================================
-- Author:		Raju Gaddam
-- Create date: march 23 ,2018
-- Description:	insert IA & ACI Tins into tbl_Tin_Gpro which are not exist in this table.
-- =============================================
CREATE PROCEDURE [dbo].[spBackend_IA_ACI_Tins_Insert_tbl_Tin_Gpro]
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @Tinsdata table(TIN varchar(9));

declare @strCurTIN varchar(9);
BEGIN TRY
    BEGIN TRANSACTION;
insert into @Tinsdata 
select distinct Tin from tbl_IA_Users 
union 
select distinct tin from tbl_ACI_Users

delete from @Tinsdata where TIN in 
(select distinct tin from tbl_TIN_GPRO)

declare @count int
select @count=count(*) from @Tinsdata
print (' The count of Tins are ready to insert into tbl_tin_gpro :  '+Convert(varchar(50), isnull(@count,0)))

declare CurTINs CURSOR FOR

    --STEP #1: Getting Required TIN 
    select DISTINCT TIN from @Tinsdata  
    OPEN CurTINs

    FETCH NEXT FROM CurTINs INTO @strCurTIN

    WHILE @@FETCH_STATUS=0

    BEGIN
     PRINT 'TIN Cursor Started with  TIN: ' + CAST(@strCurTIN AS VARCHAR(10));

							exec sp_getTIN_GPRO @strCurTIN
					
    FETCH NEXT FROM CurTINs INTO @strCurTIN
     -----------------TIN Cursor END------------------------------
    END

    CLOSE CurTINs;
    DEALLOCATE CurTINs;
 COMMIT TRANSACTION;
  END TRY
   BEGIN CATCH
    IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
 
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
  PRINT 'CODE:N 112 Error AT TIN: ' + CAST(@strCurTIN AS VARCHAR(10))
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
  END CATCH


END

