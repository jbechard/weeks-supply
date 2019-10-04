SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT *
FROM (
  SELECT 
    RTRIM(oo.ITEM) as ITEM, 
    CASE WHEN DATEDIFF(wk,GETDATE(),PlanDeliveryDate) < 1 THEN 1 ELSE DATEDIFF(wk,GETDATE(),PlanDeliveryDate) + 1 END as RelWk,
    OrderQuantity
  FROM OpenOrders oo 
  JOIN ITEM im ON im.ITEM=oo.ITEM
  JOIN CUSTOMER_HIERARCHY_EXT ch ON ch.CUSTOMER=oo.Customer
  WHERE OrderQuantity > 0 AND 
    OrderType IN ('195','650') AND
    [item_grp] IN(301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,389,390) AND
    ch.FCST_CUST_GRP <> 'ROSS'
) AS t
PIVOT (  
  SUM(OrderQuantity)
  FOR RelWk IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52])
) AS pvt
ORDER BY ITEM