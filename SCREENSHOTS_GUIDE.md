# Adding Screenshots to README

This guide explains how to add screenshots to your GitHub README.

## Step 1: Create Screenshots Folder

Create a `Screenshots` folder in your repository root:

```bash
mkdir Screenshots
```

## Step 2: Take Screenshots

Take screenshots of your app showing:

1. **PIN Entry View** (`pin-entry.png`)
   - Show the main PIN entry screen
   - All fields empty or partially filled
   - Numeric keypad visible

2. **PIN Setup View** (`pin-setup.png`)
   - Show the PIN setup screen
   - Both "Enter PIN" and "Confirm PIN" sections visible
   - Numeric keypad visible

3. **Error State** (`pin-error.png`)
   - Show the PIN entry screen with an error message
   - Example: "Invalid PIN. Please try again."

4. **Lockout State** (`pin-lockout.png`)
   - Show the lockout screen
   - Example: "Too many failed attempts. Please try again after 5 minutes."
   - Fields and keypad should appear disabled

## Step 3: Screenshot Tips

### Recommended Settings:
- **Device**: Use iPhone 14 Pro or similar (1179x2556 pixels)
- **Format**: PNG (preferred) or JPG
- **Quality**: High resolution (at least 2x for retina displays)
- **Orientation**: Portrait (vertical)

### Taking Screenshots in Xcode Simulator:
1. Run your app in the iOS Simulator
2. Navigate to the screen you want to capture
3. Press `Cmd + S` to save a screenshot
4. Or use `Device` → `Screenshots` → `Save Screenshot`

### Taking Screenshots on Physical Device:
1. Press `Volume Up + Power Button` (or `Side Button` on newer iPhones)
2. Screenshot is saved to Photos
3. Export to your computer

## Step 4: Optimize Screenshots

### Using Image Optimization Tools:
- **TinyPNG**: https://tinypng.com/ (reduces file size)
- **ImageOptim**: https://imageoptim.com/ (Mac app)
- **Squoosh**: https://squoosh.app/ (web-based)

### Recommended File Sizes:
- Each screenshot should be under 500KB
- Aim for 200-300KB for best GitHub loading performance

## Step 5: Add Screenshots to Repository

1. Copy your screenshot files to the `Screenshots` folder:
   ```
   Screenshots/
   ├── pin-entry.png
   ├── pin-setup.png
   ├── pin-error.png
   └── pin-lockout.png
   ```

2. Commit and push to GitHub:
   ```bash
   git add Screenshots/
   git commit -m "Add screenshots to README"
   git push
   ```

## Step 6: Verify in README

The README.md already includes the screenshot placeholders. Once you add the images to the `Screenshots` folder, they will automatically display on GitHub.

## Alternative: Using GitHub Issues for Screenshots

If you want to test screenshots before committing:

1. Create a GitHub Issue
2. Drag and drop screenshots into the issue
3. GitHub will provide URLs like: `https://user-images.githubusercontent.com/...`
4. Use these URLs in your README instead of relative paths

Example:
```markdown
![PIN Entry View](https://user-images.githubusercontent.com/your-image-url.png)
```

## Example Screenshot Layout

For best visual presentation, consider:

1. **Single Column Layout** (current):
   - Each screenshot on its own line
   - Good for mobile-focused READMEs

2. **Two Column Layout** (alternative):
   ```markdown
   <table>
     <tr>
       <td><img src="Screenshots/pin-entry.png" width="300"></td>
       <td><img src="Screenshots/pin-setup.png" width="300"></td>
     </tr>
     <tr>
       <td><img src="Screenshots/pin-error.png" width="300"></td>
       <td><img src="Screenshots/pin-lockout.png" width="300"></td>
     </tr>
   </table>
   ```

## Troubleshooting

### Screenshots Not Showing?
- Check file paths are correct (case-sensitive on Linux/Mac)
- Ensure images are committed to the repository
- Verify file extensions match (.png, .jpg, etc.)
- Check file size isn't too large (GitHub has limits)

### Screenshots Too Large?
- Use image optimization tools (see Step 4)
- Resize images to reasonable dimensions (max 1200px width)
- Consider using JPG for photos, PNG for UI screenshots

### Want Different Screenshots?
- Update the image filenames in README.md
- Or modify the markdown image syntax:
  ```markdown
  ![Your Description](Screenshots/pin-entry.png)
  ```

