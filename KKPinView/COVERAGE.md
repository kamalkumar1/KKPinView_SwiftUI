# Code Coverage Guide

This guide explains how to check code coverage for the KKPinView Swift Package.

## Method 1: Using Command Line (Swift Package Manager)

### Run tests with code coverage enabled:

```bash
cd KKPinView
swift test --enable-code-coverage
```

### View coverage using the script:

```bash
cd KKPinView
./check_coverage.sh
```

### Generate detailed coverage report:

After running tests with coverage enabled, you can generate a detailed text report:

```bash
# Find the test executable
find .build -name "KKPinViewPackageTests" -type f

# Generate coverage report (replace paths as needed)
xcrun llvm-cov report \
  .build/debug/KKPinViewPackageTests.xctest/Contents/MacOS/KKPinViewPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata
```

### Generate HTML coverage report:

```bash
xcrun llvm-cov show \
  .build/debug/KKPinViewPackageTests.xctest/Contents/MacOS/KKPinViewPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata \
  -format=html \
  -output-dir=coverage_report
```

## Method 2: Using Xcode (Recommended)

1. **Open the Package in Xcode:**
   ```bash
   cd KKPinView
   open Package.swift
   ```

2. **Enable Code Coverage:**
   - Go to `Product` → `Scheme` → `Edit Scheme...`
   - Select `Test` from the left sidebar
   - Check `Gather coverage for` → Select `All targets`

3. **Run Tests:**
   - Press `Cmd + U` or go to `Product` → `Test`

4. **View Coverage Report:**
   - Press `Cmd + 9` to open the Report Navigator
   - Select the latest test run
   - Click on the `Coverage` tab
   - You'll see coverage percentages for each file

5. **View Line-by-Line Coverage:**
   - In the Coverage tab, click on any file
   - Lines will be color-coded:
     - **Green**: Covered by tests
     - **Red**: Not covered by tests
     - **Gray**: Not executable (comments, blank lines, etc.)

## Coverage Targets

The following files are part of the codebase and should have test coverage:

### Core Views
- `KKPinViews.swift` - Main PIN entry view
- `KKPINSetUPView.swift` - PIN setup view
- `PinDigitField.swift` - Individual digit field
- `NumericKeypad.swift` - Numeric keypad component

### Utilities
- `KKPinviewConstant.swift` - Constants configuration
- `KKPinLockoutManager.swift` - Lockout management

### Security Components (KeyGenerator folder)
- `KKPinStorage.swift` - PIN storage
- `KKSecureKeyGenerator.swift` - Key generation
- `KKSecureKey.swift` - Secure key wrapper
- `KKEncryptionHelper.swift` - Encryption utilities

## Test Files

- `KKPinViewTests.swift` - Base test file
- `KKPinViewsTests.swift` - Tests for KKPinViews
- `KKPINSetUPViewTests.swift` - Tests for KKPINSetUPView

## Notes

- Code coverage data is stored in `.build/debug/codecov/` directory
- Coverage reports help identify untested code paths
- Aim for high coverage, but focus on testing critical business logic
- UI components may require UI tests for full coverage

