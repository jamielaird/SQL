--Set prospect source from first source tag or channel (old version)

USE sandpit;
WITH 
FirstStatus AS(
SELECT
SSH.client_id,
SSH.crms_number,
SSH.date_modified,
ROW_NUMBER()OVER(
PARTITION BY
SSH.client_id,
SSH.crms_number
ORDER BY 
SSH.client_id,
SSH.crms_number,
SSH.date_modified ASC
)seq_revFirstStatus,
SSH.student_status
FROM dbo.ZZ_crms_student_status_history SSH
)


SELECT
S.client_id,
CASE 
WHEN ST.first_source_tag = '11ten PPC' AND S.client_id = 'HUK_GLASGOWC' THEN 'Load list'
WHEN CONVERT(DATE,ST.first_source_tag_date_created) = CONVERT(DATE,S.date_created) AND  ST.first_source_tag LIKE '%[_]ff[_]%' THEN 'Fairs & Exhibitions' 
WHEN CONVERT(DATE,ST.first_ssw_tag_date_created) = CONVERT(DATE,S.date_created) THEN 'Website referral'
WHEN CONVERT(DATE,ST.first_source_tag_date_created) = CONVERT(DATE,S.date_created) AND ST.first_source_tag LIKE '%[_]bc[_]%' THEN 'Irregular Lists' 
WHEN CONVERT(DATE,ST.first_source_tag_date_created) = CONVERT(DATE,S.date_created) AND ST.first_source_tag LIKE '%emt%' THEN 'Webform' 
WHEN CONVERT(DATE,ST.first_source_tag_date_created) = CONVERT(DATE,S.date_created) AND ST.first_source_tag LIKE '%enq%' THEN 'Irregular Lists' 
WHEN CONVERT(DATE,ST.first_source_tag_date_created) = CONVERT(DATE,S.date_created) AND ST.first_source_tag LIKE '%OF REG%' THEN 'Webform' 
WHEN CONVERT(DATE,ST.first_general_tag_date_created) = CONVERT(DATE,S.date_created) AND  ST.first_general_tag LIKE '%AY enquir%' THEN 'Irregular Lists' 
WHEN CONVERT(DATE,ST.first_general_tag_date_created) = CONVERT(DATE,S.date_created) AND  ST.first_general_tag LIKE '%AY appli%' THEN 'Irregular Lists' 
WHEN ST.first_channel_mod = 'Made Offer' AND ABS(DATEDIFF(day,S.date_created,ST.first_mo_tag_date_created))<7  THEN 'Made Offer'
WHEN ST.first_channel_mod = 'Prospect List' AND ST.first_source_tag LIKE '%[_]emt%' THEN 'Webform' 
WHEN CONVERT(DATE,ST.first_mo_tag_date_created) = CONVERT(DATE,S.date_created) THEN 'Made Offer' 
WHEN ST.first_general_tag LIKE '%AY appli%' THEN 'Irregular Lists' 
WHEN ST.first_channel_mod = 'Prospect List' AND ST.first_source_tag LIKE '%[_]ff[_]%' THEN 'Fairs & Exhibitions'
WHEN ST.first_channel_mod = 'Prospect List' AND ST.first_source_tag LIKE '%[_]bc[_]%' THEN 'Irregular Lists'
WHEN ST.first_channel_mod = 'Prospect List' AND FS.student_status = 'Applied' THEN 'AppliedList'
WHEN ST.first_channel_mod = 'Prospect List' THEN 'Irregular Lists'
WHEN ST.first_comm_class_mod = 'Email' THEN 'Email' 
WHEN ST.first_comm_class_mod = 'Fax' THEN 'Email' 
WHEN ST.first_comm_class_mod = 'Letter' THEN 'Email' 
WHEN ST.first_comm_class_mod = 'SMS' THEN 'Phone' 
WHEN ST.first_comm_class_mod = 'Web' THEN 'Enquiry Forms' 
WHEN ST.first_comm_class_mod = 'Unspecified' THEN 'Email' 
WHEN ST.first_comm_class_mod IS NULL THEN 'Email' 
WHEN ST.first_channel_mod = 'Prospect List' AND ST.first_mo_source_tag <> 'Unspecified' THEN 'Load list'
WHEN ST.first_channel_mod = 'Made Offer' AND ST.first_mo_source_tag IS NOT NULL THEN 'Made Offer'
ELSE ST.first_comm_class_mod 
END AS Source


FROM dbo.ZZ_crms_student S 
LEFT JOIN dbo.ZZ_crms_student_tag ST ON S.client_id = ST.client_id AND S.crms_number = ST.crms_number
LEFT JOIN FirstStatus FS ON S.client_id = FS.client_id AND S.crms_number = FS.crms_number AND FS.seq_revFirstStatus = 1