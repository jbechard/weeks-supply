@ECHO OFF

pushd %~dp0

(
    ECHO %DATE% %TIME%

    ECHO.
    ECHO EXTRACTING ITEM MASTER DATA...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i item.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' | Out-File -encoding ASCII ..\data\item.csv"

    ECHO.
    ECHO EXTRACTING PLANNED PRODUCTION...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i pln_prod.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\prod.csv"

    ECHO.
    ECHO EXTRACTING PRODUCED TO DATE...
    sqlcmd -S giasv013 -d SeasFcst -i ptd.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\ptd.csv"

    ECHO.
    ECHO EXTRACTING AFP...
    copy ..\data\afp.csv ..\data\afp_prior.csv > nul
    sqlcmd -S giasv013 -d SeasFcst -i AFP.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\afp.csv"

    ECHO.
    ECHO EXTRACTING ON HAND INVENTORY...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i oh.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\oh.csv"

    ECHO.
    ECHO EXTRACTING OPEN ORDERS...
    sqlplus /nolog @oo.sql
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\oo.csv"

    ECHO.
    ECHO EXTRACTING NON-STANDARD OPEN ORDERS...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i oo_non_std.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\oo_non_std.csv"

    ECHO.
    ECHO EXTRACTING FORECAST...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i fcst.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\fcst.csv"

    ECHO.
    ECHO EXTRACTING TOTAL SEASON FORECAST...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i tot_seas_fcst.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\tot_seas_fcst.csv"

    ECHO.
    ECHO EXTRACTING ITEM CLASS...
    sqlcmd -S giasv013 -d SupplyChainPlanning -i item_class.sql -o tmp.csv -s, -h -1
    powershell -ExecutionPolicy Bypass -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\item_class.csv"

    IF %ERRORLEVEL% NEQ 0 (
        ECHO ERROR %ERRORLEVEL%
        EXIT /B 1
    )

    ECHO.
    ECHO DATA EXTRACTION COMPLETE.

    ECHO.
    ECHO MERGING DATA AND PRODUCING REPORT FILE...
    PowerShell -ExecutionPolicy Bypass .\integrate.ps1

    IF %ERRORLEVEL% NEQ 0 (
        ECHO ERROR %ERRORLEVEL%
        EXIT /B 1
    )

    ECHO.
    ECHO UPLOADING REPORT FILE TO SupplyChainPlanning.dbo.WEEKS_SUPPLY...
    PowerShell -ExecutionPolicy Bypass .\wos_upload.ps1

    IF %ERRORLEVEL% NEQ 0 (
        ECHO ERROR %ERRORLEVEL%
        EXIT /B 1
    )

    ECHO.
    ECHO SCRIPT COMPLETE!
    for /F "tokens=2-4 delims=/ " %%G IN ("%date%") do (set _dt=%%G/%%H/%%I)
    for /F "tokens=1 delims=." %%G IN ("%time%") do (set _tm=%%G)
    ECHO %_dt% %_tm%, Weeks of Supply, COMPLETED SUCCESSFULLY >> "\\kcmsv001\groups\Production\Data Analysis\Master_Report_Log.log"
) > wos.log






