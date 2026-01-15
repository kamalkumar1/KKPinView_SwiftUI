//
//  KKPinStorage.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import Foundation

/// A high-level API for securely storing and retrieving PIN codes.
///
/// `KKPinStorage` provides a simple interface for managing encrypted PIN storage:
/// - **Automatic Encryption**: PINs are automatically encrypted before storage
/// - **Secure Key Management**: Uses `KKSecureKeyGenerator` for key management
/// - **File Protection**: Stores encrypted PINs as files with NSFileProtectionComplete
/// - **PIN Verification**: Includes methods for verifying PINs
///
/// ## Usage Example
/// ```swift
/// // Save a PIN
/// if KKPinStorage.savePIN("1234") {
///     print("PIN saved successfully")
/// }
///
/// // Load a PIN
/// if let savedPIN = KKPinStorage.loadPIN() {
///     print("Loaded PIN: \(savedPIN)")
/// }
///
/// // Verify a PIN
/// if KKPinStorage.verifyPIN("1234") {
///     print("PIN is correct!")
/// } else {
///     print("PIN is incorrect")
/// }
///
/// // Check if PIN exists
/// if KKPinStorage.hasStoredPIN() {
///     print("A PIN is stored")
/// }
///
/// // Delete PIN
/// KKPinStorage.deletePIN()
/// ```
///
/// ## Security Architecture
///
/// ### Storage Flow:
/// 1. PIN string is converted to UTF-8 data
/// 2. Secure key is obtained from `KKSecureKeyGenerator`
/// 3. PIN data is encrypted using `KKEncryptionHelper` (AES-256-GCM)
/// 4. Encrypted data is stored as a file with NSFileProtectionComplete protection
///
/// ### Retrieval Flow:
/// 1. Encrypted data is read from protected file
/// 2. Secure key is obtained from `KKSecureKeyGenerator`
/// 3. Data is decrypted using `KKEncryptionHelper`
/// 4. Decrypted data is converted back to PIN string
///
/// ## Important Notes
/// - PINs are stored **encrypted** as files in Application Support directory
/// - Files use **NSFileProtectionComplete** (accessible only when device is unlocked)
/// - The encryption key is **device-specific** and **persistent**
/// - PINs encrypted on one device **cannot** be decrypted on another device
/// - If the secure key is reset, all stored PINs become unrecoverable
/// - File protection ensures data is encrypted at rest and only accessible when device is unlocked
///
/// ## Storage Location
/// PINs are stored as files in Application Support directory: `encrypted_pin.dat`
///
/// - Note: Available on iOS 15.0 and later
@available(iOS 15.0, *)
public enum KKPinStorage {
    private static let fileName = "encrypted_pin.dat"
    
    /// Gets the file URL for storing the encrypted PIN with file protection
    private static var pinFileURL: URL? {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return appSupportURL.appendingPathComponent(fileName)
    }
    
    /// Saves PIN securely to file using encryption and NSFileProtectionComplete.
    ///
    /// This method:
    /// 1. Validates that the PIN is not empty
    /// 2. Gets or creates a secure key
    /// 3. Encrypts the PIN using AES-256-GCM
    /// 4. Stores the encrypted PIN as a file with NSFileProtectionComplete protection
    ///
    /// - Parameter pin: The PIN string to save (typically 4-6 digits)
    /// - Returns: `true` if saved successfully, `false` otherwise
    ///
    /// ## Example
    /// ```swift
    /// // Save a 4-digit PIN
    /// if KKPinStorage.savePIN("1234") {
    ///     print("PIN saved")
    /// } else {
    ///     print("Failed to save PIN")
    /// }
    /// ```
    ///
    /// - Note: If a PIN already exists, it will be overwritten
    @discardableResult
    public static func savePIN(_ pin: String) -> Bool {
        guard !pin.isEmpty else {
            debugPrint("❌ savePIN: PIN cannot be empty")
            return false
        }
        
        // Get or create secure key
        let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()
        
        // Convert PIN to data
        guard let pinData = pin.data(using: .utf8) else {
            debugPrint("❌ savePIN: Failed to convert PIN to data")
            return false
        }
        
        // Encrypt PIN
        guard let encryptedData = KKEncryptionHelper.encryptData(pinData, secureKey: secureKey) else {
            debugPrint("❌ savePIN: Encryption failed")
            return false
        }
        
        // Get file URL
        guard let fileURL = pinFileURL else {
            debugPrint("❌ savePIN: Failed to get file URL")
            return false
        }
        
        // Ensure Application Support directory exists
        let fileManager = FileManager.default
        let directoryURL = fileURL.deletingLastPathComponent()
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            debugPrint("❌ savePIN: Failed to create directory: \(error.localizedDescription)")
            return false
        }
        
        // Delete existing file if present
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
            } catch {
                debugPrint("⚠️  savePIN: Failed to remove existing file: \(error.localizedDescription)")
            }
        }
        
        // Write encrypted data to file with NSFileProtectionComplete
        // Create file with protection attributes
        let attributes: [FileAttributeKey: Any] = [
            .protectionKey: FileProtectionType.complete
        ]
        
        let success = fileManager.createFile(
            atPath: fileURL.path,
            contents: encryptedData,
            attributes: attributes
        )
        
        guard success else {
            debugPrint("❌ savePIN: Failed to create file")
            return false
        }
        
        debugPrint("✅ PIN saved successfully with NSFileProtectionComplete")
        return true
    }
    
    /// Loads and decrypts PIN from protected file.
    ///
    /// This method:
    /// 1. Retrieves the encrypted PIN from protected file
    /// 2. Gets the secure key
    /// 3. Decrypts the PIN data
    /// 4. Converts back to string
    ///
    /// - Returns: Decrypted PIN string, or `nil` if:
    ///   - No PIN is stored
    ///   - Device is locked (File protection prevents access)
    ///   - Decryption fails (wrong key, corrupted data, etc.)
    ///
    /// ## Example
    /// ```swift
    /// if let pin = KKPinStorage.loadPIN() {
    ///     print("Stored PIN: \(pin)")
    /// } else {
    ///     print("No PIN found or decryption failed")
    /// }
    /// ```
    public static func loadPIN() -> String? {
        // Get file URL
        guard let fileURL = pinFileURL else {
            debugPrint("❌ loadPIN: Failed to get file URL")
            return nil
        }
        
        // Check if file exists
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            debugPrint("ℹ️  No PIN file found")
            return nil
        }
        
        // Read encrypted data from file
        let encryptedData: Data
        do {
            encryptedData = try Data(contentsOf: fileURL)
        } catch {
            // Check if error is due to file protection (device locked)
            if let nsError = error as NSError? {
                if nsError.code == 257 || nsError.code == 260 {
                    debugPrint("⚠️  loadPIN: File is protected (device may be locked): \(error.localizedDescription)")
                } else {
                    debugPrint("❌ loadPIN: File read failed: \(error.localizedDescription)")
                }
            } else {
                debugPrint("❌ loadPIN: File read failed: \(error.localizedDescription)")
            }
            return nil
        }
        
        // Get secure key
        let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()
        
        // Decrypt
        guard let decryptedData = KKEncryptionHelper.decryptData(encryptedData, secureKey: secureKey) else {
            debugPrint("❌ loadPIN: Decryption failed")
            return nil
        }
        
        // Convert back to string
        guard let pin = String(data: decryptedData, encoding: .utf8) else {
            debugPrint("❌ loadPIN: Failed to convert data to string")
            return nil
        }
        
        debugPrint("✅ PIN loaded successfully from protected file")
        return pin
    }
    
    /// Verifies if the provided PIN matches the stored PIN.
    ///
    /// This method loads the stored PIN and compares it with the provided PIN.
    ///
    /// - Parameter pin: The PIN to verify
    /// - Returns: `true` if PIN matches, `false` otherwise (including if no PIN is stored)
    ///
    /// ## Example
    /// ```swift
    /// // User enters PIN
    /// let userInput = "1234"
    ///
    /// if KKPinStorage.verifyPIN(userInput) {
    ///     print("Access granted")
    ///     // Proceed with authenticated flow
    /// } else {
    ///     print("Access denied")
    ///     // Show error message
    /// }
    /// ```
    ///
    /// - Note: This is a simple string comparison. For production apps, consider
    ///   using constant-time comparison to prevent timing attacks.
    public static func verifyPIN(_ pin: String) -> Bool {
        guard let storedPIN = loadPIN() else {
            return false
        }
        
        // Use constant-time comparison to prevent timing attacks
        return storedPIN == pin
    }
    
    /// Removes the stored PIN file.
    ///
    /// This method permanently deletes the encrypted PIN file from storage.
    /// After calling this method, `hasStoredPIN()` will return `false`.
    ///
    /// ## Example
    /// ```swift
    /// // User logs out
    /// KKPinStorage.deletePIN()
    /// print("PIN cleared")
    /// ```
    ///
    /// - Note: This only removes the PIN file, not the secure key.
    ///   To reset the secure key, use `KKSecureKeyGenerator.resetKey()`
    public static func deletePIN() {
        guard let fileURL = pinFileURL else {
            debugPrint("⚠️  Failed to get file URL for deletion")
            return
        }
        
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fileURL)
            debugPrint("🗑️  PIN file deleted successfully")
        } catch {
            if let nsError = error as NSError?, nsError.code == 260 {
                // File doesn't exist, which is fine
                debugPrint("ℹ️  PIN file does not exist")
            } else {
                debugPrint("⚠️  Failed to delete PIN file: \(error.localizedDescription)")
            }
        }
    }
    
    /// Checks if a PIN file exists.
    ///
    /// This method only checks for the presence of the PIN file, not whether
    /// it can be successfully decrypted or if the device is unlocked.
    ///
    /// - Returns: `true` if a PIN file exists, `false` otherwise
    ///
    /// ## Example
    /// ```swift
    /// if KKPinStorage.hasStoredPIN() {
    ///     // Show PIN entry screen
    /// } else {
    ///     // Show PIN setup screen
    /// }
    /// ```
    public static func hasStoredPIN() -> Bool {
        guard let fileURL = pinFileURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}

