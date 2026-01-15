//
//  KKPinLockoutManager.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import Foundation

/// Manages PIN validation attempts and lockout logic.
///
/// `KKPinLockoutManager` provides functionality for:
/// - Tracking failed PIN attempts
/// - Enforcing maximum attempt limits
/// - Managing lockout periods
/// - Persistent storage of attempt counts and lockout status
///
/// ## Usage Example
/// ```swift
/// let manager = KKPinLockoutManager()
///
/// // Check if locked out
/// if manager.isLockedOut {
///     print("Locked out for \(manager.remainingLockoutMinutes) minutes")
/// }
///
/// // Validate PIN
/// if manager.validatePIN("1234") {
///     print("PIN is valid")
///     manager.resetFailedAttempts()
/// } else {
///     print("Invalid PIN. Attempts: \(manager.failedAttempts)")
///     if manager.hasReachedMaxAttempts {
///         print("Max attempts reached. Locked out.")
///     }
/// }
/// ```
///
/// - Note: Available on iOS 15.0 and later
@available(iOS 15.0, *)
public class KKPinLockoutManager {
    // MARK: - UserDefaults Keys
    private let failedAttemptsKey = "kkpinview_failed_attempts"
    private let lockoutEndTimeKey = "kkpinview_lockout_end_time"
    
    // MARK: - Properties
    /// Current number of failed attempts
    public var failedAttempts: Int {
        return UserDefaults.standard.integer(forKey: failedAttemptsKey)
    }
    
    /// Maximum allowed PIN attempts before lockout
    public let maxAttempts: Int
    
    /// Lockout duration in minutes
    public let lockoutDurationMinutes: Int
    
    /// Whether the user is currently locked out
    /// Note: Call `checkLockoutStatus()` before accessing this property to ensure accurate state
    public var isLockedOut: Bool {
        return _isLockedOut
    }
    
    /// Remaining lockout time in minutes (0 if not locked out)
    public var remainingLockoutMinutes: Int {
        guard let lockoutEndTime = lockoutEndTime else {
            return 0
        }
        let now = Date()
        if now < lockoutEndTime {
            let remainingSeconds = lockoutEndTime.timeIntervalSince(now)
            return max(1, Int(ceil(remainingSeconds / 60.0)))
        }
        return 0
    }
    
    /// Whether maximum attempts have been reached
    public var hasReachedMaxAttempts: Bool {
        return failedAttempts >= maxAttempts
    }
    
    /// Current lockout end time (nil if not locked out)
    public var lockoutEndTime: Date? {
        return UserDefaults.standard.object(forKey: lockoutEndTimeKey) as? Date
    }
    
    // Internal state
    private var _isLockedOut: Bool = false
    
    // MARK: - Initialization
    public init(
        maxAttempts: Int = KKPinviewConstant.maxPinAttempts,
        lockoutDurationMinutes: Int = KKPinviewConstant.pinLockoutDurationMinutes
    ) {
        self.maxAttempts = maxAttempts
        self.lockoutDurationMinutes = lockoutDurationMinutes
        checkLockoutStatus()
    }
    
    // MARK: - PIN Validation
    /// Validates a PIN using KKPinStorage and handles attempt tracking.
    ///
    /// This method:
    /// 1. Checks if currently locked out
    /// 2. Validates PIN using `KKPinStorage.verifyPIN()`
    /// 3. Increments failed attempts if invalid
    /// 4. Sets lockout if max attempts reached
    /// 5. Resets attempts if valid
    ///
    /// - Parameter pin: The PIN string to validate
    /// - Returns: `true` if PIN is valid, `false` if invalid or locked out
    ///
    /// ## Example
    /// ```swift
    /// let manager = KKPinLockoutManager()
    /// if manager.validatePIN("1234") {
    ///     print("PIN is valid")
    /// } else {
    ///     print("Invalid PIN or locked out")
    /// }
    /// ```
    @discardableResult
    public func validatePIN(_ pin: String) -> Bool {
        // Check lockout status first
        if isLockedOut {
            return false
        }
        
        // Verify PIN using KKPinStorage
        let isValid = KKPinStorage.verifyPIN(pin)
        
        if isValid {
            // PIN is valid - reset failed attempts
            resetFailedAttempts()
            return true
        } else {
            // PIN is invalid - increment failed attempts
            incrementFailedAttempts()
            
            // Check if max attempts reached
            if hasReachedMaxAttempts {
                setLockout()
            }
            
            return false
        }
    }
    
    // MARK: - Attempt Management
    /// Increments the failed attempts counter.
    public func incrementFailedAttempts() {
        let currentAttempts = failedAttempts
        UserDefaults.standard.set(currentAttempts + 1, forKey: failedAttemptsKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Resets the failed attempts counter to 0 and clears lockout.
    public func resetFailedAttempts() {
        UserDefaults.standard.set(0, forKey: failedAttemptsKey)
        UserDefaults.standard.synchronize()
        resetLockout()
    }
    
    // MARK: - Lockout Management
    /// Checks the current lockout status and updates internal state.
    ///
    /// This method checks if there's an active lockout period and whether it has expired.
    /// Should be called periodically to check lockout status.
    public func checkLockoutStatus() {
        if let lockoutEndTimeStamp = lockoutEndTime {
            let now = Date()
            
            if now < lockoutEndTimeStamp {
                // Still in lockout period
                _isLockedOut = true
            } else {
                // Lockout period expired - reset
                resetLockout()
            }
        } else {
            // No lockout
            _isLockedOut = false
        }
    }
    
    /// Sets a lockout period starting from now.
    ///
    /// This is automatically called when maximum attempts are reached.
    public func setLockout() {
        let lockoutEnd = Date().addingTimeInterval(TimeInterval(lockoutDurationMinutes * 60))
        UserDefaults.standard.set(lockoutEnd, forKey: lockoutEndTimeKey)
        UserDefaults.standard.synchronize()
        _isLockedOut = true
    }
    
    /// Clears the lockout and resets failed attempts.
    public func resetLockout() {
        UserDefaults.standard.removeObject(forKey: lockoutEndTimeKey)
        UserDefaults.standard.removeObject(forKey: failedAttemptsKey)
        UserDefaults.standard.synchronize()
        _isLockedOut = false
    }
    
    /// Clears only the lockout without resetting failed attempts.
    public func clearLockoutOnly() {
        UserDefaults.standard.removeObject(forKey: lockoutEndTimeKey)
        UserDefaults.standard.synchronize()
        _isLockedOut = false
    }
    
    // MARK: - Error Messages
    /// Returns the appropriate error message based on current state.
    ///
    /// - Returns: Error message string, or `nil` if no error state
    ///
    /// ## Example
    /// ```swift
    /// if let errorMessage = manager.getErrorMessage() {
    ///     print(errorMessage)
    /// }
    /// ```
    public func getErrorMessage() -> String? {
        checkLockoutStatus()
        
        if isLockedOut {
            let remaining = remainingLockoutMinutes
            if remaining > 0 {
                return String(format: KKPinviewConstant.lockoutErrorTextFormat, remaining)
            }
            return String(format: KKPinviewConstant.maxAttemptsReachedErrorTextFormat, lockoutDurationMinutes)
        }
        
        if failedAttempts > 0 && failedAttempts < maxAttempts {
            return KKPinviewConstant.invalidPinErrorText
        }
        
        return nil
    }
    public func getLocKOutErrorMessagePinError() -> String? {
        checkLockoutStatus()
        
        if isLockedOut {
            let remaining = remainingLockoutMinutes
            if remaining > 0 {
                return String(format: KKPinviewConstant.lockoutErrorTextFormat, remaining)
            }
            return String(format: KKPinviewConstant.maxAttemptsReachedErrorTextFormat, lockoutDurationMinutes)
        }
        return nil
    }
        
}

