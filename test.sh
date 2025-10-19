#!/bin/bash
# Quick test script to verify functionality

set -e

echo "================================"
echo "KrankyBear Document Censor Tests"
echo "================================"
echo ""

# Build binaries
echo "1. Building binaries..."
go build -o redactsecure ./cmd/redactsecure
go build -o redactsecure-decrypt ./cmd/redactsecure-decrypt
echo "✓ Build successful"
echo ""

# Test 1: Word Document Replace
echo "2. Testing Word document search & replace..."
if [ -f "test/Custom Content Training & Questions.docx" ]; then
    ./redactsecure -file "test/Custom Content Training & Questions.docx" \
        -op replace -search "tanium" -replace "COMPANY_X" \
        -output "test/word_test.docx" > /dev/null
    echo "✓ Word document test passed"
else
    echo "⚠ Word test file not found, skipping"
fi
echo ""

# Test 2: Excel Replace
echo "3. Testing Excel search & replace..."
if [ -f "test/01-TrainingSchedules.xlsx" ]; then
    ./redactsecure -file "test/01-TrainingSchedules.xlsx" \
        -op replace -search "training" -replace "SESSION" \
        -output "test/excel_test.xlsx" > /dev/null
    echo "✓ Excel test passed"
else
    echo "⚠ Excel test file not found, skipping"
fi
echo ""

# Test 3: PowerPoint Replace
echo "4. Testing PowerPoint search & replace..."
if [ -f "test/00-Training_Introduction-AllanM.pptx" ]; then
    ./redactsecure -file "test/00-Training_Introduction-AllanM.pptx" \
        -op replace -search "Allan" -replace "TEST_USER" \
        -output "test/ppt_test.pptx" > /dev/null
    echo "✓ PowerPoint test passed"
else
    echo "⚠ PowerPoint test file not found, skipping"
fi
echo ""

# Test 3.5: Case-insensitive Replace
echo "4.5. Testing case-insensitive search..."
if [ -f "test/Custom Content Training & Questions.docx" ]; then
    # Count replacements with case-sensitive search
    cs_count=$(./redactsecure -file "test/Custom Content Training & Questions.docx" \
        -op replace -search "tanium" -replace "COMPANY" \
        -output "test/case_sensitive_count.docx" 2>&1 | grep "Total replacements:" | awk '{print $3}')
    
    # Count replacements with case-insensitive search
    ci_count=$(./redactsecure -file "test/Custom Content Training & Questions.docx" \
        -op replace -search "tanium" -replace "COMPANY" -i \
        -output "test/case_insensitive_count.docx" 2>&1 | grep "Total replacements:" | awk '{print $3}')
    
    # Case-insensitive should find more matches
    if [ "$ci_count" -gt "$cs_count" ]; then
        echo "✓ Case-insensitive test passed (found $ci_count vs $cs_count)"
    else
        echo "✗ Case-insensitive test failed (expected more matches)"
        exit 1
    fi
    
    rm -f test/case_sensitive_count.docx test/case_insensitive_count.docx
else
    echo "⚠ Test file not found, skipping case-insensitive test"
fi
echo ""

# Test 4: Encryption
echo "5. Testing encryption..."
if [ -f "test/Custom Content Training & Questions.docx" ]; then
    ./redactsecure -file "test/Custom Content Training & Questions.docx" \
        -op encrypt -password "TestPassword123" \
        -output "test/encrypted_test.docx.enc" > /dev/null
    echo "✓ Encryption test passed"
else
    echo "⚠ Test file not found, skipping encryption test"
fi
echo ""

# Test 5: Decryption
echo "6. Testing decryption..."
if [ -f "test/encrypted_test.docx.enc" ]; then
    ./redactsecure-decrypt -file "test/encrypted_test.docx.enc" \
        -password "TestPassword123" \
        -output "test/decrypted_test.docx" > /dev/null
    
    # Verify decrypted file matches original
    if diff "test/Custom Content Training & Questions.docx" "test/decrypted_test.docx" > /dev/null; then
        echo "✓ Decryption test passed (file matches original)"
    else
        echo "✗ Decryption test failed (file doesn't match original)"
        exit 1
    fi
else
    echo "⚠ Encrypted file not found, skipping decryption test"
fi
echo ""

# Test 6: Wrong password
echo "7. Testing wrong password rejection..."
if [ -f "test/encrypted_test.docx.enc" ]; then
    if ./redactsecure-decrypt -file "test/encrypted_test.docx.enc" \
        -password "WrongPassword" -output "test/should_fail.docx" 2>/dev/null; then
        echo "✗ Wrong password test failed (should have been rejected)"
        exit 1
    else
        echo "✓ Wrong password correctly rejected"
    fi
else
    echo "⚠ Encrypted file not found, skipping wrong password test"
fi
echo ""

# Cleanup
echo "8. Cleaning up test files..."
rm -f test/word_test.docx test/excel_test.xlsx test/ppt_test.pptx
rm -f test/encrypted_test.docx.enc test/decrypted_test.docx test/should_fail.docx
echo "✓ Cleanup complete"
echo ""

echo "================================"
echo "All tests passed! ✓"
echo "================================"

