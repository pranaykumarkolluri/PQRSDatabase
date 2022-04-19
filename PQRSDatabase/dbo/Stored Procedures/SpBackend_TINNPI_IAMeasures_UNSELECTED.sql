-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--Changes#1: JIRA:914
-- =============================================
CREATE PROCEDURE [dbo].[SpBackend_TINNPI_IAMeasures_UNSELECTED] 
@CmsYear int 
AS
BEGIN
declare @SelectIdTbl table(SelectionId int)
DECLARE @blnGPRO BIT;
DECLARE @strCurTIN VARCHAR(9);
DECLARE @ErrorCode VARCHAR(MAX);
DECLARE CurTINs CURSOR
                 FOR

    --STEP #1: Getting Required TIN 
                     SELECT DISTINCT
                            TIN
                     FROM Tbl_Backend_TINNPI_IA WITH (NOLOCK)
                     WHERE CMSYear = @CMSYear and Npi is not null and Npi !='' and Is_Done=1
                 OPEN CurTINs;
                 FETCH NEXT FROM CurTINs INTO @strCurTIN;
                 WHILE @@FETCH_STATUS = 0
                     BEGIN
                         PRINT 'IA:TIN Cursor Started with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));

    --STEP #1.1: FIND Whether TIN GPRO or Not?
                         SET @blnGPRO = 0;			
							--Check tin gpro status
                         EXEC sp_getTIN_GPRO
                              @strCurTIN;
                        IF EXISTS( SELECT is_GPRO
    FROM tbl_TIN_GPRO
    WHERE TIN = @strCurTIN
          AND is_GPRO = 1)--Converting  GPRO to non GPRO
                             BEGIN
                                 EXEC spUpdate_GPROtoNonGPRO_ViceVersa
                                      @strCurTIN,
                                      0,
                                      @CMSYear,
                                      '',
                                      @ErrorCode = @ErrorCode OUTPUT;
                             END;
                         PRINT 'CODE IA:N 103 TIN Cursor Ends with  TIN: '+CAST(@strCurTIN AS VARCHAR(10));
                         FETCH NEXT FROM CurTINs INTO @strCurTIN;
     -----------------TIN Cursor END------------------------------
                     END;
                 CLOSE CurTINs;
                 DEALLOCATE CurTINs;



insert into @SelectIdTbl (SelectionId)
select distinct I.SelectedID from tbl_IA_Users I inner join 
Tbl_Backend_TINNPI_IA T on  I.CMSYear=@CmsYear
and I.TIN=T.Tin 
and I.NPI=T.Npi 
and T.Is_Done=1
delete from tbl_IA_User_Selected_Categories where ID in (select  s.SelectionId from @SelectIdTbl s) and CMSYear=@CmsYear
-- Changes#1


END
