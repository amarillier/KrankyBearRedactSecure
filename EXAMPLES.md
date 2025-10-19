# Usage Examples

This document provides detailed examples of how to use KrankyBear RedactSecure

## Table of Contents
1. [Basic Search & Replace](#basic-search--replace)
2. [Batch Processing](#batch-processing)
3. [Encryption Workflow](#encryption-workflow)
4. [Real-World Scenarios](#real-world-scenarios)

## Basic Search & Replace

### Redact Personal Information

Remove email addresses from a Word document:
```bash
./redactsecure -file report.docx -op replace -search "john.doe@company.com" -replace "[REDACTED]"
```

### Update Company Name

Change company name across a PowerPoint presentation:
```bash
./redactsecure -file Q1_Results.pptx -op replace -search "Old Corp Inc" -replace "New Company LLC"
```

### Case-Insensitive Search

Replace text regardless of capitalization:
```bash
# This will match: Microsoft, MICROSOFT, microsoft, MiCrOsOfT, etc.
./redactsecure -file document.docx -op replace -search "microsoft" -replace "COMPANY_X" -i

# Useful for finding all variations of a term
./redactsecure -file contract.docx -op replace -search "confidential" -replace "[REDACTED]" -i
```

### Update Dates in Excel

Replace year references in a spreadsheet:
```bash
./redactsecure -file budget.xlsx -op replace -search "2023" -replace "2024"
```

## Batch Processing

### Process Multiple Files with Bash

Create a script to process multiple files:

```bash
#!/bin/bash
# redact_emails.sh - Replace email addresses in all Office files

for file in *.docx *.xlsx *.pptx; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        ./redactsecure -file "$file" -op replace \
            -search "sensitive@company.com" \
            -replace "[REDACTED]" \
            -output "cleaned_$file"
    fi
done

echo "All files processed!"
```

### Process Multiple Files with PowerShell (Windows)

```powershell
# redact_emails.ps1

$files = Get-ChildItem -Path . -Include *.docx,*.xlsx,*.pptx -Recurse

foreach ($file in $files) {
    Write-Host "Processing: $($file.Name)"
    .\redactsecure.exe -file $file.FullName -op replace `
        -search "sensitive@company.com" `
        -replace "[REDACTED]" `
        -output "cleaned_$($file.Name)"
}

Write-Host "All files processed!"
```

## Encryption Workflow

### Encrypt Sensitive Document

```bash
# Encrypt a confidential file
./redactsecure -file "Confidential_Report.docx" -op encrypt -password "MyStr0ngP@ssw0rd"

# This creates: Confidential_Report.docx.enc
```

### Share Encrypted File Securely

```bash
# 1. Encrypt the file
./redactsecure -file salary_data.xlsx -op encrypt -password "HR_Team_2024"

# 2. Share salary_data.xlsx.enc via email or file sharing
# 3. Share password through a different channel (phone, SMS, etc.)
```

### Decrypt and Restore

```bash
# Decrypt when needed
./redactsecure-decrypt -file salary_data.xlsx.enc -password "HR_Team_2024"

# This restores: salary_data.xlsx
```

## Real-World Scenarios

### Scenario 1: Preparing Documents for Client Review

Remove all internal references before sharing with external parties:

```bash
# Remove internal project codenames
./redactsecure -file proposal.docx -op replace \
    -search "Project Phoenix" \
    -replace "New Initiative"

# Remove internal URLs
./redactsecure -file proposal_modified.docx -op replace \
    -search "internal.company.com" \
    -replace "company.com" \
    -output proposal_client.docx
```

### Scenario 2: Anonymizing Training Materials

Create anonymized versions of documents for training:

```bash
# Replace real employee names (case-insensitive to catch all variations)
./redactsecure -file training_case_study.pptx -op replace \
    -search "Sarah Johnson" \
    -replace "Employee A" \
    -i

# Replace real customer names
./redactsecure -file training_case_study_modified.pptx -op replace \
    -search "Acme Corporation" \
    -replace "Client Company" \
    -i \
    -output training_case_study_anonymized.pptx
```

### Scenario 3: Regulatory Compliance - Data Masking

Mask sensitive data before sharing with auditors:

```bash
# Mask Social Security Numbers
./redactsecure -file employee_records.xlsx -op replace \
    -search "123-45-6789" \
    -replace "XXX-XX-XXXX"

# Mask account numbers
./redactsecure -file employee_records_modified.xlsx -op replace \
    -search "Account:" \
    -replace "Account: [MASKED]" \
    -output employee_records_compliant.xlsx
```

### Scenario 4: Archiving Sensitive Files

Encrypt files before long-term archival:

```bash
#!/bin/bash
# archive_and_encrypt.sh

ARCHIVE_DATE=$(date +%Y%m%d)
PASSWORD="Archive_${ARCHIVE_DATE}_SecureKey"

for file in sensitive_*.{docx,xlsx,pptx}; do
    if [ -f "$file" ]; then
        echo "Encrypting: $file"
        ./redactsecure -file "$file" -op encrypt -password "$PASSWORD"
        
        # Move encrypted file to archive
        mv "${file}.enc" "archive/"
        
        # Optionally remove original
        # rm "$file"
    fi
done

echo "Password for this batch: $PASSWORD" >> archive/archive_${ARCHIVE_DATE}_password.txt
echo "Archival complete!"
```

### Scenario 5: Mass Update Across Presentation Deck

Update outdated information across all slides:

```bash
# Update old product name
./redactsecure -file product_deck.pptx -op replace \
    -search "Product v1.0" \
    -replace "Product v2.0"

# Update pricing
./redactsecure -file product_deck_modified.pptx -op replace \
    -search "$99/month" \
    -replace "$149/month"

# Update contact information
./redactsecure -file product_deck_modified.pptx -op replace \
    -search "sales@oldcompany.com" \
    -replace "sales@newcompany.com" \
    -output product_deck_2024.pptx
```

### Scenario 6: Version-Specific Document Creation

Create multiple versions of the same document:

```bash
#!/bin/bash
# create_versions.sh - Create department-specific versions

TEMPLATE="annual_report_template.docx"
DEPARTMENTS=("Engineering" "Sales" "Marketing" "HR")

for dept in "${DEPARTMENTS[@]}"; do
    echo "Creating version for: $dept"
    
    # Replace department placeholder
    ./redactsecure -file "$TEMPLATE" -op replace \
        -search "[DEPARTMENT]" \
        -replace "$dept" \
        -output "annual_report_${dept}.docx"
        
    # Replace metrics placeholder
    ./redactsecure -file "annual_report_${dept}.docx" -op replace \
        -search "[METRICS]" \
        -replace "${dept} achieved 120% of target" \
        -output "annual_report_${dept}_final.docx"
done
```

### Scenario 7: Secure Document Exchange

Complete workflow for secure document exchange:

```bash
#!/bin/bash
# secure_exchange.sh

RECIPIENT="client"
PASSWORD=$(openssl rand -base64 12)  # Generate random password

echo "Step 1: Redacting sensitive information..."
./redactsecure -file contract_draft.docx -op replace \
    -search "INTERNAL USE ONLY" \
    -replace "" \
    -output contract_for_client.docx

echo "Step 2: Encrypting document..."
./redactsecure -file contract_for_client.docx -op encrypt \
    -password "$PASSWORD"

echo ""
echo "========================================="
echo "Document prepared for: $RECIPIENT"
echo "Encrypted file: contract_for_client.docx.enc"
echo "Password: $PASSWORD"
echo ""
echo "Please send the file and password through separate channels!"
echo "========================================="
```

## Tips and Best Practices

### 1. Always Keep Backups
Never work on original files directly. Always create copies first:
```bash
cp important_file.docx important_file_backup.docx
./redactsecure -file important_file_backup.docx -op replace -search "old" -replace "new"
```

### 2. Test Replacements First
Test your replacement on a small document first to ensure it works as expected.

### 3. Use Strong Passwords for Encryption
Generate strong passwords:
```bash
# Linux/Mac - Generate random password
openssl rand -base64 16

# Or use a password manager
```

### 4. Chain Operations
For complex operations, chain multiple replace commands:
```bash
./redactsecure -file doc.docx -op replace -search "A" -replace "B"
./redactsecure -file doc_modified.docx -op replace -search "C" -replace "D"
```

### 5. Verify Results
After processing, always open the modified file to verify the changes are correct:
- Check that replacements were made correctly
- Ensure document formatting is preserved
- Verify no unintended replacements occurred

### 6. Password Management for Encryption
- Store passwords securely (use a password manager)
- Use different passwords for different files or batches
- Document which password was used for which files
- Never send passwords and encrypted files through the same channel

## Troubleshooting

### No Replacements Found
- Verify the search text exists in the document (case-sensitive!)
- Text split across formatting may not be found (try shorter search strings)
- For Excel, text might be in formulas rather than plain text

### File Won't Decrypt
- Double-check the password (case-sensitive!)
- Ensure the file hasn't been corrupted
- Verify it was encrypted with this tool

### Modified File Won't Open
- Original file may have been corrupted
- File type may not be supported (only .docx, .xlsx, .pptx)
- Try with a fresh copy of the original file

