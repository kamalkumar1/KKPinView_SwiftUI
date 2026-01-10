//
//  KKPinViews.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

@available(iOS 15.0, *)
public struct KKPinViews: View {
    public var onForgotPin: (() -> Void)? = nil
    public var onSubmit: ((Bool) -> Void)? = nil
    public var showForgotPin: Bool = true
    
    public init(
        onForgotPin: (() -> Void)? = nil,
        onSubmit: ((Bool) -> Void)? = nil,
        showForgotPin: Bool = KKPinviewConstant.defaultShowForgotPin
    ) {
        self.onForgotPin = onForgotPin
        self.onSubmit = onSubmit
        self.showForgotPin = showForgotPin
    }
    
    @State private var pinDigits: [String] = Array(repeating: "", count: KKPinviewConstant.totalDigits)
    @State private var currentFieldIndex: Int = 0
    @State private var errorMessage: String? = nil
    
    private var currentEmptyFieldIndex: Int {
        pinDigits.firstIndex(where: { $0.isEmpty }) ?? 0
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            // Background color
            KKPinviewConstant.backgroundColor
                .ignoresSafeArea()
            
            // Content - Centered on screen
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Card container for PIN fields - Centered
                VStack(alignment: .center, spacing: 40) {
                    // Title section
                    VStack(alignment: .center, spacing: 10) {
                        Text(String(format: KKPinviewConstant.titleTextFormat, KKPinviewConstant.totalDigits))
                            .font(.system(size: KKPinviewConstant.titleFontSize, weight: KKPinviewConstant.titleFontWeight))
                            .foregroundColor(KKPinviewConstant.textColor)
                        
                        Text(KKPinviewConstant.subtitleText)
                            .font(.system(size: KKPinviewConstant.subtitleFontSize, weight: KKPinviewConstant.subtitleFontWeight))
                            .foregroundColor(KKPinviewConstant.subtitleTextColor)
                        
                        // Forgot PIN label
                        if showForgotPin {
                            Button(action: {
                                onForgotPin?()
                            }) {
                                Text(KKPinviewConstant.forgotPinText)
                                    .font(.system(size: KKPinviewConstant.forgotPinFontSize, weight: KKPinviewConstant.forgotPinFontWeight))
                                    .foregroundColor(KKPinviewConstant.forgotPinTextColor)
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    // PIN input fields - Centered and equally distributed
                    HStack(spacing: KKPinviewConstant.fieldSpacing) {
                        ForEach(0..<KKPinviewConstant.totalDigits, id: \.self) { index in
                            PinDigitField(
                                text: $pinDigits[index],
                                isFocused: currentFieldIndex == index,
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
                            .animation(.easeInOut(duration: 0.3), value: errorMessage)
                    }
                    
                    // Custom Numeric Keypad
                    NumericKeypad(
                        onNumberTap: { number in
                            handleNumberTap(number)
                        },
                        onDeleteTap: {
                            handleDeleteTap()
                        }
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onAppear {
            // Set initial focus
            currentFieldIndex = 0
            errorMessage = nil
        }
    }
    
    // MARK: - Helper Methods
    private func handleNumberTap(_ number: String) {
        // Clear error message when user starts entering new PIN
        if errorMessage != nil {
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = nil
            }
        }
        
        // Find the first empty field
        if let emptyIndex = pinDigits.firstIndex(where: { $0.isEmpty }) {
            pinDigits[emptyIndex] = number
            // Move to next field if not the last one
            if emptyIndex < KKPinviewConstant.totalDigits - 1 {
                currentFieldIndex = emptyIndex + 1
            } else {
                // All fields filled, validate the PIN
                validateAndSubmitPIN()
            }
        }
    }
    
    private func validateAndSubmitPIN() {
        let pinCode = pinDigits.joined()
        
        // Verify PIN using KKPinStorage
        let isValid = KKPinStorage.verifyPIN(pinCode)
        
        if isValid {
            // PIN is valid - clear error, clear fields and notify success
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = nil
            }
            clearPINFields()
            onSubmit?(true)
        } else {
            // PIN is invalid - show error message, clear fields and notify failure
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = KKPinviewConstant.invalidPinErrorText
            }
            clearPINFields()
            onSubmit?(false)
        }
    }
    
    private func clearPINFields() {
        // Clear all PIN fields
        for index in 0..<pinDigits.count {
            pinDigits[index] = ""
        }
        currentFieldIndex = 0
    }
    
    private func handleDeleteTap() {
        // Clear error message when user deletes digits
        if errorMessage != nil {
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = nil
            }
        }
        
        // Find the last filled field
        if let lastFilledIndex = pinDigits.lastIndex(where: { !$0.isEmpty }) {
            // Clear text immediately - PinDigitField will handle the animation
            pinDigits[lastFilledIndex] = ""
            currentFieldIndex = lastFilledIndex
        }
    }
}

#Preview {
    KKPinViews()
}
