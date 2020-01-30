Set-Location $PSScriptRoot
$script_name = '\\kcmsv007\..\sync-consume-and-publish-fcst.ps1'
$master_log = '\\kcmsv001\groups\Production\Data Analysis\Master_Report_Log.log'
$local_log = '.\sync-consume-and-publish-fcst.log'
$err_ct = 0

	
function main {
    "Started at $(get-date -Format 'yyyy-MM-dd hh:mm:ss').";""
	
	pushd C:\repos\supplychainplanning-etl
    	
	try{  
	# Update Prescient demand and SeasFcst demand; sync SeasFcst with Presc; consume Reg item forecast; refresh RSC_FCST_EXTRACT.
		.\run-presc-group-13.bat ;""
		.\run-presc-group-14.bat ;""
		.\run-presc-group-22.bat ;""
		.\run-presc-group-15.bat ;""
	# Update other tables in SupplyChainPlanning.
		.\forecast.ps1
		.\tot_seas_fcst_snapshot.ps1
	} 
	catch{Handle-Error}
	
	popd
		
    "$script:err_ct errors encountered."
    "";"Ended at $(get-date -Format 'yyyy-MM-dd hh:mm:ss')."
}   

function Handle-Error {
    $script:err_ct += 1
    
    # Write error to script host.
    $err_msg = "$($error[0].ToString()) `n $($error[0].invocationinfo.positionmessage)"
    write-host $err_msg
    
    # Send email notification.
    $script = $(split-path $error[0].exception.errorrecord.invocationinfo.scriptname -leaf)
    $from = 'james.bechard@rstover.com'
    $to = 'james.bechard@rstover.com','Avi.Dias@rstover.com'
    $subject = "ERROR in Script: $script"
    $server = 'email.rstover.com'
    send-mailmessage -To $to -Subject $subject -SmtpServer $server -From $from -Body $err_msg

    # Write to master log.
    "$(log_dt), $script, ERROR: $($error[0].ToString())" | out-file -FilePath $master_log -Append -encoding ascii

    # Clear the error.
    $error.Clear()
	
	# Exit Powershell.
	Exit
}

function log_dt {get-date -Format 'MM/dd/yyyy hh:mm:ss'}
    
main | out-file -FilePath $local_log -encoding ascii
"$(log_dt), $script_name, COMPLETED with $err_ct errors." | out-file -FilePath $master_log -Append -encoding ascii