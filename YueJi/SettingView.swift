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
    @State private var showStateAlert: Bool = false
    
    @State private var showPrivacyAlert: Bool = false
    
    let accumulateDays: Int
    
    init(shouldLock: Binding<Bool>, isUnlocked: Binding<Bool>, accumulateDays: Int) {
        self._shouldLock = shouldLock
        self._isUnlocked = isUnlocked
        self.accumulateDays = accumulateDays
    }
    
    var body: some View {
        VStack {
            Form {
                Section("设置") {
                    Toggle("使用Face ID锁定", isOn: $shouldLock)
                        .onChange(of: shouldLock) { newValue in
                            if newValue {
                                authenticate()
                            } else {
                                UserDefaults.standard.set(self.shouldLock, forKey: StaticProperties.USERFEFAULTS_SHOULDLOCK)
                            }
                        }
                }
                
                let year = accumulateDays / 7 / 4 / 12
                let month = accumulateDays / 7 / 4 % 12
                let week = accumulateDays / 7 % 4
                let day = accumulateDays % 7
                let nextYear = (accumulateDays + 1) / 7 / 4 / 12
                let nextMonth = (accumulateDays + 1) / 7 / 4 % 12
                let nextWeek = (accumulateDays + 1) / 7 % 4
                let nextDay = (accumulateDays + 1) % 7
                Section("累计签到：\(year)年\(month)月\(week)周\(day)日") {
                    HStack {
                        ForEach(0..<year, id: \.self) { index in
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                        
                        if nextYear > year {
                            Image(systemName: "sun.max")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                    }
                    HStack {
                        ForEach(0..<month, id: \.self) { index in
                            Image(systemName: "moon.stars.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                        
                        if nextMonth > month {
                            Image(systemName: "moon.stars")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                    }
                    HStack {
                        ForEach(0..<week, id: \.self) { index in
                            Image(systemName: "moon.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                        
                        if nextWeek > week {
                            Image(systemName: "moon")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                    }
                    HStack {
                        ForEach(0..<day, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                        
                        if nextDay > day {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                    }
                }
                .onTapGesture {
                    withAnimation {
                        self.showStateAlert.toggle()
                    }
                }
                
                if self.showStateAlert {
                    Section("累计说明表") {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("年：")
                                Image(systemName: "sun.max.fill")
                                    .foregroundColor(.yellow)
                                Text("= 12")
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.yellow)
                            }
                            HStack {
                                Text("月：")
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.yellow)
                                Text("= 4")
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.yellow)
                            }
                            HStack {
                                Text("周：")
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.yellow)
                                Text("= 7")
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            HStack {
                                Text("天：")
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("= 1天")
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .center) {
                Text("开发人员：王嘉诚")
                    .font(.caption)
                Text("联系邮箱：jcwang0717@163.com")
                    .font(.caption)
            }
        }
        .alert(isPresented: $showPrivacyAlert) {
            Alert(title: Text("需要Face ID权限"),
            message: Text("前往设置？"),
            primaryButton: .default(Text("设置"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }),
            secondaryButton: .default(Text("取消")))
        }
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
            self.showPrivacyAlert = true
            self.shouldLock = false
        }
        
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
