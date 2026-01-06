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
/// - **UserDefaults Storage**: Stores encrypted PINs in UserDefaults
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
/// 4. Encrypted data is base64-encoded and stored in UserDefaults
///
/// ### Retrieval Flow:
/// 1. Encrypted base64 string is retrieved from UserDefaults
/// 2. Base64 string is decoded to encrypted data
/// 3. Secure key is obtained from `KKSecureKeyGenerator`
/// 4. Data is decrypted using `KKEncryptionHelper`
/// 5. Decrypted data is converted back to PIN string
///
/// ## Important Notes
/// - PINs are stored **encrypted** in UserDefaults
/// - The encryption key is **device-specific** and **persistent**
/// - PINs encrypted on one device **cannot** be decrypted on another device
/// - If the secure key is reset, all stored PINs become unrecoverable
/// - For production apps, consider using Keychain Services instead of UserDefaults
///
/// ## Storage Key
/// PINs are stored in UserDefaults under the key: `"kkpinview_encrypted_pin"`
///
/// - Note: Available on iOS 15.0 and later
@available(iOS 15.0, *)
public enum KKPinStorage {
    private static let pinPreferenceKey = "kkpinview_encrypted_pin"
    
    /// Saves PIN securely to UserDefaults using encryption.
    ///
    /// This method:
    /// 1. Validates that the PIN is not empty
    /// 2. Gets or creates a secure key
    /// 3. Encrypts the PIN using AES-256-GCM
    /// 4. Stores the encrypted PIN in UserDefaults as a base64 string
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
            print("❌ savePIN: PIN cannot be empty")
            return false
        }
        
        // Get or create secure key
        let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()
        
        // Convert PIN to data
        guard let pinData = pin.data(using: .utf8) else {
            print("❌ savePIN: Failed to convert PIN to data")
            return false
        }
        
        // Encrypt PIN
        guard let encryptedData = KKEncryptionHelper.encryptData(pinData, secureKey: secureKey) else {
            print("❌ savePIN: Encryption failed")
            return false
        }
        
        // Save encrypted data to UserDefaults as base64 string
        let encryptedString = encryptedData.base64EncodedString()
        UserDefaults.standard.set(encryptedString, forKey: pinPreferenceKey)
        UserDefaults.standard.synchronize()
        
        print("✅ PIN saved successfully")
        return true
    }
    
    /// Loads and decrypts PIN from UserDefaults.
    ///
    /// This method:
    /// 1. Retrieves the encrypted PIN from UserDefaults
    /// 2. Gets the secure key
    /// 3. Decodes the base64 string
    /// 4. Decrypts the PIN data
    /// 5. Converts back to string
    ///
    /// - Returns: Decrypted PIN string, or `nil` if:
    ///   - No PIN is stored
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
        // Check if PIN exists
        guard let encryptedString = UserDefaults.standard.string(forKey: pinPreferenceKey) else {
            print("ℹ️  No PIN found in UserDefaults")
            return nil
        }
        
        // Get secure key
        let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()
        
        // Decode base64
        guard let encryptedData = Data(base64Encoded: encryptedString) else {
            print("❌ loadPIN: Failed to decode base64")
            return nil
        }
        
        // Decrypt
        guard let decryptedData = KKEncryptionHelper.decryptData(encryptedData, secureKey: secureKey) else {
            print("❌ loadPIN: Decryption failed")
            return nil
        }
        
        // Convert back to string
        guard let pin = String(data: decryptedData, encoding: .utf8) else {
            print("❌ loadPIN: Failed to convert data to string")
            return nil
        }
        
        print("✅ PIN loaded successfully")
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
    
    /// Removes the stored PIN from UserDefaults.
    ///
    /// This method permanently deletes the encrypted PIN from storage.
    /// After calling this method, `hasStoredPIN()` will return `false`.
    ///
    /// ## Example
    /// ```swift
    /// // User logs out
    /// KKPinStorage.deletePIN()
    /// print("PIN cleared")
    /// ```
    ///
    /// - Note: This only removes the PIN, not the secure key.
    ///   To reset the secure key, use `KKSecureKeyGenerator.resetKey()`
    public static func deletePIN() {
        UserDefaults.standard.removeObject(forKey: pinPreferenceKey)
        UserDefaults.standard.synchronize()
        print("🗑️  PIN deleted from UserDefaults")
    }
    
    /// Checks if a PIN is stored in UserDefaults.
    ///
    /// This method only checks for the presence of stored data, not whether
    /// it can be successfully decrypted.
    ///
    /// - Returns: `true` if a PIN is stored, `false` otherwise
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
        return UserDefaults.standard.string(forKey: pinPreferenceKey) != nil
    }
}

