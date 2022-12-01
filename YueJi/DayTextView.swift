//
//  DayTextView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/9.
//

import SwiftUI

struct DayTextView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var record: Record
    private var dateDescription: String {
        let compnents = Calendar.current.dateComponents([.year, .month, .day], from: record.wrappedCreateDate)
        
        return "\(compnents.day ?? 0) 日"
    }
    
//    @FocusState private var texteditorFocused: Bool
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var wordCount: Int = 0
    
    @State private var showSettingView = false
    
    @State private var isActive = true
    // 每隔1s保存一次
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let data = viewModel.backgroundImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .ignoresSafeArea(edges: [.bottom])
                }
                
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        if #available(iOS 16.0, *) {
                            ScrollView {
                                TextField("标题", text: $title)
                                    .padding(20)
                                    .frame(width: geo.size.width)
                                    .font(.title2)
                                
                                
                                TextEditor(text: $text)
                                    .onChange(of: text) { value in
                                        //                        let words = text.split { $0 == " " || $0.isNewline }
                                        //                        self.wordCount = words.count
                                        self.wordCount = text.count
                                    }
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .scrollContentBackground(.hidden)
                                    .multilineTextAlignment(.leading)
//                                    .border(.quaternary, width: 1)
                                    .frame(width: geo.size.width - 30, height: geo.size.height - 100)
                            }
                            .scrollDismissesKeyboard(.interactively)
                        } else {
                            ScrollView {
                                TextField("标题", text: $title)
                                    .padding(20)
                                    .frame(width: geo.size.width)
                                    .font(.title2)
                                
                                TextEditor(text: $text)
                                    .onChange(of: text) { value in
                                        let words = text.split { $0 == " " || $0.isNewline }
                                        self.wordCount = words.count
                                    }
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .lineSpacing(5)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: geo.size.width - 30, height: geo.size.height - 50)
//                                    .focused($texteditorFocused)
                            }
                       }
                    }
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(wordCount) 字数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding([.trailing], 15)
                        
                        Text("\(record.wrappedCreateDate.formatted(date: .abbreviated, time: .omitted)) 创建日期")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding([.trailing], 15)
                    }
                }
                .background(viewModel.backgroundImageData != nil ? .thinMaterial : .thin)
            }
        }
        
        
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
        .sheet(isPresented: $showSettingView, content: {
            if #available(iOS 16.0, *) {
                TextEditorSettingView()
                    .environmentObject(viewModel)
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if #available(iOS 16.0, *) {
                    Button {
                        self.showSettingView = true
                    } label: {
                        Label("设置", systemImage: "gear")
                    }
                }
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


