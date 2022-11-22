//
//  DayTextView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/9.
//

import SwiftUI
//import HighlightedTextEditor

struct DayTextView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    var record: Record
    private var dateDescription: String {
        let compnents = Calendar.current.dateComponents([.year, .month, .day], from: record.wrappedCreateDate)
        
        return "\(compnents.day ?? 0) 日"
    }
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var wordCount: Int = 0
    
    @State private var isActive = true
    // 每隔1s保存一次
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
//            ScrollView {
            
            GeometryReader { geo in
                VStack {
                    ScrollView {
                        TextField("标题", text: $title)
                            .font(.title2)
                            .padding([.leading, .trailing], 10)
                        
                        if #available(iOS 16.0, *) {
                            TextEditor(text: $text)
                                .onChange(of: text) { value in
            //                        let words = text.split { $0 == " " || $0.isNewline }
            //                        self.wordCount = words.count
                                    self.wordCount = text.count
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(5)
                                .scrollDismissesKeyboard(.interactively)
                                .multilineTextAlignment(.leading)
                                .frame(width: geo.size.width, height: geo.size.height - 50)
//                                .background(.blue)
                        } else {
                            TextEditor(text: $text)
                                .onChange(of: text) { value in
                                    let words = text.split { $0 == " " || $0.isNewline }
                                    self.wordCount = words.count
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                                .frame(width: geo.size.width, height: geo.size.height - 50)
//                                .background(.blue)
                        }
                    }
                }
            }
//            }
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(wordCount) 字数")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding([.trailing], 5)
                
                Text("\(record.wrappedCreateDate.formatted(date: .abbreviated, time: .omitted)) 创建日期")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding([.trailing], 5)
            }
        }
        .padding(15)
        .navigationTitle("\(dateDescription)")
        .navigationBarTitleDisplayMode(.inline)
        
        .onDisappear {
            // 退出的时候也保存一次
            save()
        }
        .onAppear {
            text = record.wrappedText
            title = record.wrappedTitle
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            print("save records every second!")
            save()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                isActive = true
            } else {
                isActive = false
            }
        }
    }
    
    func save() {
        viewContext.performAndWait {
            record.title = title
            record.text = text
            try? viewContext.save()
        }
    }
}


