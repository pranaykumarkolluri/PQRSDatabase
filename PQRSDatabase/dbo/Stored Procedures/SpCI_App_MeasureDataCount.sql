
-- =============================================
-- Author:		Raju G
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SpCI_App_MeasureDataCount]

AS
BEGIN

declare @count int=0;
select @count= count(*) from tbl_CI_Measuredata_value M inner join tbl_CI_Source_UniqueKeys  K on M.CategoryId=1 and
						 M.KeyId=K.Key_Id  and K.IsMSetIdActive=1  and M.CategoryId=k.Category_Id 

select @count;
END

