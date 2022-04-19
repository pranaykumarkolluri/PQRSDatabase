CREATE VIEW [dbo].[VW_TIN_CMSSubmissionStatus]
AS
     SELECT DISTINCT
            p.TIN,
            CASE
                WHEN g.Tin IS NOT NULL
                THEN 'Yes'
                ELSE 'No'
            END AS 'SubmittedtoCMS',
            c.Category_Name,
            G.CmsYear
     FROM tbl_TIN_GPRO P
          INNER JOIN tbl_CI_Source_UniqueKeys G ON p.TIN = g.Tin
                                                   AND g.Npi IS NULL
                                                   AND g.IsMSetIdActive = 1
          LEFT JOIN tbl_CI_lookup_Categories c ON g.Category_Id = c.Category_Id;
