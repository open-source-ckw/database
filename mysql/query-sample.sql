-- VIEW to check total status based on division wise
DROP VIEW IF EXISTS oe_view_monthly_total;
CREATE VIEW oe_view_monthly_total AS
SELECT
TRAN.tran_div_name as `Division`,
YEAR(TRAN.tran_datetime) AS `Year`,
MONTH(TRAN.tran_datetime) AS `Month`,
MONTHNAME(TRAN.tran_datetime) AS `Month Name`,
SUM(TRAN.tran_dr) AS `Total DR`,
SUM(TRAN.tran_cr) AS `Total CR`
FROM oe_transaction TRAN
WHERE 1
GROUP BY TRAN.tran_div_name, YEAR(TRAN.tran_datetime), MONTH(TRAN.tran_datetime)
ORDER BY YEAR(TRAN.tran_datetime) DESC, MONTH(TRAN.tran_datetime) DESC;








-- STORED PROCEDURE to check total status based on account wise for particular division
DROP PROCEDURE IF EXISTS `oe_sp_monthly_acc`;
DELIMITER //
CREATE PROCEDURE `oe_sp_monthly_acc`(
  IN `Enter_Division` ENUM('IT','CONSTRUCTION','TEXTILE') CHARSET utf8,
  IN `Enter_Year` YEAR(4),
  IN `Enter_Month` INT(2) UNSIGNED
)
BEGIN
    SELECT
    TRAN.tran_div_name as `Division`,
    TRAN.tran_acc_name as `Account Name`,
    YEAR(TRAN.tran_datetime) AS `Year`,
    MONTH(TRAN.tran_datetime) AS `Month`,
    MONTHNAME(TRAN.tran_datetime) AS `Month Name`,
    SUM(TRAN.tran_dr) AS `Total DR`,
    SUM(TRAN.tran_cr) AS `Total CR`
    FROM oe_transaction TRAN
    WHERE TRAN.tran_div_name = Enter_Division
    AND YEAR(TRAN.tran_datetime) = Enter_Year
    AND MONTH(TRAN.tran_datetime) = Enter_Month
    GROUP BY TRAN.tran_acc_name
    ORDER BY TRAN.tran_acc_name ASC;
END //
DELIMITER;

-- To call above STORED PROCEDURE use below SQL query. Change parameters as required
-- call oe_sp_monthly_acc('CONSTRUCTION',2017,10);







-- STORED PROCEDURE to view all transaction belongs to particular division
DROP PROCEDURE IF EXISTS `oe_sp_monthly_tran`;
DELIMITER //
CREATE PROCEDURE `oe_sp_monthly_tran`(
  IN `Enter_Division` ENUM('IT','CONSTRUCTION','TEXTILE') CHARSET utf8,
  IN `Enter_Year` YEAR(4),
  IN `Enter_Month` INT(2) UNSIGNED
)
BEGIN
    SELECT *
    FROM oe_transaction TRAN
    WHERE TRAN.tran_div_name = Enter_Division
    AND YEAR(TRAN.tran_datetime) = Enter_Year
    AND MONTH(TRAN.tran_datetime) = Enter_Month
    ORDER BY TRAN.tran_datetime DESC;
END //
DELIMITER;

-- To call above STORED PROCEDURE use below SQL query. Change parameters as required
-- call oe_sp_monthly_tran('IT',2017,10);








-- Get product listing on frontend
SELECT
MTBL.product_id,MTBL.product_name,MTBL.product_safe_url,MTBL.product_added_datetime,
MTBL.product_group_id,
MTBL.product_is_ready_to_dispatch,MTBL.product_quantity, MTBL.product_min_order_qty, MTBL.product_is_hot_favourite, MTBL.product_is_featured,
MTBL.product_image_type, MTBL.product_selling_price, MTBL.product_max_retail_price,
MTBL.product_enable_inquiry, MTBL.product_enable_purchase, MTBL.product_is_upcoming, MTBL.product_discount,
BM.bm_safe_url AS product_bm_safe_url,
BM.bm_name AS product_bm_name,
COUNT(PVC.view_pvcc_count) AS product_view_count,
(
    SELECT GROUP_CONCAT(SPCM.cm_safe_url)
    FROM oe_product_category SPC
    INNER JOIN oe_category_master SPCM ON SPC.pcat_cm_id = SPCM.cm_id
    WHERE SPC.pcat_product_id = MTBL.product_id
    ORDER BY SPCM.cm_level ASC
) AS product_cm_safe_url,
(
    SELECT SUM(SPM.product_quantity)FROM oe_product_master SPM
    WHERE SPM.product_psg_id = PSG.psg_id
) AS product_group_quantity,
(
    SELECT GROUP_CONCAT(CONCAT_WS('*',SFM.ftm_is,SFM.ftm_display_title,SFVM.ftvm_name,SFM.ftm_type,SSFM.ftm_display_title) SEPARATOR '|' )
    FROM
    oe_product_feature SPF,
    oe_feature_value_master SFVM,
    oe_feature_master SFM
    LEFT JOIN oe_feature_master SSFM ON SFM.ftm_sub = SSFM.ftm_safe_url
    WHERE  SPF.pfeature_product_id = MTBL.product_id
    AND SPF.pfeature_ftm_safe_url = SFM.ftm_safe_url
    AND SPF.pfeature_ftvm_safe_url = SFVM.ftvm_safe_url
    AND SFM.ftm_enable_search = '1'
    AND SFM.ftm_is != '1'
    ORDER BY SFM.ftm_is ASC
) AS product_feature_list,
(
    SELECT GROUP_CONCAT(CONCAT_WS('*',TM.tm_safe_url,TM.tm_name) SEPARATOR '|')
    FROM oe_product_tag PT,
    oe_tag_master TM
    WHERE  PT.ptag_product_id = MTBL.product_id
    AND TM.tm_safe_url = PT.ptag_tm_safe_url
) AS product_tag_list,
PSG.*
FROM oe_product_master MTBL
INNER JOIN oe_product_style_group PSG ON MTBL.product_psg_id = PSG.psg_id
INNER JOIN oe_brand_master BM ON MTBL.product_bm_id = BM.bm_id
INNER JOIN oe_product_category PC ON MTBL.product_id = PC.pcat_product_id
INNER JOIN oe_category_master PCM ON PCM.cm_id = PC.pcat_cm_id
INNER JOIN oe_business_master BUSM ON BUSM.busm_id = MTBL.product_busm_id
LEFT JOIN oe_product_tag PT ON MTBL.product_id = PT.ptag_product_id
LEFT JOIN oe_view_product_view_current_count PVC ON MTBL.product_id = PVC.view_pvcc_product_id
WHERE 1
AND
(
  SELECT SUM(SPM.product_quantity)
  FROM oe_product_master SPM
  WHERE SPM.product_psg_id = PSG.psg_id
) > ?
AND PCM.cm_safe_url IN (?)
AND product_selling_price BETWEEN ? AND ?
AND MTBL.product_is_active = ?
AND
(
    SELECT COUNT(*) FROM oe_product_feature WPF
    WHERE WPF.pfeature_product_id = MTBL.product_id
    AND WPF.pfeature_ftm_safe_url = ?
    AND WPF.pfeature_ftvm_safe_url IN (?)
) = 1
AND
(
    SELECT COUNT(*) FROM oe_product_feature WPF
    WHERE WPF.pfeature_product_id = MTBL.product_id
    AND WPF.pfeature_ftm_safe_url = ?
    AND WPF.pfeature_ftvm_safe_url IN (?)
) = 1
AND PCM.cm_is_active = ?
AND BUSM.busm_is_active = ?
AND BUSM.busm_is_verified = ?
AND BUSM.busm_is_deleted = ?
AND BUSM.busm_is_blocked = ?
AND MTBL.product_selling_price > 0
AND
(
  SELECT GROUP_CONCAT(SPCM.cm_is_active ORDER BY SPCM.cm_level ASC)
  FROM oe_product_category SPC
  INNER JOIN oe_category_master SPCM ON SPC.pcat_cm_id = SPCM.cm_id
  WHERE SPC.pcat_product_id = MTBL.product_id
) = ?
GROUP BY PSG.psg_id
ORDER BY product_added_datetime DESC
LIMIT 0,12






-- Get property based on POLYGON
SELECT
M.MLS_NUM, ListingKey, mls_is_pic_url_supported, M.ListPrice, M.PropertyType, M.SubType,
M.Beds,M.Baths,M.Main_Photo, M.Pic_Download_Flag2, M.BathsFull, M.BathsHalf, M.SQFT, M.MLSP_ID,
CONCAT(M.MLS_NUM,'-',M.MLSP_ID) AS ListingID_MLS, AI.LotSize,M.Old_Price, LastUpdateDate,
M.YearBuilt,M.ListingStatus ,Subdivision, M.Description, TotalPhotos, Parking,M.Is_OpenHouse,
M.Is_ShortSale,(DATEDIFF(CURRENT_DATE(), ListingDate)) AS DOM, A.StreetNumber, A.StreetName,
A.StreetDirPrefix, A.StreetDirSuffix, A.CityName, A.State, A.StateName, A.County, ZipCode,
DisplayAddress, A.UnitNo_2, O.Office_Name, AI.HOA_Fee, M.TotalAcreage,
IF(M.`PropertyType` = 'Land and Lots', 1, 0) AS PT, A.StreetDirection, StreetSuffix, UnitNo,
M.Parking, M.YearBuilt, A.Latitude, A.Longitude,
(
  SELECT OH_Date
  FROM listing_open_house LMOH
  WHERE M.MLS_NUM = LMOH.MLS_NUM
  AND M.MLSP_ID = LMOH.MLSP_ID
  AND LMOH.OH_Date >= CURRENT_DATE()
  ORDER BY LMOH.OH_Date ASC
  LIMIT 1
) AS open_house_date
FROM listing_master AS M
LEFT JOIN listing_address AS A ON M.MLS_NUM = A.MLS_NUM AND M.MLSP_ID = A.MLSP_ID
LEFT JOIN listing_office AS O ON M.OfficeID = O.Office_ID AND M.MLSP_ID = O.Office_MLSP_ID
LEFT JOIN mls_master AS MM ON M.MLSP_ID = MM.MLSP_ID
LEFT JOIN listing_additional_info AS AI ON M.MLS_NUM = AI.MLS_NUM AND M.MLSP_ID = AI.MLSP_ID
WHERE 1
AND ( FIND_IN_SET('Land and Lots',PropertyType) OR FIND_IN_SET('Residential',PropertyType) )
AND (A.Latitude != '' AND A.Longitude != '' AND A.Latitude != 0 AND A.Longitude != 0)
AND st_contains(
  GeomFromText(
    'POLYGON((33.58272 -111.97793000000001,33.56284 -111.97782000000001,33.56185 -111.97751,33.561870000000006 -111.98791,33.55588 -111.98793,33.5559 -111.99572999999998,33.53191 -111.99571000000003,33.53184 -112.01312000000001,33.51831 -112.01289000000003,33.51719 -112.01013999999998,33.515530000000005 -112.00636000000003,33.51435 -112.00188000000003,33.513540000000006 -112.00030000000004,33.513470000000005 -111.99525,33.52376 -111.99513999999999,33.52483 -111.99219,33.524770000000004 -111.98864000000003,33.52367 -111.98658,33.5231 -111.98554999999999,33.523610000000005 -111.98459000000003,33.52382 -111.98316,33.523770000000006 -111.97796,33.524010000000004 -111.97684000000004,33.52431 -111.97635000000002,33.524010000000004 -111.97582,33.523770000000006 -111.97505000000001,33.5238 -111.97363000000001,33.521840000000005 -111.97356000000002,33.52192 -111.96958000000001,33.517340000000004 -111.96963,33.516290000000005 -111.94326999999998,33.50916 -111.94328999999999,33.509510000000006 -111.92610000000002,33.51274 -111.92602,33.512640000000005 -111.91791,33.517120000000006 -111.91678999999999,33.51682 -111.92846000000003,33.53851 -111.92822999999999,33.53873 -111.92570999999998,33.57493 -111.92590000000001,33.575030000000005 -111.94334000000003,33.58225 -111.94334000000003,33.5827 -111.96064000000001,33.58272 -111.97793000000001))'
  ), point(Latitude, Longitude)
)
AND ListingStatus IN ('Active','Pending')
AND M.is_mark_for_deletion = 'N'
AND M.ListPrice > 0
ORDER BY PT ASC, SQFT DESC







-- Get property data to show on google map
SELECT
M.MLS_NUM, ListingKey, mls_is_pic_url_supported, M.MLSP_ID, ListPrice, Beds, BathsFull, BathsHalf,
M.PropertyType,M.Baths,M.Listing_Created_Date,M.SubType, Subdivision, SQFT,
CONCAT(M.MLS_NUM,'-',M.MLSP_ID) AS ListingID_MLS, Parking, Garage, DisplayAddress, A.StreetName,
Address, A.StreetNumber, A.StreetDirection, StreetSuffix, UnitNo, ZipCode, A.CityName, A.County, A.State,
AI.Sold_Date, AI.Sold_Price, AI.LotSize, (DATEDIFF(CURRENT_DATE(), Listing_Created_Date)) AS Day_on_market,
Category, ListingStatus, YearBuilt, Stories, A.Latitude, A.Longitude,O.Office_Name,
(
  6378.7 * ACOS(
   SIN(A.Latitude / 57.2958) *
   SIN(35.644367218000000 / 57.2958) +
   COS(A.Latitude / 57.2958) *
   COS(35.644367218000000 / 57.2958) *
   COS(-120.732368469000000 / 57.2958 - (A.Longitude) / 57.2958)
  )
) AS Miles
FROM listing_master AS M
LEFT JOIN listing_address AS A ON M.MLS_NUM = A.MLS_NUM AND M.MLSP_ID = A.MLSP_ID
LEFT JOIN mls_master AS MM ON M.MLSP_ID = MM.MLSP_ID
LEFT JOIN listing_office AS O ON M.OfficeID = O.Office_ID AND M.MLSP_ID = O.Office_MLSP_ID
LEFT JOIN listing_additional_info AS AI ON M.MLS_NUM = AI.MLS_NUM AND M.MLSP_ID = AI.MLSP_ID
WHERE 1
AND M.MLS_NUM NOT IN ('PR201247')
AND PropertyType = 'Residential'
AND (FIND_IN_SET(SubType, 'Single Family Residence'))
AND M.SQFT >= '3400'
AND M.SQFT <= '4600'
AND
(
  6378.7 * ACOS(
    SIN(A.Latitude / 57.2958) *
    SIN(35.644367218000000 / 57.2958) +
    COS(A.Latitude / 57.2958 ) *
    COS(35.644367218000000 / 57.2958 ) *
    COS(-120.732368469000000 / 57.2958 - ( A.Longitude ) / 57.2958)
  )
) < 3
AND ListingStatus = 'Active'
AND M.is_mark_for_deletion = 'N'
ORDER BY Miles ASC
LIMIT 0,6