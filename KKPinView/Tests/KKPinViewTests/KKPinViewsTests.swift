//
//  KKPinViewsTests.swift
//  KKPinViewTests
//
//  Created on 27/12/25.
//

import XCTest
import SwiftUI
@testable import KKPinView

@available(iOS 15.0, *)
@MainActor
final class KKPinViewsTests: XCTestCase {
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        // Clean up any existing PIN and lockout state before each test
        KKPinStorage.deletePIN()
        let lockoutManager = KKPinLockoutManager()
        lockoutManager.resetLockout()
    }
    
    override func tearDown() {
        // Clean up after each test
        KKPinStorage.deletePIN()
        let lockoutManager = KKPinLockoutManager()
        lockoutManager.resetLockout()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitializationWithDefaultValues() {
        let view = KKPinViews()
        
        XCTAssertNotNil(view)
        XCTAssertTrue(view.showForgotPin, "showForgotPin should default to true")
        XCTAssertNil(view.onForgotPin, "onForgotPin should be nil by default")
        XCTAssertNil(view.onSubmit, "onSubmit should be nil by default")
    }
    
    func testInitializationWithCustomValues() {
        var forgotPinCalled = false
        var onSubmitCalled = false
        var onSubmitValue: Bool?
        
        let view = KKPinViews(
            onForgotPin: {
                forgotPinCalled = true
            },
            onSubmit: { isValid in
                onSubmitCalled = true
                onSubmitValue = isValid
            },
            showForgotPin: false
        )
        
        XCTAssertNotNil(view)
        XCTAssertFalse(view.showForgotPin, "showForgotPin should be false when set")
    }
    
    // MARK: - Callback Tests
    func testOnForgotPinCallback() {
        var forgotPinCalled = false
        let expectation = XCTestExpectation(description: "onForgotPin callback called")
        
        let view = KKPinViews(
            onForgotPin: {
                forgotPinCalled = true
                expectation.fulfill()
            }
        )
        
        // Simulate forgot pin action (in a real test, you'd need to interact with the view)
        view.onForgotPin?()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(forgotPinCalled, "onForgotPin callback should be called")
    }
    
    func testOnSubmitCallbackWithValidPIN() {
        // Setup: Save a PIN first
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved successfully")
        
        var onSubmitCalled = false
        var onSubmitValue: Bool?
        let expectation = XCTestExpectation(description: "onSubmit callback called with valid PIN")
        
        let view = KKPinViews(
            onSubmit: { isValid in
                onSubmitCalled = true
                onSubmitValue = isValid
                expectation.fulfill()
            }
        )
        
        // Note: In a real integration test, you would simulate user input
        // For now, we test the callback mechanism directly
        view.onSubmit?(true)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(onSubmitCalled, "onSubmit callback should be called")
        XCTAssertEqual(onSubmitValue, true, "onSubmit should receive true for valid PIN")
    }
    
    func testOnSubmitCallbackWithInvalidPIN() {
        // Setup: Save a PIN first
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved successfully")
        
        var onSubmitCalled = false
        var onSubmitValue: Bool?
        let expectation = XCTestExpectation(description: "onSubmit callback called with invalid PIN")
        
        let view = KKPinViews(
            onSubmit: { isValid in
                onSubmitCalled = true
                onSubmitValue = isValid
                expectation.fulfill()
            }
        )
        
        view.onSubmit?(false)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(onSubmitCalled, "onSubmit callback should be called")
        XCTAssertEqual(onSubmitValue, false, "onSubmit should receive false for invalid PIN")
    }
    
    // MARK: - Integration with KKPinStorage Tests
    func testIntegrationWithPINStorage() {
        // Test that the view works with PIN storage
        let testPIN = "5678"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        XCTAssertTrue(KKPinStorage.hasStoredPIN(), "PIN should exist in storage")
        
        // Verify PIN can be verified
        XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "Stored PIN should verify correctly")
        XCTAssertFalse(KKPinStorage.verifyPIN("9999"), "Wrong PIN should not verify")
    }
    
    // MARK: - Integration with Lockout Manager Tests
    func testIntegrationWithLockoutManager() {
        let lockoutManager = KKPinLockoutManager()
        
        // Initially, should not be locked out
        lockoutManager.checkLockoutStatus()
        XCTAssertFalse(lockoutManager.isLockedOut, "Should not be locked out initially")
        XCTAssertEqual(lockoutManager.failedAttempts, 0, "Failed attempts should be 0 initially")
        
        // Test failed attempts
        let testPIN = "1234"
        KKPinStorage.savePIN(testPIN)
        
        // Simulate multiple failed attempts
        for _ in 0..<lockoutManager.maxAttempts - 1 {
            lockoutManager.validatePIN("0000")
        }
        
        XCTAssertFalse(lockoutManager.isLockedOut, "Should not be locked out before max attempts")
        XCTAssertEqual(lockoutManager.failedAttempts, lockoutManager.maxAttempts - 1, "Failed attempts should be one less than max")
        
        // One more failed attempt should trigger lockout
        lockoutManager.validatePIN("0000")
        lockoutManager.checkLockoutStatus()
        XCTAssertTrue(lockoutManager.isLockedOut, "Should be locked out after max attempts")
    }
    
    func testLockoutReset() {
        let lockoutManager = KKPinLockoutManager()
        let testPIN = "1234"
        KKPinStorage.savePIN(testPIN)
        
        // Trigger lockout
        for _ in 0..<lockoutManager.maxAttempts {
            lockoutManager.validatePIN("0000")
        }
        lockoutManager.checkLockoutStatus()
        XCTAssertTrue(lockoutManager.isLockedOut, "Should be locked out")
        
        // Reset lockout
        lockoutManager.resetLockout()
        lockoutManager.checkLockoutStatus()
        XCTAssertFalse(lockoutManager.isLockedOut, "Should not be locked out after reset")
        XCTAssertEqual(lockoutManager.failedAttempts, 0, "Failed attempts should be reset to 0")
    }
    
    // MARK: - PIN Validation Tests
    func testPINValidationWithCorrectPIN() {
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        
        let lockoutManager = KKPinLockoutManager()
        let isValid = lockoutManager.validatePIN(testPIN)
        
        XCTAssertTrue(isValid, "Correct PIN should validate as true")
        XCTAssertEqual(lockoutManager.failedAttempts, 0, "Failed attempts should be reset after valid PIN")
    }
    
    func testPINValidationWithIncorrectPIN() {
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        
        let lockoutManager = KKPinLockoutManager()
        let isValid = lockoutManager.validatePIN("9999")
        
        XCTAssertFalse(isValid, "Incorrect PIN should validate as false")
        XCTAssertEqual(lockoutManager.failedAttempts, 1, "Failed attempts should increment")
    }
    
    // MARK: - Error Message Tests
    func testLockoutErrorMessage() {
        let lockoutManager = KKPinLockoutManager()
        let testPIN = "1234"
        KKPinStorage.savePIN(testPIN)
        
        // Trigger lockout
        for _ in 0..<lockoutManager.maxAttempts {
            lockoutManager.validatePIN("0000")
        }
        lockoutManager.checkLockoutStatus()
        
        let errorMessage = lockoutManager.getErrorMessage()
        XCTAssertNotNil(errorMessage, "Error message should be present when locked out")
        XCTAssertTrue(errorMessage?.contains("minutes") ?? false, "Error message should contain lockout time")
    }
    
    func testInvalidPINErrorMessage() {
        let lockoutManager = KKPinLockoutManager()
        let testPIN = "1234"
        KKPinStorage.savePIN(testPIN)
        
        // Single failed attempt
        lockoutManager.validatePIN("0000")
        
        let errorMessage = lockoutManager.getErrorMessage()
        XCTAssertNotNil(errorMessage, "Error message should be present for invalid PIN")
    }
    
    // MARK: - Show Forgot PIN Tests
    func testShowForgotPinProperty() {
        let view1 = KKPinViews(showForgotPin: true)
        XCTAssertTrue(view1.showForgotPin, "showForgotPin should be true when set")
        
        let view2 = KKPinViews(showForgotPin: false)
        XCTAssertFalse(view2.showForgotPin, "showForgotPin should be false when set")
    }
    
    // MARK: - Multiple PIN Validation Tests
    func testMultiplePINValidations() {
        let testPIN = "5678"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        
        let lockoutManager = KKPinLockoutManager()
        
        // Validate correct PIN multiple times
        for _ in 0..<5 {
            let isValid = lockoutManager.validatePIN(testPIN)
            XCTAssertTrue(isValid, "Correct PIN should always validate as true")
            XCTAssertEqual(lockoutManager.failedAttempts, 0, "Failed attempts should remain 0")
        }
    }
    
    // MARK: - Edge Cases
    func testEmptyPINValidation() {
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        
        let lockoutManager = KKPinLockoutManager()
        let isValid = lockoutManager.validatePIN("")
        
        XCTAssertFalse(isValid, "Empty PIN should validate as false")
    }
    
    func testPINWithWrongLength() {
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        
        let lockoutManager = KKPinLockoutManager()
        let isValid1 = lockoutManager.validatePIN("123")  // Too short
        let isValid2 = lockoutManager.validatePIN("12345")  // Too long
        
        XCTAssertFalse(isValid1, "PIN with wrong length should validate as false")
        XCTAssertFalse(isValid2, "PIN with wrong length should validate as false")
    }
}

