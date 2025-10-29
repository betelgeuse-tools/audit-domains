<#
Audit DKIM / SPF / DMARC
#>

$domainListFile = "list.txt"

# DKIM selectors to check
$dkimSelectors = @(
    "default",
    "selector1",
    "selector2",
    "myselector"
)

# Output CSV filename
$outputCsv = "Audit_DKIM_SPF_DMARC_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"


# Simple DNS resolver
function Resolve-DNS {
    param (
        [string]$Domain,
        [string]$Type
    )
    try {
        Resolve-DnsName -Name $Domain -Type $Type -ErrorAction Stop
    } catch {
        $null
    }
}

# Simple DMARC parser
function Parse-DMARC {
    param([string]$record)
    $hash = @{}
    foreach ($item in $record.Split(';')) {
        if ($item -match '^\s*([^=]+)=(.*)') {
            $hash[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    $hash
}

# Load domain list
$domains = Get-Content $domainListFile | Where-Object { $_.Trim() -ne "" }

$results = @()

foreach ($domain in $domains) {

    ### SPF ###
    $spf = Resolve-DNS -Domain $domain -Type "TXT" |
        Where-Object { $_.Strings -match "v=spf1" }

    $spfStatus = if ($spf) { "OK" } else { "None" }


    ### DKIM ###
    $dkimResults = @{}
    foreach ($selector in $dkimSelectors) {

        $dk = Resolve-DNS -Domain "$selector._domainkey.$domain" -Type "TXT"

        if ($dk) {
            $dkimResults["DKIM_$selector"] = "OK"
        } else {
            $dkimResults["DKIM_$selector"] = "None"
        }
    }


    ### DMARC ###
    $dmarc = Resolve-DNS -Domain "_dmarc.$domain" -Type "TXT"

    if ($dmarc) {
        $dmarcString = $dmarc.Strings -join " "
        $dmarcData = Parse-DMARC $dmarcString
        $dmarcStatus = "OK"
    } else {
        $dmarcData = @{}
        $dmarcString = "N/A"
        $dmarcStatus = "None"
    }


    ### Build CSV row ###
    $row = [ordered]@{
        Domain        = $domain
        SPF_Status    = $spfStatus
        SPF_Details   = if ($spf) { $spf.Strings -join " " } else { "N/A" }
        DMARC_Status  = $dmarcStatus
        DMARC_v       = $dmarcData.v
        DMARC_p       = $dmarcData.p
        DMARC_pct     = $dmarcData.pct
        DMARC_sp      = $dmarcData.sp
        DMARC_rua     = $dmarcData.rua
        DMARC_ruf     = $dmarcData.ruf
        DMARC_adkim   = $dmarcData.adkim
        DMARC_aspf    = $dmarcData.aspf
        DMARC_fo      = $dmarcData.fo
        DMARC_rf      = $dmarcData.rf
        DMARC_ri      = $dmarcData.ri
        DMARC_Record  = $dmarcString
    }

    # Add DKIM results
    foreach ($selector in $dkimSelectors) {
        $row["DKIM_$selector"] = $dkimResults["DKIM_$selector"]
    }

    $results += [pscustomobject]$row
}

# Export to CSV
$results | Export-Csv -Path $outputCsv -Delimiter ";" -Encoding UTF8 -NoTypeInformation -Force

# Console summary
$results | ForEach-Object {
    Write-Host "Domain : $($_.Domain)"
    Write-Host "  SPF   : $($_.SPF_Status)"
    foreach ($selector in $dkimSelectors) {
        Write-Host "  DKIM $selector : $($_.("DKIM_$selector"))"
    }
    Write-Host "  DMARC : $($_.DMARC_Status)"
    Write-Host "----------------------------------"
}

Write-Host "`nAudit completed. CSV saved to: $outputCsv" -ForegroundColor Green