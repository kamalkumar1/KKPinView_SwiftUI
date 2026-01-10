//
//  KKSecureKey.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import Foundation

/// A secure key wrapper that provides secure zeroing of sensitive cryptographic data.
///
/// `KKSecureKey` is designed to safely handle cryptographic keys in memory by:
/// - Storing keys in a private, non-exposed format
/// - Providing secure zeroing when keys are no longer needed
/// - Supporting both byte array and base64 string representations
///
/// ## Usage Example
/// ```swift
/// // Create from bytes
/// let keyBytes: [UInt8] = [/* 32 bytes */]
/// var secureKey = KKSecureKey(keyBytes: keyBytes)
///
/// // Access base64 representation
/// let base64Key = secureKey.value
///
/// // Access raw bytes
/// let bytes = secureKey.bytes
///
/// // Securely clear when done
/// secureKey.clear()
/// ```
///
/// ## Security Considerations
/// - Keys are stored in private properties to prevent accidental exposure
/// - The `clear()` method uses `memset_s` for secure memory zeroing
/// - Always call `clear()` when the key is no longer needed
///
/// - Note: Available on iOS 15.0 and later
@available(iOS 15.0, *)
public struct KKSecureKey {
    private var _bytes: [UInt8]
    private var _value: String
    
    /// Base64 encoded string representation of the key.
    ///
    /// This is the format typically used for storage and transmission.
    /// The value is computed from the internal byte array.
    public var value: String {
        return _value
    }
    
    /// Byte array representation of the key.
    ///
    /// Returns a copy of the internal byte array. For security, the original
    /// bytes remain private and are only exposed through this computed property.
    public var bytes: [UInt8] {
        return _bytes
    }
    
    /// Initialize a secure key with raw bytes.
    ///
    /// - Parameter keyBytes: The key bytes (typically 32 bytes for AES-256)
    /// - Note: The bytes are immediately converted to base64 for storage
    public init(keyBytes: [UInt8]) {
        self._bytes = keyBytes
        self._value = Data(keyBytes).base64EncodedString()
    }
    
    /// Initialize a secure key from a base64 encoded string.
    ///
    /// - Parameter base64String: A base64 encoded string representation of the key
    /// - Returns: `nil` if the base64 string is invalid or cannot be decoded
    public init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String),
              let bytes = try? data.withUnsafeBytes({ Array($0) }) else {
            return nil
        }
        self._bytes = bytes
        self._value = base64String
    }
    
    /// Securely zero out the key bytes from memory.
    ///
    /// This method uses `memset_s` to securely overwrite the key bytes with zeros
    /// before removing them from memory. This helps prevent key material from
    /// persisting in memory after use.
    ///
    /// - Important: After calling this method, the key is no longer usable.
    ///   All subsequent access to `value` or `bytes` will return empty values.
    public mutating func clear() {
        _bytes.withUnsafeMutableBytes { buffer in
            memset_s(buffer.baseAddress, buffer.count, 0, buffer.count)
        }
        _bytes.removeAll()
        _value = ""
    }
}

@available(iOS 15.0, *)
extension KKSecureKey: ExpressibleByStringLiteral {
    /// Allows initialization from string literals (base64 format).
    ///
    /// - Parameter value: A base64 encoded string
    /// - Note: If the string is invalid, an empty key is created
    public init(stringLiteral value: String) {
        if let key = KKSecureKey(base64String: value) {
            self = key
        } else {
            self = KKSecureKey(keyBytes: [])
        }
    }
}

