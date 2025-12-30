//
//  KKPinViews.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

@available(iOS 15.0, *)
public struct KKPinViews: View {
    public static let totalDigits: Int = 4
    
    public init() {}
    @State private var pinDigits: [String] = Array(repeating: "", count: totalDigits)
    @State private var currentFieldIndex: Int = 0
    
    private var currentEmptyFieldIndex: Int {
        pinDigits.firstIndex(where: { $0.isEmpty }) ?? 0
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            // Beautiful gradient background with decorative elements
            PinBackgroundView()
            
            // Content - Centered on screen
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                // Card container for PIN fields - Centered
                VStack(alignment: .center, spacing: 40) {
                    // Title section
                    VStack(alignment: .center, spacing: 10) {
                        Text("Enter \(Self.totalDigits)-Digit Code")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Please enter your PIN to continue")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // PIN input fields - Centered and equally distributed
                    HStack(spacing: 12) {
                        ForEach(0..<Self.totalDigits, id: \.self) { index in
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
            if emptyIndex < Self.totalDigits - 1 {
                currentFieldIndex = emptyIndex + 1
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
