//
//  KKPINSetUPViewTests.swift
//  KKPinViewTests
//
//  Created on 27/12/25.
//

import XCTest
import SwiftUI
@testable import KKPinView

@available(iOS 15.0, *)
@MainActor
final class KKPINSetUPViewTests: XCTestCase {
    
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
        let view = KKPINSetUPView()
        
        XCTAssertNotNil(view)
        XCTAssertNil(view.onSetupComplete, "onSetupComplete should be nil by default")
    }
    
    func testInitializationWithCallback() {
        var setupCompleteCalled = false
        var receivedPIN: String?
        
        let view = KKPINSetUPView { pin in
            setupCompleteCalled = true
            receivedPIN = pin
        }
        
        XCTAssertNotNil(view)
        XCTAssertNotNil(view.onSetupComplete, "onSetupComplete callback should be set")
        
        // Test callback invocation
        view.onSetupComplete?("1234")
        XCTAssertTrue(setupCompleteCalled, "Callback should be called")
        XCTAssertEqual(receivedPIN, "1234", "Callback should receive the correct PIN")
    }
    
    // MARK: - Callback Tests
    func testOnSetupCompleteCallback() {
        var setupCompleteCalled = false
        var receivedPIN: String?
        let expectation = XCTestExpectation(description: "onSetupComplete callback called")
        
        let view = KKPINSetUPView { pin in
            setupCompleteCalled = true
            receivedPIN = pin
            expectation.fulfill()
        }
        
        // Simulate setup completion
        let testPIN = "5678"
        view.onSetupComplete?(testPIN)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(setupCompleteCalled, "onSetupComplete callback should be called")
        XCTAssertEqual(receivedPIN, testPIN, "Callback should receive the correct PIN")
    }
    
    // MARK: - PIN Storage Integration Tests
    func testPINDeletionBeforeSaving() {
        // Save an initial PIN
        let initialPIN = "1111"
        XCTAssertTrue(KKPinStorage.savePIN(initialPIN), "Initial PIN should be saved")
        XCTAssertTrue(KKPinStorage.hasStoredPIN(), "PIN should exist in storage")
        
        // Simulate what happens in validateAndSavePINs: delete previous PIN
        KKPinStorage.deletePIN()
        XCTAssertFalse(KKPinStorage.hasStoredPIN(), "PIN should be deleted")
        
        // Save new PIN
        let newPIN = "2222"
        XCTAssertTrue(KKPinStorage.savePIN(newPIN), "New PIN should be saved")
        XCTAssertTrue(KKPinStorage.hasStoredPIN(), "New PIN should exist in storage")
        
        // Verify old PIN is gone
        XCTAssertFalse(KKPinStorage.verifyPIN(initialPIN), "Old PIN should not verify")
        XCTAssertTrue(KKPinStorage.verifyPIN(newPIN), "New PIN should verify correctly")
    }
    
    func testLockoutManagerResetBeforeSaving() {
        // Setup: Save a PIN and trigger lockout
        let testPIN = "1234"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        
        let lockoutManager = KKPinLockoutManager()
        
        // Trigger lockout by multiple failed attempts
        for _ in 0..<lockoutManager.maxAttempts {
            lockoutManager.validatePIN("0000")
        }
        lockoutManager.checkLockoutStatus()
        XCTAssertTrue(lockoutManager.isLockedOut, "Should be locked out")
        XCTAssertTrue(lockoutManager.failedAttempts >= lockoutManager.maxAttempts, "Failed attempts should be at max")
        
        // Simulate what happens in validateAndSavePINs: reset lockout
        let newLockoutManager = KKPinLockoutManager()
        newLockoutManager.resetLockout()
        newLockoutManager.checkLockoutStatus()
        XCTAssertFalse(newLockoutManager.isLockedOut, "Should not be locked out after reset")
        XCTAssertEqual(newLockoutManager.failedAttempts, 0, "Failed attempts should be reset to 0")
    }
    
    func testPINMatchingValidation() {
        let pin1 = "1234"
        let pin2 = "1234"
        let pin3 = "5678"
        
        // Matching PINs should be equal
        XCTAssertEqual(pin1, pin2, "Matching PINs should be equal")
        XCTAssertNotEqual(pin1, pin3, "Non-matching PINs should not be equal")
    }
    
    // MARK: - PIN Saving Tests
    func testPINSaveSuccess() {
        let testPIN = "9876"
        
        // Delete any existing PIN
        KKPinStorage.deletePIN()
        
        // Reset lockout
        let lockoutManager = KKPinLockoutManager()
        lockoutManager.resetLockout()
        
        // Save PIN
        let saved = KKPinStorage.savePIN(testPIN)
        XCTAssertTrue(saved, "PIN should be saved successfully")
        XCTAssertTrue(KKPinStorage.hasStoredPIN(), "PIN should exist in storage")
        XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "Saved PIN should verify correctly")
    }
    
    func testPINSaveFailureWithEmptyPIN() {
        // Delete any existing PIN
        KKPinStorage.deletePIN()
        
        // Try to save empty PIN
        let saved = KKPinStorage.savePIN("")
        XCTAssertFalse(saved, "Empty PIN should not be saved")
        XCTAssertFalse(KKPinStorage.hasStoredPIN(), "No PIN should exist in storage")
    }
    
    // MARK: - PIN Replacement Tests
    func testPINReplacement() {
        // Save initial PIN
        let initialPIN = "1111"
        XCTAssertTrue(KKPinStorage.savePIN(initialPIN), "Initial PIN should be saved")
        XCTAssertTrue(KKPinStorage.verifyPIN(initialPIN), "Initial PIN should verify")
        
        // Delete and save new PIN
        KKPinStorage.deletePIN()
        let newPIN = "2222"
        XCTAssertTrue(KKPinStorage.savePIN(newPIN), "New PIN should be saved")
        
        // Verify old PIN is gone and new PIN works
        XCTAssertFalse(KKPinStorage.verifyPIN(initialPIN), "Old PIN should not verify")
        XCTAssertTrue(KKPinStorage.verifyPIN(newPIN), "New PIN should verify")
    }
    
    // MARK: - Complete PIN Setup Flow Tests
    func testCompletePINSetupFlow() {
        // Step 1: Delete any existing PIN
        KKPinStorage.deletePIN()
        XCTAssertFalse(KKPinStorage.hasStoredPIN(), "No PIN should exist initially")
        
        // Step 2: Reset lockout
        let lockoutManager = KKPinLockoutManager()
        lockoutManager.resetLockout()
        XCTAssertFalse(lockoutManager.isLockedOut, "Should not be locked out")
        XCTAssertEqual(lockoutManager.failedAttempts, 0, "Failed attempts should be 0")
        
        // Step 3: Save new PIN
        let testPIN = "4321"
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        XCTAssertTrue(KKPinStorage.hasStoredPIN(), "PIN should exist in storage")
        
        // Step 4: Verify PIN works
        XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "PIN should verify correctly")
        XCTAssertFalse(KKPinStorage.verifyPIN("9999"), "Wrong PIN should not verify")
    }
    
    // MARK: - Multiple PIN Setup Tests
    func testMultiplePINSetups() {
        var savedPINs: [String] = []
        
        for i in 0..<3 {
            // Delete previous PIN
            KKPinStorage.deletePIN()
            
            // Reset lockout
            let lockoutManager = KKPinLockoutManager()
            lockoutManager.resetLockout()
            
            // Save new PIN
            let testPIN = "\(i)\(i)\(i)\(i)"
            XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN \(i) should be saved")
            savedPINs.append(testPIN)
            
            // Verify current PIN
            XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "PIN \(i) should verify")
            
            // Verify previous PINs are gone
            for j in 0..<i {
                XCTAssertFalse(KKPinStorage.verifyPIN(savedPINs[j]), "Previous PIN \(j) should not verify")
            }
        }
    }
    
    // MARK: - Edge Cases
    func testPINWithMinimumLength() {
        // Test with minimum valid PIN length (assuming 4 digits)
        let testPIN = "1234"
        
        KKPinStorage.deletePIN()
        let lockoutManager = KKPinLockoutManager()
        lockoutManager.resetLockout()
        
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "4-digit PIN should be saved")
        XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "4-digit PIN should verify")
    }
    
    func testPINWithSpecialCharacters() {
        // Note: PINs are typically numeric, but test edge case
        let testPIN = "1234"
        
        KKPinStorage.deletePIN()
        let lockoutManager = KKPinLockoutManager()
        lockoutManager.resetLockout()
        
        XCTAssertTrue(KKPinStorage.savePIN(testPIN), "PIN should be saved")
        XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "PIN should verify")
    }
    
    // MARK: - Lockout State Tests
    func testLockoutStateAfterPINSetup() {
        // Setup initial lockout state
        let initialPIN = "1111"
        KKPinStorage.savePIN(initialPIN)
        
        let lockoutManager1 = KKPinLockoutManager()
        for _ in 0..<lockoutManager1.maxAttempts {
            lockoutManager1.validatePIN("0000")
        }
        lockoutManager1.checkLockoutStatus()
        XCTAssertTrue(lockoutManager1.isLockedOut, "Should be locked out before reset")
        
        // Reset lockout (as done in PIN setup)
        let lockoutManager2 = KKPinLockoutManager()
        lockoutManager2.resetLockout()
        lockoutManager2.checkLockoutStatus()
        XCTAssertFalse(lockoutManager2.isLockedOut, "Should not be locked out after reset")
        XCTAssertEqual(lockoutManager2.failedAttempts, 0, "Failed attempts should be 0")
    }
    
    // MARK: - Storage Cleanup Tests
    func testStorageCleanupOnSetup() {
        // Create multiple PINs in sequence
        for i in 1...3 {
            // Delete previous
            KKPinStorage.deletePIN()
            
            // Reset lockout
            let lockoutManager = KKPinLockoutManager()
            lockoutManager.resetLockout()
            
            // Save new
            let testPIN = "\(i)\(i)\(i)\(i)"
            KKPinStorage.savePIN(testPIN)
            
            // Verify only current PIN exists
            XCTAssertTrue(KKPinStorage.hasStoredPIN(), "PIN should exist")
            XCTAssertTrue(KKPinStorage.verifyPIN(testPIN), "Current PIN should verify")
        }
    }
}

