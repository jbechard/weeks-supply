SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ITEM, SUM(FCST) TOT_SEAS_FCST
FROM seasfcst..WAVE_DETAIL_EXT wdx JOIN seasfcst..SEAS s ON s.SEAS=wdx.SEAS
WHERE s.END_SHIP_DT > GETDATE()
GROUP BY ITEM