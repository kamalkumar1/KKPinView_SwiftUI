# Enabling Code Coverage for Swift Package Manager in Xcode

For Swift Package Manager projects, code coverage settings work slightly differently than regular Xcode projects.

## Method 1: Enable Coverage via Command Line (Recommended)

For Swift Package Manager projects, the easiest way is to enable coverage via command line:

```bash
cd KKPinView
swift test --enable-code-coverage
```

Then open the package in Xcode to view the results.

## Method 2: Enable Coverage in Xcode Scheme (For SPM Projects)

### Step-by-Step:

1. **Open Package in Xcode:**
   ```bash
   cd KKPinView
   open Package.swift
   ```

2. **Edit Scheme:**
   - Go to `Product` → `Scheme` → `Edit Scheme...`
   - Or use keyboard shortcut: `Cmd + <` (Cmd + Shift + ,)

3. **Select Test Action:**
   - In the left sidebar, select **`Test`** (under Build, Run, Test, etc.)

4. **Look for Coverage Options:**
   - In newer Xcode versions, you might see:
     - **`Options`** tab (click it)
     - Look for **`Code Coverage`** section
     - Check **`Gather coverage data`** or similar checkbox
   
   OR
   
   - In some Xcode versions, it might be:
     - **`Code Coverage`** checkbox directly in the Test settings
     - Or under **`Info`** tab → **`Code Coverage`** section

5. **If you don't see coverage options:**
   - This is normal for Swift Package Manager projects
   - Coverage is often handled automatically
   - Try Method 1 (command line) instead

## Method 3: Enable Coverage via Build Settings (Alternative)

If the scheme option isn't available:

1. Select the test target in Project Navigator
2. Go to **Build Settings**
3. Search for "coverage"
4. Enable **`Enable Code Coverage Support`** (if available)

## Method 4: View Coverage After Running Tests (Works Regardless)

Even if you can't find the scheme setting:

1. **Run Tests:**
   - `Product` → `Test` (or `Cmd + U`)

2. **View Coverage:**
   - Press `Cmd + 9` to open **Report Navigator**
   - Select the latest test run
   - Click **`Coverage`** tab
   - Coverage data should be available if tests ran successfully

## For Swift Package Manager: Coverage is Usually Automatic

When you open a Swift Package in Xcode:
- Coverage data is often collected automatically when tests run
- You don't always need to enable it explicitly in scheme settings
- The scheme settings might not show the same options as regular Xcode projects

## Verify Coverage is Working

1. **Run tests in Xcode:**
   - `Cmd + U`

2. **Check Report Navigator:**
   - `Cmd + 9`
   - Select test run
   - Look for **`Coverage`** tab

3. **If Coverage tab exists:**
   - Coverage is working!
   - Click it to see coverage percentages

4. **If Coverage tab is missing:**
   - Try running tests with command line first:
     ```bash
     cd KKPinView
     swift test --enable-code-coverage
     ```
   - Then open Xcode and check again

## Quick Test

Run this to verify coverage works:

```bash
cd KKPinView
swift test --enable-code-coverage 2>&1 | head -20
```

If tests run successfully, coverage data is being generated. Then check in Xcode's Report Navigator.

## Notes

- Swift Package Manager projects don't always show the same scheme options as regular Xcode projects
- Coverage might be enabled by default for SPM projects
- Using command line (`swift test --enable-code-coverage`) is the most reliable method
- The coverage data will still appear in Xcode's Report Navigator even if you enable it via command line

