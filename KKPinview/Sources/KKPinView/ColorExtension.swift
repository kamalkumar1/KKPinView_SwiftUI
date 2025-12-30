//
//  ColorExtension.swift
//  SampleUI
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

// MARK: - App Colors
@available(iOS 15.0, *)
extension Color {
    public static var appGradientStart: Color {
        Color(red: 0.12, green: 0.50, blue: 0.99)
    }
    
    public static var appGradientEnd: Color {
        Color(red: 0.08, green: 0.38, blue: 0.90)
    }
    
    public static var appSelectedColor: Color {
        appGradientStart
    }
    
    public static var appGradient: LinearGradient {
        LinearGradient(
            colors: [appGradientStart, appGradientEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

