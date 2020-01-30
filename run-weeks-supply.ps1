Set-Location $PSScriptRoot
$script_name = '\\kcmsv007\..\run-weeks-supply.ps1'
$master_log = '\\kcmsv001\groups\Production\Data Analysis\Master_Report_Log.log'
$local_log = '.\run-weeks-supply.log'
$err_ct = 0
    
function main {
    "Started at $(get-date -Format 'yyyy-MM-dd hh:mm:ss').";""
	
    
	# Item table.
	pushd C:\repos\supplychainplanning-etl
	try{  .\item.ps1			            ;""}   catch{Handle-Error}
	popd

	# Calculate AFP in SeasFcst.
	pushd C:\repos\seasfcst-daily-maint
	try{.\calc_afp_qty.ps1  		        ;""}   catch{Handle-Error}
	popd

	# Run Weeks of Supply.
	try{  
		# Production and inventory.
		pushd C:\repos\supplychainplanning-etl
		.\pln_prod.ps1		 ;""
		.\Invenotry_Live.ps1 ;""
		popd

		# Update actual production in SeasFcst.
		pushd C:\repos\seasfcst-etl
		try{.\item_plant_act_prod.ps1           ;""}   catch{Handle-Error}
		popd

		# Run Weeks of Supply.
		pushd c:\repos\weeks-supply\process
		try{.\REFRESH_WOS_DATA.bat              ;""}   catch{Handle-Error}
		popd

		# Send email notification.
		$to = 'James.Bechard@rstover.com','PRODPL@rstover.com','DemandPlanning@rstover.com'
		send-mailmessage -To $to -Subject "Weeks of Supply Data is READY" -SmtpServer 'email.rstover.com' -From 'james.bechard@rstover.com'
	}
	catch{Handle-Error}
	
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
