-- =============================================
-- Author:		Pavan
-- Create date: 10/29/2021
-- Description: Get Non Authorized Physician Document list for given TIN under Given Facility
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetFacilityTinDocumentsStatus] 
	-- Add the parameters for the stored procedure here
	@UserName as varchar(250),
	@CMSYear int,
	@userRole int
AS
BEGIN
	DECLARE @PhyDocStatus table(
	TIN varchar(9),
	NPI varchar(10),
	DocumentStatus varchar(50)
	)
	Declare @NPIofTins table( NPI Varchar(10),TIN varchar(10))
	Declare @Status table(DocStatus varchar(50))
	Declare @FacilityUserTins table(TIN varchar(10), Is_Gpro bit)
	

		if(@userRole = 2)
			BEGIN
				insert into @FacilityUserTins
					Exec sp_getFacilityTIN_GPRO @UserName
			END
		ELSE
			BEGIN
				declare @ACRStaffTINS table(
				TIN varchar(9)
				)
				insert into @ACRStaffTINS
					Exec SPGetNpisofTin_VW ''

				insert into @FacilityUserTins
				select a.TIN,ISNULL(g.is_GPRO,0) from @ACRStaffTINS a left join tbl_TIN_GPRO g on a.TIN=g.TIN

			END

	Insert into @NPIofTins
	select distinct NPI,V.TIN from NRDR..[PHYSICIAN_TIN_VW] v join @FacilityUserTins F on  V.TIN=F.TIN Collate DATABASE_DEFAULT where IS_ACTIVE= 1 and F.Is_Gpro = 0

	Declare @currentNPI varchar(10)
	Declare @CurrentTIN varchar(9)
	Declare @result varchar(50)

	Declare NPI_Cursor CURSOR FOR (select TIN,NPI from @NPIofTins)
		OPEN NPI_Cursor
			FETCH NEXT FROM NPI_Cursor INTO @CurrentTIN,@currentNPI
			WHILE @@FETCH_STATUS = 0
			BEGIN
					insert into @Status
					Exec dbo.sp_getPhysicianDocumentStatus @currentNPI,@CurrentTIN,@CMSYear

					select @result = DocStatus from @Status
					insert into @PhyDocStatus select @CurrentTIN,@currentNPI,@result

					delete from @Status
				FETCH NEXT FROM NPI_Cursor INTO @CurrentTIN,@currentNPI
			END
		CLOSE NPI_Cursor;
	DEALLOCATE NPI_Cursor;

	select distinct TIN,NPI from @PhyDocStatus where DocumentStatus IN ('Not submitted','Rejected')
END

