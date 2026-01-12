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
    public static let defaultTextFieldType: PinTextFieldType = .roundCorner
    
    // MARK: - Colors
    // Gradient Colors
  
    // Background and UI Colors
    public static let backgroundColor: Color = Color.white
    public static let fieldBackgroundColor: Color = Color.gray.opacity(0.1)
    public static let fieldStrokeColor: Color = Color.gray.opacity(0.3)
    public static let fieldStrokeWidth: CGFloat = 1.0
    public static let textColor: Color = .black
    public static let subtitleTextColor: Color = .gray
    public static let buttonTextColor: Color = .black
    public static let forgotPinTextColor: Color = .blue
    public static let errorTextColor: Color = .red
    public static let successTextColor: Color = .green
    
    // MARK: - Font Sizes
    public static let titleFontSize: CGFloat = 30
    public static let subtitleFontSize: CGFloat = 15
    public static let normalFontSize: CGFloat = 24
    public static let smallFontSize: CGFloat = 8
    public static let deleteButtonFontSize: CGFloat = 24
    public static let numberButtonFontSize: CGFloat = 28
    public static let forgotPinFontSize: CGFloat = 14
    public static let errorMessageFontSize: CGFloat = 14
    public static let successMessageFontSize: CGFloat = 16
    public static let headingFontSize: CGFloat = 24
    
    // MARK: - Dimensions
    public static let totalDigits: Int = 4
    public static let fieldHeight: CGFloat = 70
    public static let buttonSize: CGFloat = 70
    public static let fieldSpacing: CGFloat = 12
    public static let keypadSpacing: CGFloat = 16
    public static let keypadHorizontalPadding: CGFloat = 24
    public static let keypadVerticalPadding: CGFloat = 20
    
    // MARK: - PIN Validation Limits
    public static let maxPinAttempts: Int = 2
    public static let pinLockoutDurationMinutes: Int = 2
    
    // MARK: - Font Weights
    public static let titleFontWeight: Font.Weight = .bold
    public static let subtitleFontWeight: Font.Weight = .semibold
    public static let normalFontWeight: Font.Weight = .medium
    public static let deleteButtonFontWeight: Font.Weight = .medium
    public static let numberButtonFontWeight: Font.Weight = .semibold
    public static let forgotPinFontWeight: Font.Weight = .regular
    public static let errorMessageFontWeight: Font.Weight = .medium
    public static let successMessageFontWeight: Font.Weight = .semibold
    public static let headingFontWeight: Font.Weight = .bold
    
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

