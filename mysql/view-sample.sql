-- Mannys Ultimate Mixes DATABASE

-- VIEW SQL
-- view_business
CREATE OR REPLACE VIEW `view_business` AS
SELECT 
B.`busns_id`,
B.`busns_name` AS `BusinessName`,
B.`busns_address`,
GCI.`city_name` AS `busns_city_name`,
GS.`state_name` AS `busns_state_name`,
GCN.`country_name` AS `busns_country_name`,
B.`busns_zipcode`,
B.`busns_owner_u_id`,
U.`u_fname` AS `busns_owner_u_fname`,
U.`u_lname` AS `busns_owner_u_lname`,
U.`u_primary_email` AS `busns_owner_u_primary_email`,
U.`u_primary_mobile` AS `busns_owner_u_primary_mobile`,
U.`u_whatsapp` AS `busns_owner_u_whatsapp`,
B.`busns_toll_free_number`, 
B.`busns_mobile`, 
B.`busns_whatsapp`, 
B.`busns_email`,
B.`busns_fax`, 
B.`busns_website_url`, 
B.`busns_facebook_profile`, 
B.`busns_instagram_profile`, 
B.`busns_youtube_profile`, 
B.`busns_x_profile`, 
B.`busns_linkedin_profile`, 
B.`busns_tiktok_profile`, 
B.`busns_pinterest_profile`, 
B.`busns_google_my_business_url`, 
B.`busns_google_map_url`, 
B.`busns_google_review_url`, 
B.`busns_initial_findings`, 
B.`busns_competitor_findings`
FROM `te_business` B 
INNER JOIN `te_user` U ON B.busns_owner_u_id = U.u_id
INNER JOIN `te_geo_city` GCI ON B.busns_city_id = GCI.city_id
INNER JOIN `te_geo_state` GS ON B.busns_state_id = GS.state_id
INNER JOIN `te_geo_country` GCN ON B.busns_country_id = GCN.country_id
WHERE 1
AND B.`busns_deleted` IS NULL
ORDER BY B.`busns_id` DESC;


-- view_business_user
CREATE OR REPLACE VIEW `view_business_user` AS
SELECT 
BU.`bu_busns_id`,
B.`busns_name` AS `bu_busns_name`,
BU.`bu_u_id`,
BU.`bu_jtitle_id`,
JT.`jtitle_name` AS `bu_jtitle_name`,
U.`u_fname` AS `bu_u_fname`,
U.`u_lname` AS `bu_u_lname`,
U.`u_primary_email` AS `bu_u_primary_email`,
U.`u_primary_mobile` AS `bu_u_primary_mobile`,
U.`u_whatsapp` AS `bu_u_whatsapp`,
BU.`bu_about`,
BU.`bu_parent_u_id`,
BU2.`bu_jtitle_id` AS `bu_parent_jtitle_id`,
JT2.`jtitle_name` AS `bu_parent_jtitle_name`,
U2.`u_fname` AS `bu_parent_u_fname`,
U2.`u_lname` AS `bu_parent_u_lname`,
U2.`u_primary_email` AS `bu_parent_u_primary_email`,
U2.`u_primary_mobile` AS `bu_parent_u_primary_mobile`,
U2.`u_whatsapp` AS `bu_parent_u_whatsapp`,
BU2.`bu_about` AS `bu_parent_about`,
(
    SELECT GROUP_CONCAT(DISTINCT BSR.`bsalreg_name` ORDER BY BSR.`bsalreg_name` SEPARATOR ', ')
    FROM  `te_business_user_sales_location` AS BUSL
    LEFT JOIN `te_business_sales_region` BSR ON BUSL.`busl_bsalreg_id` = BSR.`bsalreg_id`
    WHERE BUSL.`busl_bu_id` = BU.`bu_id`
) AS `bu_busns_sales_region`,
(
    SELECT GROUP_CONCAT(DISTINCT BSA.`bsalar_area_name` ORDER BY BSA.`bsalar_area_name` SEPARATOR ', ')
    FROM  `te_business_user_sales_location` AS BUSL2
    LEFT JOIN `te_business_sales_area` BSA ON BUSL2.`busl_bsalar_id` = BSA.`bsalar_id`
    WHERE BUSL2.`busl_bu_id` = BU.`bu_id`
) AS `bu_busns_sales_area`,
U.`u_website_url` AS `bu_u_website_url`, 
U.`u_facebook_profile` AS `bu_u_facebook_profile`, 
U.`u_instagram_profile` AS `bu_u_instagram_profile`, 
U.`u_youtube_profile` AS `bu_u_youtube_profile`, 
U.`u_x_profile` AS `bu_u_x_profile`, 
U.`u_linkedin_profile` AS `bu_u_linkedin_profile`, 
U.`u_tiktok_profile` AS `bu_u_tiktok_profile`, 
U.`u_pinterest_profile` AS `bu_u_pinterest_profile`
FROM `te_business_user` BU
INNER JOIN `te_user` U ON BU.`bu_u_id` = U.`u_id`
INNER JOIN `te_business` B ON BU.`bu_busns_id` = B.`busns_id`
LEFT JOIN `te_job_title` JT ON BU.`bu_jtitle_id` = JT.`jtitle_id`
LEFT JOIN `te_user` U2 ON BU.`bu_parent_u_id` = U2.`u_id`
LEFT JOIN `te_business_user` BU2 ON U2.`u_id` = BU2.`bu_u_id`
LEFT JOIN `te_job_title` JT2 ON BU2.`bu_jtitle_id` = JT2.`jtitle_id`
WHERE 1
AND BU.`bu_deleted` IS NULL
AND BU.`bu_active` IS NULL
ORDER BY BU.`bu_id` DESC;



-- view_lead
CREATE OR REPLACE VIEW `view_lead` AS
SELECT 
L.`lead_id`, 
L.`lead_from_busns_id`, 
B.`busns_name` AS `lead_from_busns_name`,
L.`lead_from_u_id`, 
CONCAT(U.`u_fname`, ' ', U.`u_lname`) AS `lead_from_u_name`,
U.`u_primary_email` AS `lead_from_u_primary_email`,
U.`u_primary_mobile` AS `lead_from_u_primary_mobile`,
U.`u_whatsapp` AS `lead_from_u_whatsapp`,
L.`lead_to_u_id`, 
CONCAT(U2.`u_fname`, ' ', U2.`u_lname`) AS `lead_to_u_name`,
L.`lead_concern_issue`, 
L.`lead_preferred_contact_method`, 
L.`lead_subject`, 
L.`lead_comment`, 
L.`lead_initial_findings`, 
L.`lead_first_incoming_message_dt`, 
L.`lead_created`,
LASTLF.`leadfup_id` AS `last_followup_id`,
LASTLF.`leadfup_u_id` AS `last_followup_u_id`, 
LASTLF.`leadfup_leadpot_id` AS `last_followup_leadpot_id`,
LP.`leadpot_title` AS `last_followup_leadpot_title`, 
LASTLF.`leadfup_leadfst_id` AS `last_followup_leadfst_id`, 
LFS.`leadfst_title` AS `last_followup_leadfst_title`,
LASTLF.`leadfup_leadfupvia_id` AS `last_followup_leadfupvia_id`, 
LFVIA.`leadfupvia_title` AS `last_followup_leadfupvia_title`,
LASTLF.`leadfup_note` AS `last_followup_note`, 
LASTLF.`leadfup_competitor_note` AS `last_followup_competitor_note`, 
LASTLF.`leadfup_created` AS `last_followup_date`,
LASTLF.`leadfup_next_followup` AS `next_followup_date`
FROM `te_lead` L
LEFT JOIN `te_business` B ON L.`lead_from_busns_id` = B.`busns_id`
LEFT JOIN `te_user` U ON L.`lead_from_u_id` = U.`u_id`
LEFT JOIN `te_user` U2 ON L.`lead_to_u_id` = U2.`u_id`
LEFT JOIN (
  SELECT TEMPLF.`leadfup_lead_id`, MAX(TEMPLF.`leadfup_id`) AS `max_leadfup_id`
  FROM `te_lead_followup` TEMPLF
  WHERE 1 AND TEMPLF.`leadfup_deleted` IS NULL
  GROUP BY TEMPLF.`leadfup_lead_id`
) SUBLF ON SUBLF.`leadfup_lead_id` = L.`lead_id`
LEFT JOIN `te_lead_followup` LASTLF ON LASTLF.`leadfup_id` = SUBLF.`max_leadfup_id`
LEFT JOIN `te_user` U3 ON LASTLF.`leadfup_u_id` = U3.`u_id`
LEFT JOIN `te_lead_potential` LP ON LASTLF.`leadfup_leadpot_id` = LP.`leadpot_id`
LEFT JOIN `te_lead_followup_status` LFS ON LASTLF.`leadfup_leadfst_id` = LFS.`leadfst_id`
LEFT JOIN `te_lead_followup_via` LFVIA ON LASTLF.`leadfup_leadfupvia_id` = LFVIA.`leadfupvia_id`
WHERE 1
AND L.`lead_deleted` IS NULL
ORDER BY L.`lead_id` DESC;

-- view_lead_followup
CREATE OR REPLACE VIEW `view_lead_followup` AS
SELECT 
LFUP.`leadfup_id`, 
LFUP.`leadfup_lead_id`, 
L.`lead_subject` AS `leadfup_lead_subject`,
L.`lead_comment` AS `leadfup_lead_comment`,
L.`lead_initial_findings` AS `leadfup_lead_initial_findings`,
B.`busns_name` AS `leadfup_lead_from_busns_name`,
CONCAT(U2.`u_fname`, ' ', U2.`u_lname`) AS `leadfup_lead_from_u_name`,
LFUP.`leadfup_u_id`, 
CONCAT(U.`u_fname`, ' ', U.`u_lname`) AS `leadfup_u_name`,
LFUP.`leadfup_leadpot_id`, 
LP.`leadpot_title` AS `leadfup_leadpot_title`,
LFUP.`leadfup_leadfst_id`, 
LFS.`leadfst_title` AS `leadfup_leadfst_title`,
LFUP.`leadfup_leadfupvia_id`, 
LFVIA.`leadfupvia_title` AS `leadfup_leadfupvia_title`,
LFUP.`leadfup_note`, 
LFUP.`leadfup_competitor_note`, 
LFUP.`leadfup_created`, 
LFUP.`leadfup_next_followup`
FROM `te_lead_followup` LFUP
INNER JOIN `te_lead` L ON LFUP.`leadfup_lead_id` = L.`lead_id`
LEFT JOIN `te_user` U ON LFUP.`leadfup_u_id` = U.`u_id`
LEFT JOIN `te_lead_potential` LP ON LFUP.`leadfup_leadpot_id` = LP.`leadpot_id`
LEFT JOIN `te_lead_followup_status` LFS ON LFUP.`leadfup_leadfst_id` = LFS.`leadfst_id`
LEFT JOIN `te_lead_followup_via` LFVIA ON LFUP.`leadfup_leadfupvia_id` = LFVIA.`leadfupvia_id`
LEFT JOIN `te_business` B ON L.`lead_from_busns_id` = B.`busns_id`
LEFT JOIN `te_user` U2 ON L.`lead_from_u_id` = U2.`u_id`
WHERE 1 
AND LFUP.`leadfup_deleted` IS NULL
ORDER BY LFUP.`leadfup_id` DESC;

----------------------
-- PFG NC DATA PROCESS
----------------------

-- DATA TRANSFER SQL
INSERT INTO temp_pfg_nc_user_sales_area (ID, SR_ID, UNIQUE_ID, SALES_AREA)
WITH RECURSIVE split AS (
  SELECT
    t.ID,
    t.SR_ID,
    t.UNIQUE_ID,
    TRIM(SUBSTRING_INDEX(t.SALES_AREA_FORMATTED, ',', 1)) AS SALES_AREA,
    CASE
      WHEN INSTR(t.SALES_AREA_FORMATTED, ',') > 0
        THEN SUBSTRING(t.SALES_AREA_FORMATTED, INSTR(t.SALES_AREA_FORMATTED, ',') + 1)
      ELSE ''
    END AS rest
  FROM temp_pfg_nc t
  WHERE t.SALES_AREA_FORMATTED IS NOT NULL
    AND TRIM(t.SALES_AREA_FORMATTED) <> ''

  UNION ALL

  SELECT
    ID,
    SR_ID,
    UNIQUE_ID,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS SALES_AREA,
    CASE
      WHEN INSTR(rest, ',') > 0
        THEN SUBSTRING(rest, INSTR(rest, ',') + 1)
      ELSE ''
    END AS rest
  FROM split
  WHERE rest <> ''
)
SELECT
  ID,
  SR_ID,
  UNIQUE_ID,
  SALES_AREA
FROM split
WHERE SALES_AREA <> ''
ON DUPLICATE KEY UPDATE
  temp_pfg_nc_user_sales_area.SALES_AREA = temp_pfg_nc_user_sales_area.SALES_AREA;


-- Multiple ROW for each record
INSERT INTO temp_pfg_nc_user_sales_area (SR_ID, UNIQUE_ID, SALES_AREA)
SELECT
  t.SR_ID,
  t.UNIQUE_ID,
  TRIM(j.sales_area) AS SALES_AREA
FROM temp_pfg_nc t
JOIN JSON_TABLE(
  CONCAT(
    '["',
    REPLACE(REPLACE(t.SALES_AREA_FORMATTED, '"', '\\"'), ',', '","'),
    '"]'
  ),
  '$[*]' COLUMNS (
    sales_area VARCHAR(255) PATH '$'
  )
) AS j
ON DUPLICATE KEY UPDATE SALES_AREA = SALES_AREA;

-- FIND THE DIFFERENCE
SELECT * FROM temp_pfg_nc_user_sales_area A LEFT JOIN temp_pfg_nc_sales_area_unique B ON A.SALES_AREA = B.sales_area HAVING B.id IS NULL ORDER BY `UNIQUE_ID` ASC;


-- ADD REAL USER ID AND BUSINESS USER ID TO TEMP USER SALES AREA
UPDATE 
temp_pfg_nc_user_sales_area A,
temp_pfg_nc B
SET 
A.USER_ID = B.USER_ID,
A.BUSINESS_USER_ID = B.BUSINESS_USER_ID
WHERE
A.UNIQUE_ID = B.UNIQUE_ID;



-- FINAL IMPORT SQL

INSERT INTO te_business_sales_area 
(bsalar_busns_id, bsalar_bsalreg_id, bsalar_area_name, bsalar_import_unique_id, bsalar_import_batch, bsalar_import_note)
SELECT 
692 AS bsalar_busns_id,
A.region_id AS bsalar_bsalreg_id,
A.sales_area AS bsalar_area_name,
A.id AS bsalar_import_unique_id,
'MUM - Contacts - Database : PFG NC- Sales Team' AS bsalar_import_batch,
'temp_pfg_nc_sales_area_unique' AS bsalar_import_note
FROM temp_pfg_nc_sales_area_unique A
WHERE 1;

-- REVERSE UPDATE TO TEMP FOR FURTHER PROCESS
UPDATE 
temp_pfg_nc_sales_area_unique A, 
te_business_sales_area B 
SET A.main_id = B.bsalar_id 
WHERE 
A.id = B.bsalar_import_unique_id
AND B.bsalar_busns_id = 692
AND B.bsalar_import_batch = 'MUM - Contacts - Database : PFG NC- Sales Team'; 


-- UPDATE temp_pfg_nc_user_sales_area
UPDATE temp_pfg_nc_user_sales_area A,
temp_pfg_nc_sales_area_unique B
SET A.MAIN_SALES_AREA_ID = B.main_id
WHERE A.SALES_AREA_ID = B.id;

-- TRANSFER USER SALES AREA IN LOCATION
INSERT INTO 
te_business_user_sales_location
(busl_bu_id, busl_bsalreg_id, busl_bsalar_id, busl_import_unique_id, busl_import_batch, busl_import_note)
SELECT 
A.BUSINESS_USER_ID,
B.region_id,
A.MAIN_SALES_AREA_ID,
CONCAT(A.ID,":",A.MAIN_SALES_AREA_ID,":",A.UNIQUE_ID) AS busl_import_unique_id, 
'MUM - Contacts - Database : PFG NC- Sales Team' AS busl_import_batch, 
'temp_pfg_nc_user_sales_area' AS busl_import_note
FROM 
temp_pfg_nc_user_sales_area A
LEFT JOIN temp_pfg_nc_sales_area_unique B
ON A.SALES_AREA_ID = B.id















