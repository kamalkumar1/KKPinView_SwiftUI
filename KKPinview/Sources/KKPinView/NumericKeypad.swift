//
//  NumericKeypad.swift
//  SampleUI
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

struct NumericKeypad: View {
    let onNumberTap: (String) -> Void
    let onDeleteTap: () -> Void
    
    @State private var pressedButton: String? = nil
    
    private let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "X"]
    ]
    
    var body: some View {
        VStack(spacing: KKPinviewConstant.keypadSpacing) {
            ForEach(0..<numbers.count, id: \.self) { rowIndex in
                HStack(spacing: KKPinviewConstant.keypadSpacing) {
                    ForEach(0..<numbers[rowIndex].count, id: \.self) { colIndex in
                        let value = numbers[rowIndex][colIndex]
                        
                        if value.isEmpty {
                            // Empty space for layout
                            Spacer()
                                .frame(width: KKPinviewConstant.buttonSize, height: KKPinviewConstant.buttonSize)
                        } else if value == KKPinviewConstant.deleteButtonValue {
                            // Delete button
                            KeypadButton(
                                value: value,
                                isPressed: pressedButton == value,
                                icon: Image(systemName: KKPinviewConstant.deleteButtonIconName),
                                fontSize: KKPinviewConstant.deleteButtonFontSize,
                                fontWeight: KKPinviewConstant.deleteButtonFontWeight,
                                onTap: {
                                    handleButtonPress(value) {
                                        onDeleteTap()
                                    }
                                }
                            )
                        } else {
                            // Number button
                            KeypadButton(
                                value: value,
                                isPressed: pressedButton == value,
                                text: value,
                                fontSize: KKPinviewConstant.numberButtonFontSize,
                                fontWeight: KKPinviewConstant.numberButtonFontWeight,
                                onTap: {
                                    handleButtonPress(value) {
                                        onNumberTap(value)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, KKPinviewConstant.keypadHorizontalPadding)
        .padding(.vertical, KKPinviewConstant.keypadVerticalPadding)
    }
    
    private func handleButtonPress(_ value: String, action: @escaping () -> Void) {
        // Animate button press with smooth spring animation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            pressedButton = value
        }
        
        // Execute action immediately
        action()
        
        // Reset button state after animation completes smoothly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                pressedButton = nil
            }
        }
    }
}

struct KeypadButton: View {
    let value: String
    let isPressed: Bool
    var text: String? = nil
    var icon: Image? = nil
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    var buttonType: PinTextFieldType = KKPinviewConstant.defaultTextFieldType
    let onTap: () -> Void
    
    // MARK: - Background Shape Based on Type
    @ViewBuilder
    private var backgroundShape: some View {
        switch buttonType {
        case .rectangle:
            Rectangle()
                .fill(KKPinviewConstant.fieldBackgroundColor)
                .overlay(
                    Rectangle()
                        .stroke(KKPinviewConstant.fieldStrokeColor, lineWidth: KKPinviewConstant.fieldStrokeWidth)
                )
                .frame(width: KKPinviewConstant.buttonSize, height: KKPinviewConstant.buttonSize)
        case .roundCorner:
            // Fully round (Circle)
            Circle()
                .fill(KKPinviewConstant.fieldBackgroundColor)
                .overlay(
                    Circle()
                        .stroke(KKPinviewConstant.fieldStrokeColor, lineWidth: KKPinviewConstant.fieldStrokeWidth)
                )
                .frame(width: KKPinviewConstant.buttonSize, height: KKPinviewConstant.buttonSize)
        case .withCornerRadius:
            // Rounded rectangle with corner radius
            RoundedRectangle(cornerRadius: buttonType.cornerRadius)
                .fill(KKPinviewConstant.fieldBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: buttonType.cornerRadius)
                        .stroke(KKPinviewConstant.fieldStrokeColor, lineWidth: KKPinviewConstant.fieldStrokeWidth)
                )
                .frame(width: KKPinviewConstant.buttonSize, height: KKPinviewConstant.buttonSize)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Group {
                if let icon = icon {
                    icon
                        .font(.system(size: fontSize, weight: fontWeight))
                } else if let text = text {
                    Text(text)
                        .font(.system(size: fontSize, weight: fontWeight))
                }
            }
            .foregroundColor(KKPinviewConstant.buttonTextColor)
            .frame(width: KKPinviewConstant.buttonSize, height: KKPinviewConstant.buttonSize)
            .background(backgroundShape)
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.white
        NumericKeypad(
            onNumberTap: { number in
                print("Tapped: \(number)")
            },
            onDeleteTap: {
                print("Delete tapped")
            }
        )
    }
}

