@ECHO OFF

pushd %~dp0


REM ECHO.
REM ECHO EXTRACTING ITEM MASTER DATA...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i item.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' | Out-File -encoding ASCII ..\data\item.csv"

REM ECHO.
REM ECHO EXTRACTING PLANNED PRODUCTION...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i pln_prod.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\prod.csv"

REM ECHO.
REM ECHO EXTRACTING PRODUCED TO DATE...
REM sqlcmd -S giasv013 -d SeasFcst -i ptd.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\ptd.csv"

REM ECHO.
REM ECHO EXTRACTING AFP...
REM copy ..\data\afp.csv ..\data\afp_prior.csv > nul
REM sqlcmd -S giasv013 -d SeasFcst -i AFP.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\afp.csv"

REM ECHO.
REM ECHO EXTRACTING ON HAND INVENTORY...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i oh.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\oh.csv"

REM ECHO.
REM ECHO EXTRACTING OPEN ORDERS...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i oo.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\oo.csv"

REM ECHO.
REM ECHO EXTRACTING NON-STANDARD OPEN ORDERS...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i oo_non_std.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\oo_non_std.csv"

REM ECHO.
REM ECHO EXTRACTING FORECAST...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i fcst.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\fcst.csv"

REM ECHO.
REM ECHO EXTRACTING TOTAL SEASON FORECAST...
REM sqlcmd -S giasv013 -d SeasFcst -i tot_seas_fcst.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\tot_seas_fcst.csv"

REM ECHO.
REM ECHO EXTRACTING FORECAST...
REM sqlcmd -S giasv013 -d SupplyChainPlanning -i item_class.sql -o tmp.csv -s, -h -1
REM powershell -Command "(gc tmp.csv) -replace 'NULL','' -replace ' ','' | Out-File -encoding ASCII ..\data\item_class.csv"

REM ECHO.
REM ECHO DATA EXTRACTION COMPLETE.

ECHO.
ECHO MERGING DATA AND PRODUCING REPORT FILE...
PowerShell .\integrate.ps1

ECHO.
ECHO UPLOADING REPORT FILE TO SupplyChainPlanning.dbo.WEEKS_SUPPLY...
PowerShell .\wos_upload.ps1

ECHO.
ECHO SCRIPT COMPLETE!



