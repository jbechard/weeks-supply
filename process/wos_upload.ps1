# Variables particular to this table update.

# NOTE: column number and order must match between the text file and the staging table. Column names need not match.
$sql_create_staging_table = @"
    CREATE TABLE etl.WEEKS_SUPPLY (
        ITEM VARCHAR(100),
        DESCR VARCHAR(100),
        SC VARCHAR(100),
        SIG_CD VARCHAR(100),
        ITEM_GRP VARCHAR(100),
        PLANNER VARCHAR(100),
        CS_PACK VARCHAR(100),
        DFLT_WK_CTR VARCHAR(100),
        CROSS_SHIP VARCHAR(100),
        COUNTRY_OF_SALE VARCHAR(100),
        ITEM_CLASS VARCHAR(100),
        AFP VARCHAR(100),
        AFP_CHG VARCHAR(100),
        PTD VARCHAR(100),
        ON_HAND VARCHAR(100),
        TOT_SEAS_FCST VARCHAR(100),
        METRIC VARCHAR(100),
        [1] VARCHAR(100),[2] VARCHAR(100),[3] VARCHAR(100),[4] VARCHAR(100),[5] VARCHAR(100),[6] VARCHAR(100),[7] VARCHAR(100),[8] VARCHAR(100),[9] VARCHAR(100),[10] VARCHAR(100),[11] VARCHAR(100),[12] VARCHAR(100),[13] VARCHAR(100),[14] VARCHAR(100),[15] VARCHAR(100),[16] VARCHAR(100),[17] VARCHAR(100),[18] VARCHAR(100),[19] VARCHAR(100),[20] VARCHAR(100),[21] VARCHAR(100),[22] VARCHAR(100),[23] VARCHAR(100),[24] VARCHAR(100),[25] VARCHAR(100),[26] VARCHAR(100),[27] VARCHAR(100),[28] VARCHAR(100),[29] VARCHAR(100),[30] VARCHAR(100),[31] VARCHAR(100),[32] VARCHAR(100),[33] VARCHAR(100),[34] VARCHAR(100),[35] VARCHAR(100),[36] VARCHAR(100),[37] VARCHAR(100),[38] VARCHAR(100),[39] VARCHAR(100),[40] VARCHAR(100),[41] VARCHAR(100),[42] VARCHAR(100),[43] VARCHAR(100),[44] VARCHAR(100),[45] VARCHAR(100),[46] VARCHAR(100),[47] VARCHAR(100),[48] VARCHAR(100),[49] VARCHAR(100),[50] VARCHAR(100),[51] VARCHAR(100),[52] VARCHAR(100),
    )
"@

$sql_merge_into_final = @"
    DELETE dbo.WEEKS_SUPPLY WHERE EXTRACT_DT >= CAST(GETDATE() AS DATE);
    
    INSERT dbo.WEEKS_SUPPLY (
       ITEM
      ,DESCR
      ,SC
      ,SIG_CD
      ,ITEM_GRP
      ,PLANNER
      ,CS_PACK
      ,DFLT_WK_CTR
      ,CROSS_SHIP
      ,COUNTRY_OF_SALE
      ,ITEM_CLASS
      ,AFP
      ,AFP_CHG
      ,PTD
      ,ON_HAND
      ,TOT_SEAS_FCST
      ,METRIC
      ,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52]
      ,EXTRACT_DT
    )
    SELECT
       ITEM
      ,DESCR
      ,SC
      ,SIG_CD
      ,ITEM_GRP
      ,PLANNER
      ,CS_PACK
      ,DFLT_WK_CTR
      ,CROSS_SHIP
      ,COUNTRY_OF_SALE
      ,ITEM_CLASS
      ,AFP
      ,AFP_CHG
      ,PTD
      ,ON_HAND
      ,TOT_SEAS_FCST
      ,METRIC
      ,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52]
      ,GETDATE()      
    FROM etl.WEEKS_SUPPLY
"@

$script_dir = split-path (split-path -path $MyInvocation.MyCommand.Path -parent) -parent

$source_file = join-path -path $script_dir\data -childpath wos_data.csv
$field_delim = "|"
$has_hdr_row = 1 # 1=True; 0=False
$destination_server = "giasv013" 
$destination_db = "SupplyChainPlanning" 
$destination_staging_table = "etl.WEEKS_SUPPLY" 
$batch_size = 50000
.\ETL_SupplyChainPlanning_TextFile.ps1 `
    $source_file `
    $field_delim `
    $has_hdr_row `
    $sql_create_staging_table `
    $sql_merge_into_final `
    $destination_server `
    $destination_db `
    $destination_staging_table `
    $batch_size
