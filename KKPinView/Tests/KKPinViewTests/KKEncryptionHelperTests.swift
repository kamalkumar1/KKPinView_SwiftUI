//
//  KKEncryptionHelperTests.swift
//  KKPinViewTests
//
//  Created on 27/12/25.
//

import XCTest
@testable import KKPinView
import CryptoKit

@available(iOS 15.0, *)
@MainActor
final class KKEncryptionHelperTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        // Generate a test key for each test
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    /// Generates a valid 32-byte base64-encoded key for testing
    private func generateTestKey() -> String {
        var keyBytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, 32, &keyBytes)
        if status == errSecSuccess {
            return Data(keyBytes).base64EncodedString()
        } else {
            // Fallback for testing
            let testKey = Array(repeating: UInt8(0x42), count: 32)
            return Data(testKey).base64EncodedString()
        }
    }
    
    /// Generates a 32-byte key that's different from the given key
    private func generateDifferentKey(from originalKey: String) -> String {
        // Decode original key, modify first byte, re-encode
        guard let originalData = Data(base64Encoded: originalKey) else {
            return generateTestKey()
        }
        var modifiedBytes = Array(originalData.prefix(32))
        modifiedBytes[0] = modifiedBytes[0] == 0xFF ? 0x00 : 0xFF
        return Data(modifiedBytes).base64EncodedString()
    }
    
    // MARK: - Encryption Tests
    
    func testEncryptData_Success() {
        let testKey = generateTestKey()
        let testData = "Hello, World!".data(using: .utf8)!
        
        let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: testKey)
        
        XCTAssertNotNil(encrypted, "Encryption should succeed")
        XCTAssertGreaterThan(encrypted?.count ?? 0, testData.count, "Encrypted data should be larger than plaintext (includes nonce and tag)")
        
        // Encrypted data should have: 12 bytes (nonce) + ciphertext + 16 bytes (tag)
        // Minimum: 12 + 0 + 16 = 28 bytes
        XCTAssertGreaterThanOrEqual(encrypted?.count ?? 0, 28, "Encrypted data should be at least 28 bytes")
    }
    
    func testEncryptData_EmptyData() {
        let testKey = generateTestKey()
        let emptyData = Data()
        
        let encrypted = KKEncryptionHelper.encryptData(emptyData, secureKey: testKey)
        
        XCTAssertNil(encrypted, "Encryption should reject empty data")
    }
    
    func testEncryptData_LargeData() {
        let testKey = generateTestKey()
        let largeData = Data(repeating: 0x42, count: 1024) // 1KB of data
        
        let encrypted = KKEncryptionHelper.encryptData(largeData, secureKey: testKey)
        
        XCTAssertNotNil(encrypted, "Encryption should handle large data")
        XCTAssertGreaterThan(encrypted?.count ?? 0, largeData.count, "Encrypted data should be larger than plaintext")
    }
    
    func testEncryptData_EmptyKey() {
        let testData = "Test data".data(using: .utf8)!
        let emptyKey = ""
        
        let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: emptyKey)
        
        XCTAssertNil(encrypted, "Encryption should fail with empty key")
    }
    
    func testEncryptData_InvalidBase64Key() {
        let testData = "Test data".data(using: .utf8)!
        let invalidKey = "This is not base64!!!"
        
        let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: invalidKey)
        
        XCTAssertNil(encrypted, "Encryption should fail with invalid base64 key")
    }
    
    func testEncryptData_ShortKey() {
        let testData = "Test data".data(using: .utf8)!
        // Create a key shorter than 32 bytes
        let shortKeyData = Data(repeating: 0x42, count: 16) // 16 bytes instead of 32
        let shortKey = shortKeyData.base64EncodedString()
        
        let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: shortKey)
        
        XCTAssertNil(encrypted, "Encryption should fail with key shorter than 32 bytes")
    }
    
    func testEncryptData_DifferentKeysProduceDifferentOutput() {
        let testData = "Same input data".data(using: .utf8)!
        let key1 = generateTestKey()
        let key2 = generateDifferentKey(from: key1)
        
        let encrypted1 = KKEncryptionHelper.encryptData(testData, secureKey: key1)
        let encrypted2 = KKEncryptionHelper.encryptData(testData, secureKey: key2)
        
        XCTAssertNotNil(encrypted1, "First encryption should succeed")
        XCTAssertNotNil(encrypted2, "Second encryption should succeed")
        XCTAssertNotEqual(encrypted1, encrypted2, "Different keys should produce different encrypted output")
    }
    
    func testEncryptData_SameKeyProducesDifferentOutput() {
        let testData = "Same input data".data(using: .utf8)!
        let testKey = generateTestKey()
        
        // Encrypt the same data twice with the same key
        // Due to random nonce, output should be different each time
        let encrypted1 = KKEncryptionHelper.encryptData(testData, secureKey: testKey)
        let encrypted2 = KKEncryptionHelper.encryptData(testData, secureKey: testKey)
        
        XCTAssertNotNil(encrypted1, "First encryption should succeed")
        XCTAssertNotNil(encrypted2, "Second encryption should succeed")
        XCTAssertNotEqual(encrypted1, encrypted2, "Same data encrypted twice should produce different output (due to random nonce)")
    }
    
    // MARK: - Decryption Tests
    
    func testDecryptData_Success() {
        let testKey = generateTestKey()
        let originalData = "Hello, World!".data(using: .utf8)!
        
        // Encrypt first
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        // Decrypt
        let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey)
        
        XCTAssertNotNil(decrypted, "Decryption should succeed")
        XCTAssertEqual(decrypted, originalData, "Decrypted data should match original data")
    }
    
    func testDecryptData_EmptyData() {
        let testKey = generateTestKey()
        // Empty data encryption is rejected, so we can't test decryption of empty data
        // This test verifies that encryption correctly rejects empty data
        let encrypted = KKEncryptionHelper.encryptData(Data(), secureKey: testKey)
        
        XCTAssertNil(encrypted, "Encryption should reject empty data")
        
        // Since encryption fails, we can't test decryption with empty data
        // This is expected behavior - empty data is not allowed
    }
    
    func testDecryptData_LargeData() {
        let testKey = generateTestKey()
        let originalData = Data(repeating: 0x42, count: 1024) // 1KB of data
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey)
        
        XCTAssertNotNil(decrypted, "Decryption should succeed")
        XCTAssertEqual(decrypted, originalData, "Decrypted data should match original data")
    }
    
    func testDecryptData_WrongKey() {
        let testKey1 = generateTestKey()
        let testKey2 = generateDifferentKey(from: testKey1)
        let originalData = "Secret data".data(using: .utf8)!
        
        // Encrypt with key1
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey1) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        // Try to decrypt with key2 (wrong key)
        let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey2)
        
        XCTAssertNil(decrypted, "Decryption should fail with wrong key")
    }
    
    func testDecryptData_EmptyKey() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: "")
        
        XCTAssertNil(decrypted, "Decryption should fail with empty key")
    }
    
    func testDecryptData_InvalidBase64Key() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: "Invalid base64!!!")
        
        XCTAssertNil(decrypted, "Decryption should fail with invalid base64 key")
    }
    
    func testDecryptData_TooShortEncryptedData() {
        let testKey = generateTestKey()
        // Create data shorter than 28 bytes (12 nonce + 0 ciphertext + 16 tag minimum)
        let tooShortData = Data(repeating: 0x42, count: 20)
        
        let decrypted = KKEncryptionHelper.decryptData(tooShortData, secureKey: testKey)
        
        XCTAssertNil(decrypted, "Decryption should fail with data shorter than 28 bytes")
    }
    
    func testDecryptData_CorruptedEncryptedData() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        // Corrupt the encrypted data by modifying a byte
        var corruptedData = encrypted
        corruptedData[corruptedData.count / 2] ^= 0xFF // Flip a bit in the middle
        
        let decrypted = KKEncryptionHelper.decryptData(corruptedData, secureKey: testKey)
        
        XCTAssertNil(decrypted, "Decryption should fail with corrupted encrypted data")
    }
    
    func testDecryptData_CorruptedTag() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        // Corrupt the tag (last 16 bytes)
        var corruptedData = encrypted
        corruptedData[corruptedData.count - 1] ^= 0xFF // Flip last byte (part of tag)
        
        let decrypted = KKEncryptionHelper.decryptData(corruptedData, secureKey: testKey)
        
        XCTAssertNil(decrypted, "Decryption should fail with corrupted tag")
    }
    
    func testDecryptData_CorruptedNonce() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        // Corrupt the nonce (first 12 bytes)
        var corruptedData = encrypted
        corruptedData[0] ^= 0xFF // Flip first byte (part of nonce)
        
        let decrypted = KKEncryptionHelper.decryptData(corruptedData, secureKey: testKey)
        
        XCTAssertNil(decrypted, "Decryption should fail with corrupted nonce")
    }
    
    func testDecryptData_ShortKey() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
            XCTFail("Encryption should succeed")
            return
        }
        
        // Create a key shorter than 32 bytes
        let shortKeyData = Data(repeating: 0x42, count: 16) // 16 bytes instead of 32
        let shortKey = shortKeyData.base64EncodedString()
        
        let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: shortKey)
        
        XCTAssertNil(decrypted, "Decryption should fail with key shorter than 32 bytes")
    }
    
    // MARK: - Round-Trip Tests
    
    func testEncryptDecrypt_RoundTrip() {
        let testKey = generateTestKey()
        // Note: Empty string "" is excluded because encryption rejects empty data
        let testCases = [
            "a",
            "Hello, World!",
            "1234567890",
            "Special chars: !@#$%^&*()",
            "Unicode: 🎉🚀✅",
            "Long string: " + String(repeating: "A", count: 100)
        ]
        
        for testString in testCases {
            guard let originalData = testString.data(using: .utf8) else {
                XCTFail("Failed to convert test string to data: \(testString)")
                continue
            }
            
            guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
                XCTFail("Encryption failed for: \(testString)")
                continue
            }
            
            guard let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey) else {
                XCTFail("Decryption failed for: \(testString)")
                continue
            }
            
            XCTAssertEqual(decrypted, originalData, "Round-trip should preserve original data for: \(testString)")
            
            // Also verify string representation
            if let decryptedString = String(data: decrypted, encoding: .utf8) {
                XCTAssertEqual(decryptedString, testString, "Decrypted string should match original for: \(testString)")
            }
        }
    }
    
    func testEncryptDecrypt_RoundTrip_BinaryData() {
        let testKey = generateTestKey()
        // Test with binary data (not valid UTF-8)
        let binaryData = Data([0x00, 0x01, 0x02, 0xFF, 0xFE, 0xFD])
        
        guard let encrypted = KKEncryptionHelper.encryptData(binaryData, secureKey: testKey) else {
            XCTFail("Encryption should succeed with binary data")
            return
        }
        
        guard let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey) else {
            XCTFail("Decryption should succeed with binary data")
            return
        }
        
        XCTAssertEqual(decrypted, binaryData, "Round-trip should preserve binary data")
    }
    
    func testEncryptDecrypt_MultipleEncryptions() {
        let testKey = generateTestKey()
        let originalData = "Test data".data(using: .utf8)!
        
        // Encrypt multiple times
        var encryptedResults: [Data] = []
        for _ in 0..<10 {
            guard let encrypted = KKEncryptionHelper.encryptData(originalData, secureKey: testKey) else {
                XCTFail("Encryption should succeed")
                return
            }
            encryptedResults.append(encrypted)
            
            // Verify each can be decrypted correctly
            guard let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey) else {
                XCTFail("Decryption should succeed")
                return
            }
            XCTAssertEqual(decrypted, originalData, "Each encryption should decrypt correctly")
        }
        
        // All encrypted results should be different (due to random nonce)
        for i in 0..<encryptedResults.count {
            for j in (i+1)..<encryptedResults.count {
                XCTAssertNotEqual(encryptedResults[i], encryptedResults[j], "Multiple encryptions should produce different output")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testIntegration_WithKKSecureKeyGenerator() {
        // Test integration with actual key generator
        let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()
        let testData = "Integration test data".data(using: .utf8)!
        
        guard let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: secureKey) else {
            XCTFail("Encryption should succeed with generated key")
            return
        }
        
        guard let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: secureKey) else {
            XCTFail("Decryption should succeed with generated key")
            return
        }
        
        XCTAssertEqual(decrypted, testData, "Integration test should preserve original data")
    }
    
    // MARK: - Edge Cases
    
    func testEncryptData_VariousDataSizes() {
        let testKey = generateTestKey()
        // Note: Size 0 is excluded because encryption rejects empty data
        let sizes = [1, 15, 16, 31, 32, 100, 256, 1024, 4096]
        
        for size in sizes {
            let testData = Data(repeating: 0x42, count: size)
            let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: testKey)
            
            XCTAssertNotNil(encrypted, "Encryption should succeed for size: \(size)")
            
            if let encrypted = encrypted {
                guard let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: testKey) else {
                    XCTFail("Decryption should succeed for size: \(size)")
                    continue
                }
                XCTAssertEqual(decrypted, testData, "Round-trip should work for size: \(size)")
            }
        }
    }
    
    func testEncryptData_MaxLengthKey() {
        // Test with a key longer than 32 bytes (should use first 32 bytes)
        let longerKeyData = Data(repeating: 0x42, count: 64) // 64 bytes
        let longerKey = longerKeyData.base64EncodedString()
        let testData = "Test data".data(using: .utf8)!
        
        // This should work (uses first 32 bytes)
        let encrypted = KKEncryptionHelper.encryptData(testData, secureKey: longerKey)
        XCTAssertNotNil(encrypted, "Encryption should work with longer key (uses first 32 bytes)")
    }
}

