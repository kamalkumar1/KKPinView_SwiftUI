//
//  ContentView.swift
//  KKPinview_SwiftUI
//
//  Created by kamalkumar on 30/12/25.
//

import SwiftUI
import KKPinView

struct ContentView: View {
    @State private var code: String = ""
    var body: some View {
        KKPinViews(
            onForgotPin: {
                print("Forgot PIN")
            },
            onSubmit: { code in
                print("Submitted code: \(code)")
                self.code = code
            }
        )
    }
}

#Preview {
    ContentView()
}
