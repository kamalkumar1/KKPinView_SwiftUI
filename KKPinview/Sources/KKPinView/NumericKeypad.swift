//
//  NumericKeypad.swift
//  SampleUI
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

@available(iOS 15.0, *)
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
    public init(
        onNumberTap: @escaping (String) -> Void,
        onDeleteTap: @escaping () -> Void
    ) {
        self.onNumberTap = onNumberTap
        self.onDeleteTap = onDeleteTap
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<numbers.count, id: \.self) { rowIndex in
                HStack(spacing: 16) {
                    ForEach(numbers[rowIndex].indices, id: \.self) { colIndex in
                        let value = numbers[rowIndex][colIndex]
                        
                        if value.isEmpty {
                            // Empty space for layout
                            Spacer()
                                .frame(width: 70, height: 70)
                        } else if value == "X" {
                            // Delete button
                            KeypadButton(
                                value: value,
                                isPressed: pressedButton == value,
                                icon: Image(systemName: "delete.backward.fill"),
                                fontSize: 24,
                                fontWeight: .medium,
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
                                fontSize: 28,
                                fontWeight: .semibold,
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
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
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

@available(iOS 15.0, *)
struct KeypadButton: View {
    let value: String
    let isPressed: Bool
    var text: String? = nil
    var icon: Image? = nil
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    var buttonType: PinTextFieldType = AppConstants.defaultTextFieldType
    let onTap: () -> Void
    
    // MARK: - Background Shape Based on Type
    @ViewBuilder
    private var backgroundShape: some View {
        switch buttonType {
        case .rectangle:
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 70, height: 70)
        case .roundCorner:
            // Fully round (Circle)
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 70, height: 70)
        case .withCornerRadius:
            // Rounded rectangle with corner radius
            RoundedRectangle(cornerRadius: buttonType.cornerRadius)
                .fill(Color.white.opacity(0.2))
                .frame(width: 70, height: 70)
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
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(backgroundShape)
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.appGradient
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

