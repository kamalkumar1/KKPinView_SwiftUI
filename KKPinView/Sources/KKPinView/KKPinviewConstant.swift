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
    
    // MARK: - Font Sizes
    public static let titleFontSize: CGFloat = 30
    public static let subtitleFontSize: CGFloat = 15
    public static let normalFontSize: CGFloat = 24
    public static let smallFontSize: CGFloat = 8
    public static let deleteButtonFontSize: CGFloat = 24
    public static let numberButtonFontSize: CGFloat = 28
    public static let forgotPinFontSize: CGFloat = 14
    
    // MARK: - Dimensions
    public static let totalDigits: Int = 4
    public static let fieldHeight: CGFloat = 70
    public static let buttonSize: CGFloat = 70
    public static let fieldSpacing: CGFloat = 12
    public static let keypadSpacing: CGFloat = 16
    public static let keypadHorizontalPadding: CGFloat = 24
    public static let keypadVerticalPadding: CGFloat = 20
    
    // MARK: - Font Weights
    public static let titleFontWeight: Font.Weight = .bold
    public static let subtitleFontWeight: Font.Weight = .semibold
    public static let normalFontWeight: Font.Weight = .medium
    public static let deleteButtonFontWeight: Font.Weight = .medium
    public static let numberButtonFontWeight: Font.Weight = .semibold
    public static let forgotPinFontWeight: Font.Weight = .regular
    
    // MARK: - Strings
    public static let titleTextFormat: String = "Enter %d-Digit Code"
    public static let subtitleText: String = "Please enter your PIN to continue"
    public static let forgotPinText: String = "Forgot PIN?"
    public static let secureCharacter: String = "●"
    public static let deleteButtonValue: String = "X"
    public static let deleteButtonIconName: String = "delete.backward.fill"
    
    // MARK: - Behavior Flags
    public static let defaultShowForgotPin: Bool = true
}

