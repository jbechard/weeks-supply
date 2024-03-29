SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ITEM,SUM(AFP_QTY) as AFP
FROM SEAS_ITEM si 
JOIN SEAS s ON s.SEAS=si.SEAS
WHERE s.ACTIVE = 1 AND AFP_QTY > 0
GROUP BY ITEM