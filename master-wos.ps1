Set-Location $PSScriptRoot
$master_log = '\\kcmsv001\groups\Production\Data Analysis\Master_Report_Log.log'
$err_ct = 0
    
function main {
    "Started at $(get-date -Format 'yyyy-MM-dd hh:mm:ss').";""
	
	pushd C:\repos\supplychainplanning-etl\master-wos.ps1
    
	# Update shipments and open orders in SupplyChainPlanning.
    try{  .\delivery_header.ps1             ;""}   catch{Handle-Error}
    try{  .\delivery_line.ps1               ;""}   catch{Handle-Error}
    try{  .\open_ord.ps1                    ;""}   catch{Handle-Error}
	
	# Update Prescient demand and SeasFcst demand; sync SeasFcst with Presc; consume Reg item forecast; refresh RSC_FCST_EXTRACT.
	try{  .\run-presc-group-11a.bat          ;""}   catch{Handle-Error}
	try{  .\run-presc-group-13.bat           ;""}   catch{Handle-Error}
	try{  .\run-presc-group-14.bat           ;""}   catch{Handle-Error}
	try{  .\run-presc-group-22.bat           ;""}   catch{Handle-Error}
	try{  .\run-presc-group-15.bat           ;""}   catch{Handle-Error}
	
	# Update other tables in SupplyChainPlanning.
	try{  .\item.ps1			            ;""}   catch{Handle-Error}
	try{  .\pln_prod.ps1					;""}   catch{Handle-Error}
	try{  .\forecast.ps1      				;""}   catch{Handle-Error}
    try{  .\tot_seas_fcst_snapshot.ps1      ;""}   catch{Handle-Error}
    try{  .\Invenotry_Live.ps1              ;""}   catch{Handle-Error}
	
	popd
	
	# Update actual production in SeasFcst.
	pushd C:\repos\seasfcst-etl
	try{.\item_plant_act_prod.ps1           ;""}   catch{Handle-Error}
	popd
	
	# Calculate AFP in SeasFcst.
	pushd C:\repos\seasfcst-daily-maint
	try{.\calc-afp-qty.ps1  		        ;""}   catch{Handle-Error}
	popd
	
	# Conditionally run WoS and send email notification.
	if ($script:err_ct = 0) {
		# Run Weeks of Supply.
		pushd c:\repos\weeks-supply\process
		try{.\REFRESH_WOS_DATA.bat              ;""}   catch{Handle-Error}
		popd
	}
	if ($script:err_ct = 0) {
		# Send email notification.
		$to = 'James.Bechard@rstover.com','PRODPL@rstover.com','DemandPlanning@rstover.com'
		send-mailmessage -To $to -Subject "Weeks of Supply Data is READY" -SmtpServer 'email.rstover.com' -From 'james.bechard@rstover.com'
	}
	
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
    
main | out-file -FilePath '.\master-wos.log' -encoding ascii
$script_name = '\SupplyChainPlanning\etl\master.ps1'
"$(log_dt), $script_name, COMPLETED with $err_ct errors." | out-file -FilePath $master_log -Append -encoding ascii
