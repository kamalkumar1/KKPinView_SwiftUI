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
//        KKPinViews(
//            onForgotPin: {
//                print("Forgot PIN")
//            },
//            onSubmit: { code in
//                print("Submitted code: \(code)")
//                self.code = code
//            }
//        )
        if(KKPinStorage.hasStoredPIN())
        {
            KKPinViews(
                
                onForgotPin: {
                    print("Forgot PIN")
                },
                onSubmit: { isValid in
                    
                    if isValid {
                        print("pin is valid - proceed to main scrren")
                    }else {
                        print("pin is not valid")
                    }
                }
            )
            
        }else {
            
            KKPINSetUPView(onSetupComplete:     {_ in
                print("Setup complete")
            })
            
        }
      
    }
}

#Preview {
    ContentView()
}
