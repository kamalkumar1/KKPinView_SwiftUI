//
//  KKPinviewConstant.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

// MARK: - KKPinview Constants
@available(iOS 15.0, *)
public struct KKPinviewConstant {
    // MARK: - Field Type
    nonisolated(unsafe) public static var defaultTextFieldType: PinTextFieldType = .roundCorner
    
    // MARK: - Colors
    // Gradient Colors
  
    // Background and UI Colors
    nonisolated(unsafe) public static var backgroundColor: Color = Color.white
    nonisolated(unsafe) public static var fieldBackgroundColor: Color = Color.gray.opacity(0.1)
    nonisolated(unsafe) public static var fieldStrokeColor: Color = Color.gray.opacity(0.3)
    nonisolated(unsafe) public static var fieldStrokeWidth: CGFloat = 1.0
    nonisolated(unsafe) public static var textColor: Color = .black
    nonisolated(unsafe) public static var subtitleTextColor: Color = .gray
    nonisolated(unsafe) public static var buttonTextColor: Color = .black
    nonisolated(unsafe) public static var forgotPinTextColor: Color = .blue
    nonisolated(unsafe) public static var errorTextColor: Color = .red
    nonisolated(unsafe) public static var successTextColor: Color = .green
    
    // MARK: - Font Sizes
    nonisolated(unsafe) public static var titleFontSize: CGFloat = 30
    nonisolated(unsafe) public static var subtitleFontSize: CGFloat = 15
    nonisolated(unsafe) public static var normalFontSize: CGFloat = 24
    nonisolated(unsafe) public static var smallFontSize: CGFloat = 8
    nonisolated(unsafe) public static var deleteButtonFontSize: CGFloat = 24
    nonisolated(unsafe) public static var numberButtonFontSize: CGFloat = 28
    nonisolated(unsafe) public static var forgotPinFontSize: CGFloat = 14
    nonisolated(unsafe) public static var errorMessageFontSize: CGFloat = 14
    nonisolated(unsafe) public static var successMessageFontSize: CGFloat = 16
    nonisolated(unsafe) public static var headingFontSize: CGFloat = 24
    
    // MARK: - Dimensions
    nonisolated(unsafe) public static var totalDigits: Int = 4
    nonisolated(unsafe) public static var fieldHeight: CGFloat = 70
    nonisolated(unsafe) public static var buttonSize: CGFloat = 70
    nonisolated(unsafe) public static var fieldSpacing: CGFloat = 12
    nonisolated(unsafe) public static var keypadSpacing: CGFloat = 16
    nonisolated(unsafe) public static var keypadHorizontalPadding: CGFloat = 24
    nonisolated(unsafe) public static var keypadVerticalPadding: CGFloat = 20
    
    // MARK: - PIN Validation Limits
    nonisolated(unsafe) public static var maxPinAttempts: Int = 5
    nonisolated(unsafe) public static var pinLockoutDurationMinutes: Int = 5
    
    // MARK: - Font Weights
    nonisolated(unsafe) public static var titleFontWeight: Font.Weight = .bold
    nonisolated(unsafe) public static var subtitleFontWeight: Font.Weight = .semibold
    nonisolated(unsafe) public static var normalFontWeight: Font.Weight = .medium
    nonisolated(unsafe) public static var deleteButtonFontWeight: Font.Weight = .medium
    nonisolated(unsafe) public static var numberButtonFontWeight: Font.Weight = .semibold
    nonisolated(unsafe) public static var forgotPinFontWeight: Font.Weight = .regular
    nonisolated(unsafe) public static var errorMessageFontWeight: Font.Weight = .medium
    nonisolated(unsafe) public static var successMessageFontWeight: Font.Weight = .semibold
    nonisolated(unsafe) public static var headingFontWeight: Font.Weight = .bold
    
    // MARK: - Strings
    public static let titleTextFormat: String = "Enter %d-Digit Code"
    public static let subtitleText: String = "Please enter your PIN to continue"
    public static let forgotPinText: String = "Forgot PIN?"
    public static let invalidPinErrorText: String = "Invalid PIN. Please try again."
    public static let maxAttemptsReachedErrorTextFormat: String = "Maximum attempts reached. Please try again after %d minutes."
    public static let lockoutErrorTextFormat: String = "Too many failed attempts. Please try again after %d minutes."
    public static let secureCharacter: String = "●"
    public static let deleteButtonValue: String = "X"
    public static let deleteButtonIconName: String = "delete.backward.fill"
    
    // PIN Setup View Strings
    public static let pinSetupHeadingFormat: String = "Set %d-Digit PIN"
    public static let enterPinLabelText: String = "Enter the PIN"
    public static let confirmPinLabelText: String = "Confirm the PIN"
    public static let pinMismatchErrorText: String = "PINs do not match. Please try again."
    public static let pinSetupSuccessText: String = "PIN has been set successfully!"
    
    // MARK: - Behavior Flags
    public static let defaultShowForgotPin: Bool = true
}

