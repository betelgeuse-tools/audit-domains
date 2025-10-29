# DKIM / SPF / DMARC PowerShell Auditor

A simple PowerShell script to check DKIM, SPF, and DMARC configurations for a list of domains and export the results to CSV.

This tool is useful for:
- Security / CTI teams
- Email infrastructure audits
- Migration / onboarding
- Verifying domain authentication settings

## Features

- Check SPF (v=spf1) record presence + full TXT value
- Check DKIM for multiple selectors
- Parse common DMARC tags (p, sp, rua, ruf, adkim, aspf, pct, etc.)
- Console summary + CSV export
- Lightweight — no external dependencies
- Human-readable results

Note:  
This script does not compute DKIM key length — it only reports selector presence (OK / Absent).

## Example Usage

Open PowerShell in the directory containing the script and list.txt, then run:

```
# If execution is blocked
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Run the script
./audit_dkim_spf_dmarc.ps1
```

## Required Files

### list.txt

A text file containing one domain per line:

```
example.com
test.org
mydomain.net
```

### PowerShell script

`audit_dkim_spf_dmarc.ps1`

DKIM selectors to check are configured in the script:

```
$selecteursDKIM = @(
    "default",
    "selector1",
    "selector2",
    "myselector"
)
```

Modify as needed.

## Output

### CSV report

The script generates:

```
Audit_DKIM_SPF_DMARC_YYYYMMDD_HHMMSS.csv
```

It includes:
- SPF status and value
- DKIM status per selector
- DMARC tags and raw record

Example columns:

```
Domain | SPF_Statut | SPF_Details | DKIM_default | DKIM_selector1 | DMARC_Statut | DMARC_p | DMARC_rua | ...
```

### Console summary

```
Domain : example.com
  SPF   : OK
  DKIM default : OK
  DKIM selector1 : None
  DKIM selector2 : None
  DKIM myselector : OK
  DMARC : OK
----------------------------------
```

## Installation

```
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

Add domains to list.txt and run the script.

No external dependencies required.

## Requirements

- Windows PowerShell 5.1+
- DNS outbound access

Also works on PowerShell 7+ with DNS enabled.

## Limitations

- DKIM selectors must be manually listed
- No automatic DKIM key discovery
- No DKIM key length calculation
- DNS resolution depends on your resolver

## Example Workflow

1. Add domains to list.txt
2. Edit DKIM selectors if needed
3. Run script
4. Check:
   - Console summary
   - CSV report

## Possible Enhancements

| Feature | Difficulty |
|--------|------------|
| Auto DKIM selector discovery | ★★★ |
| Parallel / multithreaded DNS lookups | ★★☆ |
| JSON / HTML export | ★☆☆ |
| SIEM / ELK export | ★★★ |
| Email / webhook reporting | ★★☆ |

PRs welcome.

## License

This project is licensed under the MIT License.

## Contributions

Pull requests, issues, and feedback are welcome!

If you find this useful, please star ⭐ the repository.
