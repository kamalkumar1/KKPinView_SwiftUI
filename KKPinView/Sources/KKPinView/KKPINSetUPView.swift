//
//  KKPINSetUPView.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

/// A complete PIN setup screen with entry and confirmation fields.
///
/// `KKPINSetUPView` provides a dedicated screen for setting up a new PIN:
/// - Heading message indicating PIN length (4 or 6 digits)
/// - Enter PIN section with label and text fields
/// - Confirm PIN section with label and text fields
/// - Numeric keypad for input
/// - Validation and error handling
/// - Automatic PIN saving when both PINs match
///
/// ## Usage Example
/// ```swift
/// KKPINSetUPView(
///     onSetupComplete: { pin in
///         print("PIN setup completed: \(pin)")
///         // Navigate to main screen
///     }
/// )
/// ```
///
/// - Note: Available on iOS 15.0 and later
@available(iOS 15.0, *)
public struct KKPINSetUPView: View {
    /// Callback when PIN setup is completed successfully
    public var onSetupComplete: ((String) -> Void)? = nil
    
    public init(
        onSetupComplete: ((String) -> Void)? = nil
    ) {
        self.onSetupComplete = onSetupComplete
    }
    
    // MARK: - State Management
    @State private var pinDigits: [String] = Array(repeating: "", count: KKPinviewConstant.totalDigits)
    @State private var confirmPinDigits: [String] = Array(repeating: "", count: KKPinviewConstant.totalDigits)
    @State private var currentFieldIndex: Int = 0
    @State private var isEnteringConfirmPin: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var showSuccess: Bool = false
    
    public var body: some View {
        ZStack(alignment: .center) {
            // Background color
            KKPinviewConstant.backgroundColor
                .ignoresSafeArea()
            
            // ScrollView to fit small screens
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 24) {
                    // Heading message
                    Text(String(format: KKPinviewConstant.pinSetupHeadingFormat, KKPinviewConstant.totalDigits))
                        .font(.system(size: KKPinviewConstant.headingFontSize, weight: KKPinviewConstant.headingFontWeight))
                        .foregroundColor(KKPinviewConstant.textColor)
                        .padding(.top, 40)
                    
                    // Enter PIN section
                    VStack(alignment: .center, spacing: 16) {
                        // "Enter the PIN" label
                        Text(KKPinviewConstant.enterPinLabelText)
                            .font(.system(size: KKPinviewConstant.subtitleFontSize, weight: KKPinviewConstant.subtitleFontWeight))
                            .foregroundColor(KKPinviewConstant.subtitleTextColor)
                        
                        // Enter PIN fields
                        HStack(spacing: KKPinviewConstant.fieldSpacing) {
                            ForEach(0..<KKPinviewConstant.totalDigits, id: \.self) { index in
                                PinDigitField(
                                    text: $pinDigits[index],
                                    isFocused: currentFieldIndex == index && !isEnteringConfirmPin,
                                    fieldSize: PinDigitField.fieldHeight
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(isEnteringConfirmPin ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 24)
                    
                    // Confirm PIN section
                    VStack(alignment: .center, spacing: 16) {
                        // "Confirm the PIN" label
                        Text(KKPinviewConstant.confirmPinLabelText)
                            .font(.system(size: KKPinviewConstant.subtitleFontSize, weight: KKPinviewConstant.subtitleFontWeight))
                            .foregroundColor(KKPinviewConstant.subtitleTextColor)
                        
                        // Confirm PIN fields
                        HStack(spacing: KKPinviewConstant.fieldSpacing) {
                            ForEach(0..<KKPinviewConstant.totalDigits, id: \.self) { index in
                                PinDigitField(
                                    text: $confirmPinDigits[index],
                                    isFocused: currentFieldIndex == index && isEnteringConfirmPin,
                                    fieldSize: PinDigitField.fieldHeight
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: KKPinviewConstant.errorMessageFontSize, weight: KKPinviewConstant.errorMessageFontWeight))
                                .foregroundColor(KKPinviewConstant.errorTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Success message
                        if showSuccess, let successMessage = successMessage {
                            Text(successMessage)
                                .font(.system(size: KKPinviewConstant.successMessageFontSize, weight: KKPinviewConstant.successMessageFontWeight))
                                .foregroundColor(KKPinviewConstant.successTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Numeric Keypad
                    NumericKeypad(
                        onNumberTap: { number in
                            handleNumberTap(number)
                        },
                        onDeleteTap: {
                            handleDeleteTap()
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            // Set initial focus
            currentFieldIndex = 0
            isEnteringConfirmPin = false
        }
    }
    
    // MARK: - Helper Methods
    private func handleNumberTap(_ number: String) {
        if !isEnteringConfirmPin {
            // Entering first PIN
            if let emptyIndex = pinDigits.firstIndex(where: { $0.isEmpty }) {
                pinDigits[emptyIndex] = number
                if emptyIndex < KKPinviewConstant.totalDigits - 1 {
                    currentFieldIndex = emptyIndex + 1
                } else {
                    // First PIN complete, move to confirmation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isEnteringConfirmPin = true
                        currentFieldIndex = 0
                        errorMessage = nil
                    }
                }
            }
        } else {
            // Entering confirmation PIN
            if let emptyIndex = confirmPinDigits.firstIndex(where: { $0.isEmpty }) {
                confirmPinDigits[emptyIndex] = number
                if emptyIndex < KKPinviewConstant.totalDigits - 1 {
                    currentFieldIndex = emptyIndex + 1
                } else {
                    // Both PINs complete, validate
                    validateAndSavePINs()
                }
            }
        }
    }
    
    private func handleDeleteTap() {
        if isEnteringConfirmPin {
            // Deleting from confirmation PIN
            if let lastFilledIndex = confirmPinDigits.lastIndex(where: { !$0.isEmpty }) {
                confirmPinDigits[lastFilledIndex] = ""
                currentFieldIndex = lastFilledIndex
            } else if confirmPinDigits.allSatisfy({ $0.isEmpty }) {
                // All confirmation fields empty, go back to first PIN
                isEnteringConfirmPin = false
                currentFieldIndex = pinDigits.lastIndex(where: { !$0.isEmpty }) ?? 0
                errorMessage = nil
            }
        } else {
            // Deleting from first PIN
            if let lastFilledIndex = pinDigits.lastIndex(where: { !$0.isEmpty }) {
                pinDigits[lastFilledIndex] = ""
                currentFieldIndex = lastFilledIndex
            }
        }
    }
    
    private func validateAndSavePINs() {
        let enteredPin = pinDigits.joined()
        let confirmPin = confirmPinDigits.joined()
        
        if enteredPin == confirmPin {
            // PINs match - Save and show success
            let saved = KKPinStorage.savePIN(enteredPin)
            if saved {
                withAnimation(.easeInOut(duration: 0.3)) {
                    successMessage = KKPinviewConstant.pinSetupSuccessText
                    showSuccess = true
                    errorMessage = nil
                }
                
                // Call success callback after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if(!KKPinStorage.hasStoredPIN()){
                        KKPinStorage.savePIN(enteredPin)
                    }
                    onSetupComplete?(enteredPin)
                }
            } else {
                // Failed to save
                withAnimation(.easeInOut(duration: 0.3)) {
                    errorMessage = "Failed to save PIN. Please try again."
                }
                resetAllFields()
            }
        } else {
            // PINs don't match - Show error and reset
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = KKPinviewConstant.pinMismatchErrorText
                showSuccess = false
                successMessage = nil
            }
            
            // Reset after showing error
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                resetAllFields()
            }
        }
    }
    
    private func resetAllFields() {
        // Reset all fields
        for index in 0..<pinDigits.count {
            pinDigits[index] = ""
            confirmPinDigits[index] = ""
        }
        isEnteringConfirmPin = false
        currentFieldIndex = 0
        errorMessage = nil
        successMessage = nil
        showSuccess = false
    }
}

#Preview {
    KKPINSetUPView(
        onSetupComplete: { pin in
            print("PIN setup completed: \(pin)")
        }
    )
}

