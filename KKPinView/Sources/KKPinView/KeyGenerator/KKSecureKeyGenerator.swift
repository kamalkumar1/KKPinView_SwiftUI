//
//  KKSecureKeyGenerator.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import Foundation
import CryptoKit
#if canImport(UIKit)
import UIKit
#endif

/// A secure key generator that creates device-specific cryptographic keys.
///
/// `KKSecureKeyGenerator` generates secure keys using:
/// - **Device Fingerprint**: Unique device identifier (UIDevice identifierForVendor on iOS)
/// - **App-Specific Salt**: Combines random entropy, app path, and device ID
/// - **PBKDF2**: Password-Based Key Derivation Function 2 with 100,000 iterations
///
/// ## Key Features
/// - **Device-Specific**: Keys are unique to each device
/// - **Persistent**: Keys are stored in UserDefaults and persist across app launches
/// - **Secure**: Uses PBKDF2 with 100,000 iterations and SHA256
/// - **Automatic Management**: Automatically generates and stores keys
///
/// ## Usage Example
/// ```swift
/// // Get or create a secure key (automatically stored)
/// let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()
///
/// // Generate a new key (doesn't store it)
/// let newKey = KKSecureKeyGenerator.generateSecureKey()
///
/// // Reset the stored key
/// KKSecureKeyGenerator.resetKey()
/// ```
///
/// ## Security Architecture
///
/// ### Key Generation Process:
/// 1. **Device Fingerprint**: Uses `UIDevice.current.identifierForVendor` (iOS)
/// 2. **Salt Generation**:
///    - 32 bytes of cryptographically secure random entropy
///    - App path hash (from Application Support directory)
///    - Device ID hash
///    - Combined and hashed with SHA256
/// 3. **Key Derivation**: PBKDF2-HMAC-SHA256 with 100,000 iterations
/// 4. **Output**: 32-byte (256-bit) key suitable for AES-256
///
/// ### Storage:
/// - Keys are stored in `UserDefaults` under the key `"kkpinview_secure_key"`
/// - Keys persist across app launches
/// - Keys are device-specific and cannot be transferred between devices
///
/// ## Important Notes
/// - Keys are **device-specific** and will be different on each device
/// - Keys are **persistent** - once generated, they remain the same until reset
/// - For production apps, consider using Keychain Services instead of UserDefaults
/// - The key generation is deterministic for the same device and app
///
/// - Note: Available on iOS 15.0 and later (includes iPadOS)
@available(iOS 15.0, *)
public enum KKSecureKeyGenerator {
    private static let secureKeyPreferenceKey = "kkpinview_secure_key"
    
    /// Generates a secure key using device fingerprint and app-specific salt.
    ///
    /// This method creates a new key each time it's called. The key is derived using:
    /// - Device identifier (UIDevice identifierForVendor)
    /// - App-specific salt (entropy + app path + device ID)
    /// - PBKDF2 with 100,000 iterations
    ///
    /// - Returns: A `KKSecureKey` containing a 32-byte (256-bit) key
    /// - Note: This method does NOT store the key. Use `getOrCreateSecureKey()` for automatic storage.
    public static func generateSecureKey() -> KKSecureKey {
        let deviceFingerprint = getDeviceFingerprint()
        let password = deviceFingerprint.data(using: .utf8) ?? Data()
        let salt = getAppSalt()
        
        // Use PBKDF2 with 100,000 iterations, SHA256, 32-byte output
        let keyBytes = pbkdf2(
            password: password,
            salt: salt,
            iterations: 100_000,
            keyLength: 32
        )
        
        return KKSecureKey(keyBytes: keyBytes)
    }
    
    /// Gets or creates a secure key, storing it in UserDefaults.
    ///
    /// This is the recommended method for most use cases. It:
    /// 1. Checks if a key already exists in UserDefaults
    /// 2. Returns the existing key if found
    /// 3. Generates and stores a new key if not found
    ///
    /// - Returns: Base64 encoded string representation of the secure key
    /// - Note: The key is automatically stored in UserDefaults and will persist across app launches
    ///
    /// ## Example
    /// ```swift
    /// // First call - generates and stores a new key
    /// let key1 = KKSecureKeyGenerator.getOrCreateSecureKey()
    ///
    /// // Subsequent calls - returns the same stored key
    /// let key2 = KKSecureKeyGenerator.getOrCreateSecureKey()
    /// // key1 == key2
    /// ```
    public static func getOrCreateSecureKey() -> String {
        let userDefaults = UserDefaults.standard
        
        // Try to load existing key
        if let existingKey = userDefaults.string(forKey: secureKeyPreferenceKey) {
            debugPrint("🔑 Loaded key from UserDefaults")
            return existingKey
        }
        
        // Generate and save new key
        let newKey: KKSecureKey = generateSecureKey()
        let keyValue: String = newKey.value
        userDefaults.set(keyValue, forKey: secureKeyPreferenceKey)
        userDefaults.synchronize()
        
        debugPrint("🔑 Generated + saved new key")
        return keyValue
    }
    
    /// Resets the secure key by removing it from UserDefaults.
    ///
    /// After calling this method, the next call to `getOrCreateSecureKey()` will
    /// generate a new key. This is useful for:
    /// - Testing purposes
    /// - User logout scenarios
    /// - Security resets
    ///
    /// - Warning: This will invalidate any data encrypted with the previous key
    public static func resetKey() {
        UserDefaults.standard.removeObject(forKey: secureKeyPreferenceKey)
        UserDefaults.standard.synchronize()
        debugPrint("🗑️  Secure key reset")
    }
    
    // MARK: - Private Helpers
    
    /// Gets device fingerprint (UIDevice identifier on iOS/iPadOS).
    ///
    /// - Returns: Device identifier string, or fallback string if unavailable
    private static func getDeviceFingerprint() -> String {
        #if canImport(UIKit)
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            return identifier
        }
        #endif
        return "ios-fallback"
    }
    
    /// Generates app-specific salt using entropy, app path, and device ID.
    ///
    /// The salt is created by combining:
    /// - 32 bytes of cryptographically secure random entropy
    /// - Application Support directory path hash
    /// - Device fingerprint hash
    ///
    /// The combined data is then hashed with SHA256 to produce the final salt.
    ///
    /// - Returns: 32-byte salt data for PBKDF2
    private static func getAppSalt() -> Data {
        // Generate random entropy (32 bytes)
        var entropy = Data(count: 32)
        let result = entropy.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        if result != errSecSuccess {
            // Fallback to less secure random
            entropy = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        }
        
        // Get app path hash
        let appPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path ?? ""
        let appPathHash = appPath.hashValue
        
        // Get device ID hash
        let deviceId = getDeviceFingerprint()
        let deviceIdHash = deviceId.hashValue
        
        // Combine: entropy + appPathHash + deviceIdHash
        var combined = entropy
        combined.append(contentsOf: withUnsafeBytes(of: appPathHash) { Data($0) })
        combined.append(contentsOf: withUnsafeBytes(of: deviceIdHash) { Data($0) })
        
        // Hash the combined data using SHA256
        let hashed = SHA256.hash(data: combined)
        return Data(hashed)
    }
    
    /// PBKDF2 key derivation function using HMAC-SHA256.
    ///
    /// Implements PBKDF2 (Password-Based Key Derivation Function 2) as specified
    /// in RFC 2898. Uses HMAC-SHA256 as the pseudorandom function.
    ///
    /// - Parameters:
    ///   - password: The password (device fingerprint) to derive the key from
    ///   - salt: The salt value (app-specific salt)
    ///   - iterations: Number of iterations (100,000 for security)
    ///   - keyLength: Desired key length in bytes (32 for AES-256)
    /// - Returns: Derived key bytes
    ///
    /// ## Algorithm
    /// For each block i:
    /// 1. U1 = HMAC-SHA256(password, salt || i)
    /// 2. U2 = HMAC-SHA256(password, U1)
    /// 3. U3 = HMAC-SHA256(password, U2)
    /// 4. ... (repeat for `iterations` times)
    /// 5. T(i) = U1 XOR U2 XOR ... XOR U(iterations)
    ///
    /// The final key is the concatenation of all T(i) blocks, truncated to `keyLength`.
    ///
    /// - Note: Compatible with iOS 15+ using CryptoKit
    private static func pbkdf2(password: Data, salt: Data, iterations: Int, keyLength: Int) -> [UInt8] {
        let hmacKey = SymmetricKey(data: password)
        var result = Data()
        
        // Calculate number of blocks needed (SHA256 produces 32-byte hashes)
        let blockCount = (keyLength + 31) / 32
        
        for blockIndex in 1...blockCount {
            // T(i) = U1 ^ U2 ^ ... ^ U(iterations)
            // where U1 = HMAC(password, salt || i)
            // and U(n) = HMAC(password, U(n-1))
            
            var saltWithBlock = salt
            saltWithBlock.append(contentsOf: withUnsafeBytes(of: UInt32(blockIndex).bigEndian) { Data($0) })
            
            // U1
            var u = Data(HMAC<SHA256>.authenticationCode(for: saltWithBlock, using: hmacKey))
            var t = u
            
            // U2, U3, ..., U(iterations)
            for _ in 1..<iterations {
                u = Data(HMAC<SHA256>.authenticationCode(for: u, using: hmacKey))
                // XOR with previous result
                t = Data(zip(t, u).map { $0 ^ $1 })
            }
            
            result.append(t)
        }
        
        // Return exactly keyLength bytes
        return Array(result.prefix(keyLength))
    }
}

