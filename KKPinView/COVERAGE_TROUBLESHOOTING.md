# Code Coverage Troubleshooting

If your test file (`KKEncryptionHelperTests.swift`) is not showing up in code coverage, try these steps:

## Solution 1: Clean Build and Run Tests Again (Most Common)

1. **Clean Build Folder:**
   - In Xcode: `Product` → `Clean Build Folder` (or `Shift + Cmd + K`)
   - Or in Terminal:
     ```bash
     cd KKPinView
     swift package clean
     ```

2. **Run Tests Again:**
   - In Xcode: `Product` → `Test` (or `Cmd + U`)
   - Or in Terminal:
     ```bash
     cd KKPinView
     swift test --enable-code-coverage
     ```

3. **View Coverage:**
   - In Xcode: `Cmd + 9` → Select latest test run → `Coverage` tab

## Solution 2: Verify Coverage is Enabled

1. **Check Scheme Settings:**
   - In Xcode: `Product` → `Scheme` → `Edit Scheme...`
   - Select `Test` from left sidebar
   - Ensure `Gather coverage for:` is checked
   - Select `All targets` or specific targets

2. **Re-run Tests** after enabling coverage

## Solution 3: Verify Test File is Included

The test file should be in:
```
Tests/KKPinViewTests/KKEncryptionHelperTests.swift
```

Swift Package Manager automatically discovers all `.swift` files in the `Tests` directory.

## Solution 4: Check Test Execution

1. **Verify Tests Run Successfully:**
   - In Xcode Test Navigator (`Cmd + 6`), check that `KKEncryptionHelperTests` appears
   - All test methods should show checkmarks (✅) if they pass

2. **Check Test Output:**
   - Look for any warnings or errors
   - Make sure tests actually execute (check the test execution count)

## Solution 5: Force Xcode to Refresh Coverage

1. **Close and Reopen Xcode**
2. **Delete Derived Data:**
   - In Terminal:
     ```bash
     rm -rf ~/Library/Developer/Xcode/DerivedData/*
     ```
   - Or in Xcode: `Preferences` → `Locations` → Click arrow next to Derived Data path → Delete contents

3. **Re-run Tests**

## Solution 6: Verify Source File Location

The source file should be in:
```
Sources/KKPinView/KeyGenerator/KKEncryptionHelper.swift
```

Coverage tracks source files, not test files. The test file must be in the correct location to execute, but coverage shows for the source files being tested.

## Solution 7: Check Build Settings

1. **Verify Build Configuration:**
   - Make sure you're using Debug configuration (coverage typically only works in Debug)

2. **Check Compiler Flags:**
   - Coverage should be enabled automatically when you enable it in the scheme

## Solution 8: Terminal Test (Verify Tests Run)

Run tests from terminal to verify they execute:

```bash
cd KKPinView
swift test --enable-code-coverage 2>&1 | grep -i "KKEncryptionHelper"
```

You should see output showing that `KKEncryptionHelperTests` ran.

## Common Issues

1. **Tests weren't run after adding the test file** - Coverage only shows for code executed in the latest test run
2. **Coverage disabled in scheme** - Check scheme settings
3. **Using wrong configuration** - Coverage typically works in Debug mode
4. **Stale coverage data** - Clean build folder and re-run tests
5. **Test file not executing** - Check if tests actually run (checkmarks in test navigator)

## Quick Checklist

- [ ] Tests are in `Tests/KKPinViewTests/` directory
- [ ] Source file is in `Sources/KKPinView/` directory  
- [ ] Coverage is enabled in scheme (`Product` → `Scheme` → `Edit Scheme...` → `Test`)
- [ ] Tests actually run (checkmarks in Test Navigator)
- [ ] Build folder is cleaned
- [ ] Tests are run after adding test file
- [ ] Using Debug configuration

If all of these are correct and coverage still doesn't show, try closing and reopening Xcode, or deleting Derived Data.

