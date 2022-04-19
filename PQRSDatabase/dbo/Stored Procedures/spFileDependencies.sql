CREATE PROCEDURE [dbo].[spFileDependencies]

AS
BEGIN


declare @DependentFileIds table(FileId int,depid int)
declare @PhyNpi varchar(10);
declare @IsFacity bit;
declare @FileId int ;
declare @FileName varchar(256);

DECLARE @IS_REQQUIRE_RUN_PERFORMANCE BIT=0;
DECLARE File_CUR CURSOR FOR

select ID,isFacility,NPI,FILE_NAME from tbl_PQRS_FILE_UPLOAD_HISTORY where STATUS='Pending'
	
 OPEN File_CUR
 FETCH NEXT FROM File_CUR
 INTO @FileId,@IsFacity,@PhyNpi,@FileName

 WHILE @@FETCH_STATUS=0
 BEGIN

			if not exists( select 1 from tbl_MultipleFileUpload_History where FileId=@FileId)
			Begin
				  With DependentFileIds_CTE as
				  (
				     
					    select distinct p.ID from tbl_PQRS_FILE_UPLOAD_HISTORY P where p.STATUS='Pending' and P.ID < @FileId 
					 and p.NPI=@PhyNpi --and p.NPI is not null
					 and p.ID not in (
										select distinct p.ID from tbl_PQRS_FILE_UPLOAD_HISTORY P inner join 
									    tbl_MultipleFileUpload_History M on P.ID=M.FileId  and p.STATUS='Pending' and P.ID < @FileId 
										-- and p.NPI is null
									    and m.NPI=@PhyNpi
									 )
					 union
				     select distinct p.ID from tbl_PQRS_FILE_UPLOAD_HISTORY P inner join 
					 tbl_MultipleFileUpload_History M on P.ID=M.FileId  and p.STATUS='Pending' and P.ID < @FileId 
					 -- and p.NPI is null
					 and m.NPI=@PhyNpi
				  )
				insert into @DependentFileIds(FileId,depid)
				select distinct @FileId,ID  from  DependentFileIds_CTE
			end
			else
			begin
					With FlleTIN_NPIS_CTE as
					(
					  select  Tin,npi from  tbl_MultipleFileUpload_History where FileId=@FileId and (TIN is not null or TIN != '')
					),
					DependentFiles As
					(
					   select p.ID from  tbl_MultipleFileUpload_History M  
		   
					   inner join tbl_PQRS_FILE_UPLOAD_HISTORY P on M.FileId=P.ID and P.STATUS='Pending'
					   inner join FlleTIN_NPIS_CTE F
		   
					   on M.TIN=F.TIN and M.NPI=F.NPI and p.ID < @FileId 
					)
					insert into @DependentFileIds(FileId,depid)

					select distinct  @FileId,ID from DependentFiles
			end

-- Cursor end
  FETCH NEXT FROM File_CUR   INTO @FileId,@IsFacity,@PhyNpi,@FileName

   END
 CLOSE File_CUR
 DEALLOCATE File_CUR

 insert into tbl_File_Dependencies(FileId,DepFileId)
 select distinct * from  @DependentFileIds D

 where not EXISTS(

 select  fd.FileId,fd.DepFileId from tbl_File_Dependencies fd where fd.FileId=D.FileId and fd.DepFileId=D.depid
 )


 



END




