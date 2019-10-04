function Get-objItem {
    process {
        If ( -Not $htItems.ContainsKey($_) ) {$htItems[$_] = [clsItem]::new($_)}
        $htItems[$_]
    }
}


$htItems = @{}

$OutputFile = Join-Path -Path (get-item $pwd).parent.Fullname -ChildPath 'data\wos_data.csv'
Remove-Item $OutputFile -ErrorAction Ignore
$sw = new-object system.IO.StreamWriter($OutputFile)



#Import Total Season Forecast.
gc '..\data\tot_seas_fcst.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).TotSeasFcst = $ar[1]
}
Write-Host 'Imported Total Season Forecast.'

#Import AFP.
gc '..\data\afp.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).Afp = $ar[1]
}
Write-Host 'Imported AFP.'

#Import Prior AFP.
gc '..\data\afp_prior.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).PriorAfp = $ar[1]
}
Write-Host 'Imported Prior AFP.'

#Import On Hand.
gc '..\data\oh.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).OnHand = $ar[1]
}
Write-Host 'Imported On Hand.'

#Import Produced to Date.
gc '..\data\ptd.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).Ptd = $ar[1]
}
Write-Host 'Imported PTD.'

#Import Forecast.
gc '..\data\fcst.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).arFcst = $ar[1..52]
}
Write-Host 'Imported Forecast.'

#Import Production.
gc '..\data\prod.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).arPlnProd = $ar[1..52]
}
Write-Host 'Imported Production.'

#Import Open Orders.
gc '..\data\oo.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).arOpenOrd = $ar[1..52]
}
Write-Host 'Imported Open Orders.'

#Import Non-Standard Open Orders.
gc '..\data\oo_non_std.csv' | foreach -process {
    $ar = $_.Split(',')
    ($ar[0].Trim() | Get-objItem).arOpenOrdNonStd = $ar[1..52]
}
Write-Host 'Imported Non-Standard Open Orders.'

#Import Item Class.
gc '..\data\item_class.csv' | foreach -process {
    $ar = $_.Split(',')
    If ( $htItems.ContainsKey($ar[0].Trim()) ) { $htItems[$ar[0].Trim()].ItemClass = $ar[1].Trim() } 
}
Write-Host 'Imported Item Class.'

#Import Item Master Data.
gc '..\data\item.csv' | foreach -process {
    $ar = $_.Split(',')
    $strItem = $ar[0].Trim()
    If ( $htItems.ContainsKey($strItem) ) {
        $objItem = $htItems[$strItem]
        $objItem.Descr = $ar[1].Trim()
        $objItem.Sc = $ar[2].Trim()
        $objItem.SigCd = $ar[3].Trim()
        $objItem.ItemGrp = $ar[4].Trim()
        $objItem.Planner = $ar[5].Trim()
        $objItem.CsPack = $ar[6].Trim()
        $objItem.DfltWkCtr = $ar[7].Trim()
        $objItem.CrossShip = $(if ($ar[8].Trim() -eq 1) {'Y'} else {'N'})
        $objItem.CountryOfSale = $ar[9].Trim()
    } 
}
Write-Host 'Imported Item Master Data.'


#File Header(s).
#$sw.writeline(('|'*17) + ($(for($wk=1;$wk -le 52;$wk++){(get-date).adddays((7*$wk)-1-(get-date).dayofweek).ToShortDateString()}) -join "|"))
$sw.writeline([String]'Item|Descr|Sc|Sig Cd|Item Grp|Planner|Cs Pack|Dflt Wk Ctr|Cross Ship|Country Of Sale|Item Class|Afp|Afp Chg|Ptd|On Hand|Tot Seas Fcst|Metric' + 
'|' + (@(1..52) -join '|'))


try {
    [long] $ct = 0
   foreach ($strItem in $htItems.Keys) {
       $objItem = $htItems[$strItem]
    
        $item_attributes = $objItem.ItemAttributes() -join "|"
        $sw.writeline($item_attributes + '|1-Afp Pct|' + ($objItem.AfpPercentArray() -join "|"))
        $sw.writeline($item_attributes + '|2-Fcst|' + ($objItem.arFcst -join "|"))
        $sw.writeline($item_attributes + '|3-OpenOrd|' + ($objItem.arOpenOrd -join "|"))
        $sw.writeline($item_attributes + '|4-NonStdOrders|' + ($objItem.arOpenOrdNonStd -join "|"))
        $sw.writeline($item_attributes + '|5-Final Demand|' + ($objItem.FinalDemandArray() -join "|"))
        $sw.writeline($item_attributes + '|6-PlnProd|' + ($objItem.arPlnProd -join "|"))
        $sw.writeline($item_attributes + '|7-EndInv|' + ($objItem.EndInventoryArray() -join "|"))
        $sw.writeline($item_attributes + '|8-Weeks Supply|' + ($objItem.WoSArray() -join "|"))

        $ct++;if($ct % 100 -eq 0){"$ct items processed."}  
   }
}
finally {
    $sw.close()
}

Class clsItem {
    [String] $Item
    [String] $Descr
    [String] $Sc
    [String] $SigCd
    [String] $ItemGrp
    [String] $Planner
    [int] $CsPack
    [String] $DfltWkCtr
    [String] $CrossShip
    [String] $CountryOfSale
    [String] $ItemClass
    [long] $Afp
    [long] $PriorAfp
    [long] $Ptd
    [long] $OnHand
    [long] $TotSeasFcst
    [array] $arFcst
    [array] $arOpenOrd
    [array] $arOpenOrdNonStd
    [array] $arPlnProd
   

    # Constructor 
    clsItem ([String] $item) 
    {
        $this.Item = $item
        for ($i = 1; $i -le 52; $i++) {$this.arFcst += @($null)}
        for ($i = 1; $i -le 52; $i++) {$this.arOpenOrd += @($null)}
        for ($i = 1; $i -le 52; $i++) {$this.arOpenOrdNonStd += @($null)}
        for ($i = 1; $i -le 52; $i++) {$this.arPlnProd += @($null)}
    }

    [String] ToString()
    {
        return $this.Item
    }
    
    [array] ItemAttributes()
    {
        return @(
            $this.Item,$this.Descr,$this.Sc,$this.SigCd,$this.ItemGrp,$this.Planner,$this.CsPack,
            $this.DfltWkCtr,$this.CrossShip,$this.CountryOfSale,$this.ItemClass,$this.Afp,$this.AfpChg(),
            $this.Ptd,$this.OnHand,$this.TotSeasFcst
        )
    }
    
    [double] AfpChg() {return $($this.Afp - $this.PriorAfp)}
    
    [array] FinalDemandArray()
    {
        return $(
            foreach ($wk in @(0..51)) {
                [int32]$this.arFcst[$wk] + [int32]$this.arOpenOrdNonStd[$wk]
            }
        )
    }
       
    [array] EndInventoryArray()
    {
        $arFcst_NonStdOrders = $this.FinalDemandArray()
        return $(
            $endinv = $this.OnHand + $this.arPlnProd[0] - $arFcst_NonStdOrders[0]
            foreach ($wk in @(1..51)) {
                $endinv
                $endinv = $endinv + $this.arPlnProd[$wk] - $arFcst_NonStdOrders[$wk]
            }
        )
    }
    
    [array] CumProductionArray()
    {
        $cumProd = $this.Ptd
        return $($this.arPlnProd | %{$cumProd += $_; $cumProd})
    }
    
    [array] WoSArray()
    {
        $arFcst_NonStdOrders = $this.FinalDemandArray()
        $arEndInv = $this.EndInventoryArray()
        return $(
            for ($wk=0;$wk -le 51;$wk++) {
                $cumFcst = 0;$wos = 0
                for ($fcst_wk=$wk+1;$fcst_wk -le 51;$fcst_wk++) {
                    $cumFcst += $arFcst_NonStdOrders[$fcst_wk]
                    if ($cumFcst -lt $arEndInv[$wk]) {$wos++}
                }
                if ( ($wos -eq 0) -and (($arFcst_NonStdOrders[($wk+1)..51] -gt 0).length -eq 0) ){-1} else {$wos}
            }
        )
    }
    
    [array] AfpPercentArray()
    {
        return $(
            if ($this.Afp -gt 0) {
                $arCumProd = $this.CumProductionArray()
                for ($wk=0;$wk -le 51;$wk++) {[math]::Round(($arCumProd[$wk] / $this.Afp),2)}
            } else {foreach ($wk in @(0..51)){-1}}
        )
    }


}
<# 

# Instance Method
[String] getAlias()
{
    return $this.Alias
}

# Static Method
static [String] getClan()
{
    return [CyberNinja]::Clan
}

# Static Method
static [String] Whisper ([String] $Name)
{
    return "Hello {0}!" -f $Name
}

Public Property Get EndInv(wk)
    If wk > 1 Then
        EndInv = EndInv(wk-1) + PlnProd(wk) - Fcst(wk)
    Else # wk = 1.
        EndInv = Me.OnHand + PlnProd(wk) - Fcst(wk)
    End If
End Property

 #>