//
//  ColorExtension.swift
//  SampleUI
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

// MARK: - App Colors
extension Color {
    static var appGradientStart: Color {
        Color(red: 0.12, green: 0.50, blue: 0.99)
    }
    
    static var appGradientEnd: Color {
        Color(red: 0.08, green: 0.38, blue: 0.90)
    }
    
    static var appSelectedColor: Color {
        appGradientStart
    }
    
    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [appGradientStart, appGradientEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

