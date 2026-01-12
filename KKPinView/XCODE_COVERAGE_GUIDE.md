# How to Check Code Coverage in Xcode

## Step-by-Step Instructions

### Step 1: Open the Package in Xcode

1. Navigate to the `KKPinView` directory in Terminal:
   ```bash
   cd /Users/kamal/Documents/GitHub/KKPinView_SwiftUI/KKPinView
   ```

2. Open the package in Xcode:
   ```bash
   open Package.swift
   ```
   
   Or manually: In Xcode, go to `File` → `Open` → Select `Package.swift` in the `KKPinView` folder

### Step 2: Enable Code Coverage

1. In Xcode, go to the menu bar
2. Click `Product` → `Scheme` → `Edit Scheme...`
   - Or use keyboard shortcut: `Cmd + <` (Cmd + Shift + ,)
3. In the scheme editor dialog:
   - Select **`Test`** from the left sidebar (under "Run", "Test", "Profile", etc.)
   - In the right panel, find the **`Options`** tab
   - Check the box **`Gather coverage for:`**
   - Select **`All targets`** from the dropdown (or select specific targets if needed)
4. Click **`Close`** to save

### Step 3: Run Tests

1. Run the test suite:
   - Press **`Cmd + U`** (shortcut)
   - Or go to `Product` → `Test`
   - Or click the play button next to any test class/method

2. Wait for tests to complete (you'll see a progress indicator in the top toolbar)

### Step 4: View Code Coverage Report

1. Open the **Report Navigator**:
   - Press **`Cmd + 9`**
   - Or go to `View` → `Navigators` → `Reports`
   - Or click the report icon in the navigator bar (left sidebar)

2. In the Report Navigator:
   - You'll see a list of test runs (most recent at the top)
   - Select the latest test run (it will show a timestamp)

3. View Coverage:
   - In the main editor area, you'll see tabs: `Tests`, `Coverage`, etc.
   - Click on the **`Coverage`** tab

4. Explore Coverage Data:
   - You'll see a list of all source files with their coverage percentages
   - Files are organized by target/module
   - Coverage percentage shows next to each file

### Step 5: View Line-by-Line Coverage

1. In the Coverage tab, click on any file name (e.g., `KKPinViews.swift`)
2. Xcode will open the file with coverage indicators:
   - **Green bars on the left**: Lines covered by tests
   - **Red bars on the left**: Lines NOT covered by tests
   - **Gray areas**: Non-executable code (comments, blank lines)

3. You can also view coverage while editing:
   - Open any source file in the editor
   - Code coverage indicators will appear on the left margin
   - Hover over coverage indicators to see execution counts

## Tips

- **Coverage percentages**: Aim for high coverage (80%+ is good, 90%+ is excellent)
- **Focus areas**: Pay special attention to business logic, error handling, and edge cases
- **UI components**: Some UI code may show lower coverage as it requires UI tests
- **Compare runs**: You can compare coverage between different test runs

## Quick Reference

| Action | Shortcut |
|--------|----------|
| Open Package | `open Package.swift` (Terminal) |
| Edit Scheme | `Cmd + <` (Cmd + Shift + ,) |
| Run Tests | `Cmd + U` |
| Open Report Navigator | `Cmd + 9` |
| View Coverage | Click "Coverage" tab in test report |

## Troubleshooting

- **Coverage not showing?**: Make sure you enabled "Gather coverage for" in the scheme settings
- **No test results?**: Ensure tests ran successfully (check for errors in the test navigator)
- **Coverage percentages seem off?**: Some files (like constants) may show 0% if they don't have executable code

## Example Coverage Targets

For this project, aim for good coverage on:
- ✅ `KKPinViews.swift` - Main PIN entry logic
- ✅ `KKPINSetUPView.swift` - PIN setup logic  
- ✅ `KKPinLockoutManager.swift` - Lockout management
- ✅ `KKPinStorage.swift` - PIN storage operations
- ✅ `KKEncryptionHelper.swift` - Encryption/decryption
- ⚠️ UI components may have lower coverage (require UI tests)

