//
//  PinDigitField.swift
//  SampleUI
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

@available(iOS 15.0, *)
struct PinDigitField: View {
    @Binding var text: String
    let isFocused: Bool
    var fieldSize: CGFloat?
    var fieldType: PinTextFieldType = AppConstants.defaultTextFieldType
    @State private var fontSize: CGFloat = 8
    @State private var displayText: String = ""
    @State private var opacity: Double = 1.0
    @State private var showSecure: Bool = false
    
    // Secure character to display
    private let secureCharacter: String = "●"
    
    // MARK: - Frame Dimensions (Fixed for all screen types)
    static let fieldHeight: CGFloat = 70
    static let normalFontSize: CGFloat = 24
    static let smallFontSize: CGFloat = 8
    
    // Equal width and height (circular shape - market standard)
    private var size: CGFloat {
        fieldSize ?? Self.fieldHeight // Default to height if not provided
    }
    
    // MARK: - Background Shape Based on Type
    @ViewBuilder
    private var backgroundShape: some View {
        switch fieldType {
        case .rectangle:
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: size, height: size)
        case .roundCorner:
            // Fully round (Circle)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: size, height: size)
        case .withCornerRadius:
            // Rounded rectangle with corner radius
            RoundedRectangle(cornerRadius: fieldType.cornerRadius)
                .fill(Color.white.opacity(0.2))
                .frame(width: size, height: size)
        }
    }
    
    var body: some View {
        ZStack {
            // Background - Shape based on fieldType
            backgroundShape
            
            // Text display with animated font size
            // Show secure character if enabled, otherwise show actual text
            Text(showSecure && !displayText.isEmpty ? secureCharacter : displayText)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: size, height: size)
                .opacity(opacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: fontSize)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: opacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSecure)
            
            // Invisible TextField for input handling
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: Self.normalFontSize, weight: .medium))
                .foregroundColor(.clear)
                .frame(width: size, height: size)
                .disabled(true)
        }
        .onChange(of: text) { oldValue, newValue in
            // Animate font size from small to big when text appears
            if oldValue.isEmpty && !newValue.isEmpty {
                displayText = newValue
                showSecure = false // Show actual number during animation
                opacity = 1.0
                fontSize = Self.smallFontSize
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        fontSize = Self.normalFontSize
                    }
                    // After animation completes, show secure character
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showSecure = true
                    }
                }
            } else if !oldValue.isEmpty && newValue.isEmpty {
                // Animate font size from normal to small (reverse of display animation)
                // Show secure character during delete animation
                showSecure = true
                displayText = secureCharacter // Keep secure character visible during animation
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    fontSize = Self.smallFontSize
                }
                // Clear display text immediately when animation completes (precise timing)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    displayText = ""
                    showSecure = false
                }
            } else if !newValue.isEmpty {
                // Keep displayText in sync when text is not empty
                displayText = newValue
                // If text exists, show secure character
                showSecure = true
            }
        }
        .onAppear {
            // Set initial font size and display text based on text state
            displayText = text
            fontSize = text.isEmpty ? Self.smallFontSize : Self.normalFontSize
            opacity = text.isEmpty ? 0.0 : 1.0
            showSecure = !text.isEmpty // Show secure if text exists
        }
    }
}

#Preview {
    PinDigitField(text: .constant("5"), isFocused: true)
}

