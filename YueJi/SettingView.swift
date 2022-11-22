//
//  SettingView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/22.
//

import SwiftUI
import LocalAuthentication

struct SettingView: View {
    @Binding private var shouldLock: Bool
    @Binding private var isUnlocked: Bool
    
    init(shouldLock: Binding<Bool>, isUnlocked: Binding<Bool>) {
        self._shouldLock = shouldLock
        self._isUnlocked = isUnlocked
    }
    
    var body: some View {
        Form {
            Toggle("使用Face ID锁定", isOn: $shouldLock)
                .onChange(of: shouldLock) { newValue in
                        if newValue {
                            authenticate()
                        } else {
                            UserDefaults.standard.set(self.shouldLock, forKey: StaticProperties.USERFEFAULTS_SHOULDLOCK)
                        }
                }
        }
    }
    
    func checkIfFaceIDValid() {
        
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    self.shouldLock = true
                    self.isUnlocked = true
                    UserDefaults.standard.set(self.shouldLock, forKey: StaticProperties.USERFEFAULTS_SHOULDLOCK)
                } else {
                    self.shouldLock = false
                }
            }
        } else {
            self.shouldLock = false
        }
        
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
