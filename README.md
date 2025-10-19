# KrankyBear RedactSecure Document Censor

A cross-platform command-line tool for manipulating Microsoft Office files (.docx, .xlsx, .pptx) with search/replace and encryption capabilities.

## Quick Start

```bash
# Build the tools
go build -o redactsecure ./cmd/redactsecure
go build -o redactsecure-decrypt ./cmd/redactsecure-decrypt

# Replace text in a document (case-sensitive)
./redactsecure -file document.docx -op replace -search "old" -replace "new"

# Replace text (case-insensitive - matches Old, OLD, oLd, etc.)
./redactsecure -file document.docx -op replace -search "old" -replace "new" -i

# Encrypt a file
./redactsecure -file document.docx -op encrypt -password "MySecurePassword"

# Decrypt a file
./redactsecure-decrypt -file document.docx.enc -password "MySecurePassword"
```

## Features

- **Search & Replace**: Find and replace text in Word documents, Excel spreadsheets, and PowerPoint presentations
- **Case-Insensitive Search**: Optional `-i` flag to match text regardless of capitalization
- **Encryption**: Encrypt Office files with password protection using AES-256-GCM
- **Decryption**: Companion tool to decrypt encrypted files
- **In-Memory Processing**: All operations performed in memory without creating temporary files
- **Cross-Platform**: Works on Windows, Linux, and macOS

## Building

### Prerequisites
- Go 1.21 or higher

### Build Instructions

#### For your current platform:
```bash
go build -o redactsecure ./cmd/redactsecure
go build -o redactsecure-decrypt ./cmd/redactsecure-decrypt
```

#### Cross-compilation for all platforms:

**Windows:**
```bash
GOOS=windows GOARCH=amd64 go build -o redactsecure.exe ./cmd/redactsecure
GOOS=windows GOARCH=amd64 go build -o redactsecure-decrypt.exe ./cmd/redactsecure-decrypt
```

**Linux:**
```bash
GOOS=linux GOARCH=amd64 go build -o redactsecure-linux ./cmd/redactsecure
GOOS=linux GOARCH=amd64 go build -o redactsecure-decrypt-linux ./cmd/redactsecure-decrypt
```

**macOS (Intel):**
```bash
GOOS=darwin GOARCH=amd64 go build -o redactsecure-mac-intel ./cmd/redactsecure
GOOS=darwin GOARCH=amd64 go build -o redactsecure-decrypt-mac-intel ./cmd/redactsecure-decrypt
```

**macOS (Apple Silicon):**
```bash
GOOS=darwin GOARCH=arm64 go build -o redactsecure-mac-arm ./cmd/redactsecure
GOOS=darwin GOARCH=arm64 go build -o redactsecure-decrypt-mac-arm ./cmd/redactsecure-decrypt
```

## Usage

### Search and Replace

Replace text in an Office document:

```bash
./redactsecure -file document.docx -op replace -search "confidential" -replace "REDACTED"
./redactsecure -file presentation.pptx -op replace -search "John Doe" -replace "Jane Smith"
./redactsecure -file spreadsheet.xlsx -op replace -search "2023" -replace "2024"
```

Case-insensitive search (matches any capitalization):
```bash
./redactsecure -file document.docx -op replace -search "tanium" -replace "COMPANY" -i
# This will match: Tanium, TANIUM, tanium, TaNiUm, etc.
```

With custom output path:
```bash
./redactsecure -file document.docx -op replace -search "secret" -replace "public" -output cleaned_document.docx
```

### Encryption

Encrypt an Office file:

```bash
./redactsecure -file document.docx -op encrypt -password "MySecurePassword123"
./redactsecure -file presentation.pptx -op encrypt -password "SecretKey" -output presentation.enc
```

### Decryption

Decrypt an encrypted file:

```bash
./redactsecure-decrypt -file document.docx.enc -password "MySecurePassword123"
./redactsecure-decrypt -file presentation.enc -password "SecretKey" -output presentation.pptx
```

## How It Works

### Search & Replace
Office files (.docx, .xlsx, .pptx) are actually ZIP archives containing XML files. The tool:
1. Opens the Office file as a ZIP archive in memory
2. Identifies the relevant XML files based on file type:
   - **PowerPoint (.pptx)**: `ppt/slides/slide*.xml`
   - **Word (.docx)**: `word/document.xml`
   - **Excel (.xlsx)**: `xl/worksheets/sheet*.xml`
3. Performs text replacement in these XML files
4. Repackages the modified files into a new Office document

### Encryption
The tool uses industry-standard encryption:
- **Algorithm**: AES-256-GCM (Galois/Counter Mode)
- **Key Derivation**: PBKDF2 with SHA-256
- **Iterations**: 100,000 (provides good security vs performance balance)
- **Salt**: 32-byte random salt (prevents rainbow table attacks)
- **Authentication**: GCM mode provides authenticated encryption

The encrypted file structure:
```
[32 bytes salt][12 bytes nonce][encrypted data + auth tag]
```

## Command-Line Options

### Main Tool (redactsecure)

| Flag | Description | Required |
|------|-------------|----------|
| `-file` | Path to the Office file | Yes |
| `-op` | Operation: `replace` or `encrypt` | No (default: `replace`) |
| `-search` | Text to search for | Yes (for replace) |
| `-replace` | Text to replace with | Yes (for replace) |
| `-i` | Case-insensitive search | No (default: `false`) |
| `-password` | Password for encryption | Yes (for encrypt) |
| `-output` | Output file path | No (auto-generated) |

### Decrypt Tool (redactsecure-decrypt)

| Flag | Description | Required |
|------|-------------|----------|
| `-file` | Path to the encrypted file | Yes |
| `-password` | Password for decryption | Yes |
| `-output` | Output file path | No (removes .enc or adds .decrypted) |

## Examples

### Quick Examples

**Redact sensitive information:**
```bash
./redactsecure -file "Employee_Report.docx" -op replace -search "SSN: 123-45-6789" -replace "SSN: [REDACTED]"
```

**Update company name (case-insensitive):**
```bash
./redactsecure -file "Q4_Presentation.pptx" -op replace -search "acme corp" -replace "GlobalTech Inc" -i
```

**Encrypt sensitive file:**
```bash
./redactsecure -file "Payroll_2024.xlsx" -op encrypt -password "HR_Secure_2024!"
```

**Decrypt file:**
```bash
./redactsecure-decrypt -file "Payroll_2024.xlsx.enc" -password "HR_Secure_2024!"
```

📚 **For more examples and real-world scenarios, see [EXAMPLES.md](EXAMPLES.md)**

## Important Notes

### Text Replacement Limitations
- The tool replaces text in XML content nodes
- Formatted text that spans multiple XML elements may not be replaced as expected
- For example, if "Hello" has "Hel" in bold and "lo" in regular font, it might be stored as separate XML elements
- Test with your specific documents to ensure expected behavior

### Security Considerations
- **Encryption**: AES-256-GCM with PBKDF2 provides good security for most use cases
- **Password Strength**: Use strong, unique passwords for encryption
- **No Password Recovery**: If you lose the password, the file cannot be decrypted
- **File Permissions**: Encrypted files use standard file permissions (0644)

### File Safety
- Original files are never modified - a new file is always created
- Default naming:
  - Replace: `filename_modified.ext`
  - Encrypt: `filename.ext.enc`
  - Decrypt: `filename.ext` (strips .enc) or `filename.ext.decrypted`

## Testing

Test files are included in the `test/` directory:
- `00-Training_Introduction-AllanM.pptx`
- `01-TrainingSchedules.xlsx`
- `Custom Content Training & Questions.docx`

Try the tool with these files to see it in action!

## License

See LICENSE file for details.

## Troubleshooting

### "File is not a valid ZIP archive"
- Ensure the file is a modern Office format (.docx, .xlsx, .pptx)
- Old formats (.doc, .xls, .ppt) are not supported

### "Decryption failed"
- Verify you're using the correct password
- Ensure the file hasn't been corrupted
- Check that the file was encrypted with this tool

### No replacements made
- Check that the search text exactly matches the text in the document
- Remember that text in formatted sections might be split across XML elements
- Try searching for smaller fragments if needed

## Contributing

This is a utility tool - feel free to modify and extend as needed for your use case!

