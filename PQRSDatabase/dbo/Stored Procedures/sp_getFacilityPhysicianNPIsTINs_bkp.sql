


-- =============================================
-- Author:		Raju
-- Create date: Jan 17th,2019
-- Description:	used to get facility related tin and npis
-- Change date: Mar 13th, 2020 by Hari J for JIRA#778
-- Change#1:JIRA#955, Hari on June 10th,2021
-- =============================================
CREATE PROCEDURE [dbo].[sp_getFacilityPhysicianNPIsTINs_bkp]
	-- Add the parameters for the stored procedure here
@UserName NVARCHAR(256),
@TIN      VARCHAR(9)    = NULL
AS
         BEGIN
             SELECT first_name,
                    last_name,
                    npi,
                    TIN,
                    is_active,
                    null as deactivation_date,
                    CONVERT(bit,MAX(CONVERT(int,is_enrolled)))  AS is_enrolled
             FROM nrdr..MIPS_FacilityPhysicianNPIsTINs_VW
             WHERE username = @UserName
		   AND is_active=1 -- Change#1
                   AND Tin = CASE
                                 WHEN @TIN = ''
                                      OR @TIN IS NULL
                                 THEN TIN
                                 ELSE @TIN
                             END

					    GROUP BY 
					    first_name,
                    last_name,
                    npi,
                    TIN,
                    is_active,
                    deactivation_date
         END;



