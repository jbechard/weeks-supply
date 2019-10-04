SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH WK_ONE_SHIPMENTS (ITEM,SHIP_QTY) AS (
	SELECT ITEM,SUM(CASES)
	FROM SHIPMENT s 
	JOIN CALENDAR c ON c.CAL_DT=s.SHIPMENT_DT
	WHERE c.RELATIVE_WK = 0 AND ORDER_TYPE NOT IN('195','650')
	AND WAREHOUSE NOT IN('F98','F99','H98','H99')
	GROUP BY ITEM
),
ITEM_WK_FCST (ITEM,RELATIVE_WK,OPEN_ORD,CONS_DMD) AS (
  SELECT f.ITEM,c.RELATIVE_WK + 1 as RelWk,SUM(OPEN_ORD) OPEN_ORD,SUM(CONS_DMD) CONS_DMD
  FROM FORECAST f 
  JOIN CALENDAR c ON c.CAL_DT=f.ACT_END_DATE AND c.IS_WEEKENDING = 'Y'
  WHERE c.RELATIVE_WK BETWEEN 0 AND 51
  GROUP BY f.ITEM,c.RELATIVE_WK + 1
)
SELECT *
FROM (
  SELECT f.ITEM,f.RELATIVE_WK,
    CASE 
      WHEN f.RELATIVE_WK = 1
      THEN CASE WHEN CONS_DMD - COALESCE(s.SHIP_QTY,0) < OPEN_ORD THEN OPEN_ORD ELSE CONS_DMD - COALESCE(s.SHIP_QTY,0) END
      ELSE CONS_DMD
    END as FCST
  FROM ITEM_WK_FCST f 
  LEFT JOIN WK_ONE_SHIPMENTS s ON s.ITEM=f.ITEM
  WHERE CONS_DMD > 0 OR (f.RELATIVE_WK = 1 AND (s.SHIP_QTY > 0 OR OPEN_ORD > 0))
) t
PIVOT (  
  SUM(FCST)
  FOR RELATIVE_WK IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52])
) pvt
ORDER BY ITEM;
