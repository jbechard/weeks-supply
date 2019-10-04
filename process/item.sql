SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
  itm.item,
  description,
  selection_cd,
  sig_cd,
  item_grp,
  planner,
  units_per_carton,
  wc.WK_CTR_TYPE as dflt_wk_ctr,
  cross_ship,
  country_of_sale
FROM ITEM itm
LEFT JOIN PLNR_CD_WK_CTR_TYPE wc ON wc.PLNR_CD=itm.Planner
WHERE item_grp IN(301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,389,390);
