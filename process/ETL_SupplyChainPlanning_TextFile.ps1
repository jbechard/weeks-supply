# Variables particular to this table update.
param ( `
    [string]$source_file, 
    [string]$field_delim,
    [bool]$has_hdr_row,
    [string]$sql_create_staging_table,
    [string]$sql_merge_into_final,
    [string]$destination_server, 
    [string]$destination_db,
    [string]$destination_staging_table, `
    [long]$batchsize = 50000 `
)
 
Write-Host "Beginning Script."
$elapsed = [System.Diagnostics.Stopwatch]::StartNew() 

try {

    # CommandTimeout.
    $command_timeout = 60 * 2 # seconds.
     
    # Database variables 
    $destination_connect = "Data Source=$destination_server;Integrated Security=true;Initial Catalog=$destination_db;" # TransparentNetworkIPResolution=False" 
    $destination_conn = New-Object System.Data.SqlClient.SqlConnection
    $destination_conn.ConnectionString = $destination_connect
    $destination_cmd = New-Object System.Data.SqlClient.SqlCommand
    $destination_cmd.Connection = $destination_conn
    $destination_cmd.CommandTimeout = $command_timeout
    $destination_conn.Open()
     
    # Create staging table.
    $destination_cmd.CommandText = "IF OBJECT_ID('$destination_staging_table', 'U') IS NOT NULL DROP TABLE $destination_staging_table;" 
    $destination_cmd.ExecuteNonQuery() | out-null
    $destination_cmd.CommandText = $sql_create_staging_table
    $destination_cmd.ExecuteNonQuery() | out-null

    # Build the sqlbulkcopy connection, and set the timeout to infinite. 
    $bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($destination_connect, [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock) 
    $bulkcopy.DestinationTableName = $destination_staging_table 
    $bulkcopy.bulkcopyTimeout = 0 
    $bulkcopy.batchsize = $batchsize 

    # Create the datatable. 
    $datatable = New-Object System.Data.DataTable 

    # build columns of data table, and get extract date.
    $streamIn = [System.IO.StreamReader] $source_file
    $line_elements = $streamIn.ReadLine().Split($field_delim)
    for ($i=1; $i -le $line_elements.length; $i++) {$datatable.Columns.Add() | out-null} 
    $streamIn.Close()

    # begin extract. 
    $streamIn = [System.IO.StreamReader] $source_file
    if ($has_hdr_row){$streamIn.ReadLine() | out-null}
    while ($line = $streamIn.ReadLine()) {
        $line_elements = $line.Split('|')
        $datatable.Rows.Add($line_elements) | out-null
        # Import and empty the datatable before it starts taking up too much RAM, but  
        # after it has enough rows to make the import efficient. 
        $i++; if (($i % $batchsize) -eq 0) {  
            $bulkcopy.WriteToServer($datatable)  
            Write-Host "$i rows inserted to [$destination_staging_table]." 
            $datatable.Clear()  
            [System.GC]::Collect()
            $x = $i
        }
    }
    # Add in all the remaining rows since the last clear. 
    if($datatable.Rows.Count -gt 0) { 
        $bulkcopy.WriteToServer($datatable) 
        $datatable.Clear() 
        $x = $i
    } 
    Write-Host "$x rows inserted to [$destination_staging_table]." 
    Write-Host "Staging table insert complete. Elapsed time: $($elapsed.Elapsed.ToString())."

    # Merge staged data into final table.
    $destination_cmd.CommandText = $sql_merge_into_final
    $raff=0;$raff = $destination_cmd.ExecuteNonQuery()
    Write-Host "$raff rows merged into the final table. Elapsed time: $($elapsed.Elapsed.ToString())." 

    # Drop staging table.
#    $destination_cmd.CommandText = "DROP TABLE $destination_staging_table"
    $null = $destination_cmd.ExecuteNonQuery()

    Write-Host "Script complete. Elapsed time: $($elapsed.Elapsed.ToString())."
}

catch {
    Write-Host "SCRIPT FAILED. Elapsed time: $($elapsed.Elapsed.ToString())."
    $_
    $line
    throw
}

finally {
    # Clean Up 
    $destination_cmd.Dispose()
    $datatable.Dispose() 
    $streamIn.Close()
    # Sometimes the Garbage Collector takes too long to clear the huge datatable. 
    [System.GC]::Collect()

}

