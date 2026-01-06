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
    public var onSubmit: ((String) -> Void)? = nil
    public var showForgotPin: Bool = true
    
    public init(
        onForgotPin: (() -> Void)? = nil,
        onSubmit: ((String) -> Void)? = nil,
        showForgotPin: Bool = KKPinviewConstant.defaultShowForgotPin
    ) {
        self.onForgotPin = onForgotPin
        self.onSubmit = onSubmit
        self.showForgotPin = showForgotPin
    }
    
    @State private var pinDigits: [String] = Array(repeating: "", count: KKPinviewConstant.totalDigits)
    @State private var currentFieldIndex: Int = 0
    
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
        }
    }
    
    // MARK: - Helper Methods
    private func handleNumberTap(_ number: String) {
        // Find the first empty field
        if let emptyIndex = pinDigits.firstIndex(where: { $0.isEmpty }) {
            pinDigits[emptyIndex] = number
            // Move to next field if not the last one
            if emptyIndex < KKPinviewConstant.totalDigits - 1 {
                currentFieldIndex = emptyIndex + 1
            } else {
                // All fields filled, submit the PIN
                let pinCode = pinDigits.joined()
                onSubmit?(pinCode)
            }
        }
    }
    
    private func handleDeleteTap() {
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
