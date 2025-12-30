//
//  PinBackgroundView.swift
//  SampleUI
//
//  Created by kamalkumar on 27/12/25.
//

import SwiftUI

@available(iOS 15.0, *)
public struct PinBackgroundView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            // Base gradient background
            Color.appGradient
                .ignoresSafeArea()
            
            // Decorative circles for depth
            GeometryReader { geometry in
                // Large circle - top right
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(x: geometry.size.width * 0.4, y: -geometry.size.height * 0.2)
                    .blur(radius: 40)
                
                // Medium circle - bottom left
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    .offset(x: -geometry.size.width * 0.3, y: geometry.size.height * 0.6)
                    .blur(radius: 30)
                
                // Small accent circle
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.3)
                    .offset(x: geometry.size.width * 0.7, y: geometry.size.height * 0.3)
                    .blur(radius: 20)
            }
        }
    }
}

#Preview {
    PinBackgroundView()
}

