CREATE PROCEDURE [dbo].[SpCI_App_GetMeasureData]
@PageNo int,
@PageLimit int
AS
BEGIN


	declare @skiprows int=0;
	set @skiprows = CASE WHEN  @PageNo >1 THEN (@PageNo-1) * @PageLimit ELSE 0 END 
	print @PageNo*@PageLimit
	select K.Tin,K.Npi, M.* from tbl_CI_Measuredata_value M inner join tbl_CI_Source_UniqueKeys  K on M.CategoryId=1 and
	M.KeyId=K.Key_Id  and K.IsMSetIdActive=1  and M.CategoryId=k.Category_Id 
	
	order by m.KeyId
	OFFSET @skiprows  ROWS
	FETCH NEXT @PageLimit ROWS ONLY

 
END
