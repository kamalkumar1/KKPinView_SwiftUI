#!/bin/bash

# Script to check code coverage for KKPinView Swift Package
# Usage: ./check_coverage.sh

set -e

echo "📊 Generating Code Coverage Report for KKPinView..."
echo ""

# Change to the package directory
cd "$(dirname "$0")"

# Run tests with code coverage enabled
echo "🧪 Running tests with code coverage enabled..."
swift test --enable-code-coverage

# Find the .xctestresult bundle (usually in .build directory)
RESULT_BUNDLE=$(find .build -name "*.xctestresult" -type d | head -n 1)

if [ -z "$RESULT_BUNDLE" ]; then
    echo "❌ Error: Could not find test result bundle"
    exit 1
fi

echo ""
echo "✅ Tests completed successfully!"
echo ""
echo "📈 Coverage data location: $RESULT_BUNDLE"
echo ""
echo "To view coverage in Xcode:"
echo "1. Open the project in Xcode"
echo "2. Press Cmd+9 to open Report Navigator"
echo "3. Select the latest test run"
echo "4. Click on the 'Coverage' tab"
echo ""
echo "To generate a text report, use:"
echo "xcrun llvm-cov report .build/debug/KKPinViewPackageTests.xctest/Contents/MacOS/KKPinViewPackageTests -instr-profile=$RESULT_BUNDLE/coverage.profdata"
echo ""

