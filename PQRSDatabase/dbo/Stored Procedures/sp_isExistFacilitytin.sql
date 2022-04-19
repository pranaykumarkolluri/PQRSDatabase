create procedure sp_isExistFacilitytin
@tin varchar(10),
@facilityusername varchar(50)
as
begin
DECLARE @abc table(TIN varchar(10),IS_GPRO bit)
Declare @isExist bit;
set @isExist=0;
insert into  @abc exec  sp_getFacilityTIN_GPRO @facilityusername
--select Tin from @abc
if exists(select Tin from @abc where TIN=@tin)
begin
set @isExist=1;
end
select @isExist as isTinExist
end

