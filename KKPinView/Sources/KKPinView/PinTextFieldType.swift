//
//  PinTextFieldType.swift
//  KKPinView
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

// MARK: - Pin Text Field Type
enum PinTextFieldType {
    case rectangle
    case roundCorner
    case withCornerRadius(CGFloat)
    
    var cornerRadius: CGFloat {
        switch self {
        case .rectangle:
            return 0
        case .roundCorner:
            return 35 // Half of 70 (button size) for full circle
        case .withCornerRadius(let radius):
            return radius
        }
    }
}

// MARK: - App Constants
struct AppConstants {
    static let defaultTextFieldType: PinTextFieldType = .roundCorner
}

