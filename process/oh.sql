SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT oh.ITEM,SUM(oh.QTY) as QTY
FROM (

	SELECT warehouse,item,stock 
	from Avi_On_Hand_Live 
	UNION ALL
	SELECT warehouse,item,stock 
	from Avi_On_Hand_Live_113 
	UNION ALL
	SELECT warehouse,item,stock 
	from Avi_On_Hand_Live_116
	UNION ALL
	SELECT warehouse,item,stock 
	from Avi_On_Hand_Live_119
	UNION ALL
	SELECT warehouse,item,stock 
	from Avi_On_Hand_Live_120 

) oh (LOC,ITEM,QTY)
JOIN ITEM itm ON itm.ITEM=oh.ITEM
WHERE 
	ITEM_GRP IN(301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,389,390) AND
	LOC NOT IN ('F98','F99','H99','Y8E') AND
	LOC NOT LIKE '3*' AND  
	LOC NOT LIKE '6*' AND  
	QTY > 0 
GROUP BY oh.ITEM



