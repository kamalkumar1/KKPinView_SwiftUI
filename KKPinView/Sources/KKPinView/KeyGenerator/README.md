# KeyGenerator Module

The KeyGenerator module provides secure cryptographic key generation, encryption, and PIN storage functionality for the KKPinView package.

## Overview

This module consists of four main components:

1. **KKSecureKey** - Secure key wrapper with memory protection
2. **KKSecureKeyGenerator** - Device-specific key generation using PBKDF2
3. **KKEncryptionHelper** - AES-256-GCM encryption/decryption utilities
4. **KKPinStorage** - High-level API for encrypted PIN storage

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    KKPinStorage                          │
│  (High-level PIN storage API)                            │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│              KKEncryptionHelper                          │
│  (AES-256-GCM encryption/decryption)                     │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│            KKSecureKeyGenerator                          │
│  (PBKDF2 key derivation, device fingerprinting)         │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────┐
│                  KKSecureKey                             │
│  (Secure key wrapper with memory protection)             │
└─────────────────────────────────────────────────────────┘
```

## Components

### KKSecureKey

A secure key wrapper that provides:
- Base64 and byte array representations
- Secure memory zeroing
- Safe key handling

**Key Features:**
- Private key storage
- Secure `clear()` method using `memset_s`
- Support for byte array and base64 initialization

### KKSecureKeyGenerator

Generates device-specific cryptographic keys using:
- **Device Fingerprint**: UIDevice identifierForVendor (iOS)
- **App-Specific Salt**: Random entropy + app path + device ID
- **PBKDF2**: 100,000 iterations with HMAC-SHA256
- **Output**: 32-byte (256-bit) keys for AES-256

**Key Features:**
- Device-specific keys (unique per device)
- Persistent storage in UserDefaults
- Automatic key management
- Reset capability

### KKEncryptionHelper

Provides AES-256-GCM encryption/decryption:
- Authenticated encryption (confidentiality + integrity)
- Automatic nonce generation
- Secure key handling

**Encryption Format:**
```
[12 bytes: Nonce] + [N bytes: Ciphertext] + [16 bytes: Tag]
```

### KKPinStorage

High-level API for PIN management:
- Automatic encryption/decryption
- UserDefaults storage
- PIN verification
- Storage management

## Usage

### Basic PIN Storage

```swift
import KKPinView

// Save a PIN
KKPinStorage.savePIN("1234")

// Load a PIN
if let pin = KKPinStorage.loadPIN() {
    print("PIN: \(pin)")
}

// Verify a PIN
if KKPinStorage.verifyPIN("1234") {
    print("Correct!")
}

// Delete PIN
KKPinStorage.deletePIN()
```

### Advanced: Direct Encryption

```swift
// Get secure key
let secureKey = KKSecureKeyGenerator.getOrCreateSecureKey()

// Encrypt data
let data = "Sensitive data".data(using: .utf8)!
if let encrypted = KKEncryptionHelper.encryptData(data, secureKey: secureKey) {
    // Use encrypted data
}

// Decrypt data
if let decrypted = KKEncryptionHelper.decryptData(encrypted, secureKey: secureKey) {
    let text = String(data: decrypted, encoding: .utf8)
}
```

### Key Management

```swift
// Generate a new key (doesn't store)
let newKey = KKSecureKeyGenerator.generateSecureKey()

// Get or create stored key
let storedKey = KKSecureKeyGenerator.getOrCreateSecureKey()

// Reset key (invalidates all encrypted data)
KKSecureKeyGenerator.resetKey()
```

## Security Considerations

### Strengths
- ✅ AES-256-GCM encryption (industry standard)
- ✅ PBKDF2 with 100,000 iterations
- ✅ Device-specific keys
- ✅ Authenticated encryption (prevents tampering)
- ✅ Secure memory zeroing

### Limitations
- ⚠️ Keys stored in UserDefaults (not Keychain)
- ⚠️ Device-specific keys (cannot transfer between devices)
- ⚠️ Simple string comparison for PIN verification

### Recommendations for Production

1. **Use Keychain Services** instead of UserDefaults for key storage
2. **Implement constant-time comparison** for PIN verification
3. **Add key rotation** mechanisms
4. **Consider biometric authentication** integration
5. **Add rate limiting** for PIN attempts

## Storage Keys

The module uses the following UserDefaults keys:
- `"kkpinview_secure_key"` - Stored secure key
- `"kkpinview_encrypted_pin"` - Encrypted PIN data

## Requirements

- iOS 15.0+
- Swift 5.5+
- CryptoKit framework

## Error Handling

All methods return optional values or boolean results:
- `nil` indicates failure (with console logging)
- `false` indicates validation failure
- Check console logs for detailed error messages

## Thread Safety

- All methods are thread-safe
- UserDefaults operations are synchronized
- CryptoKit operations are thread-safe

## Testing

When testing, you can reset keys and PINs:

```swift
// Reset everything
KKSecureKeyGenerator.resetKey()
KKPinStorage.deletePIN()
```

## Migration Notes

If you need to migrate from UserDefaults to Keychain:
1. Read encrypted data from UserDefaults
2. Store in Keychain using `SecItemAdd`
3. Remove from UserDefaults
4. Update `KKPinStorage` to use Keychain APIs

## License

Part of the KKPinView package. See main package license.

