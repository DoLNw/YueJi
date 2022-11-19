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
    
//    @ObservedObject var record: Record
    var record: Record
    private var dateDescription: String {
        let compnents = Calendar.current.dateComponents([.year, .month, .day], from: record.wrappedCreateDate)
        
//        return "\(compnents.year ?? 0)年\(compnents.month ?? 0)月\(compnents.day ?? 0)日"
        return "\(compnents.day ?? 0) 日"
    }
    
    @State private var title: String = "a d s"
    @State private var text: String = "saddas d asd as ads"
    @State private var wordCount: Int = 0
    @State private var aaa = 0.0
    
    @State private var isActive = true
    // 每隔1s保存一次
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
//            ScrollView {
            
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
                    } else {
                        TextEditor(text: $text)
                            .onChange(of: text) { value in
                                let words = text.split { $0 == " " || $0.isNewline }
                                self.wordCount = words.count
                            }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .lineSpacing(5)
                    }
                }
                .padding(15)
            }
//            }
        
            
            
            
//            HighlightedTextEditor(text: $text, highlightRules: .markdown)
//
//                .onCommit {
//                    print("onCommit")
//                }
//                .onEditingChanged {
//                    print("editing changed")
//                }
//                .onTextChange {
//                    print("latest text val", $0)
//                }
//                .onSelectionChange { (range: NSRange) in
//                    print(range)
//                }
////                .introspect { editor in
////                    // access underlying UITextView or NSTextView
////                    editor.textView.backgroundColor = .green
////                }
//                .autocapitalization(.none)
//                .disableAutocorrection(false)
//                .padding(5)
//                .lineSpacing(5)
            
            
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
        
        .navigationTitle("\(dateDescription)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: addItem) {
//                    Label("asd", systemImage: "plus")
//                }
            }
        }
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
            
            print("save")
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
//            record.updateTitle(title: title, text: text)
            try? viewContext.save()
        }
    }
    
    private func addItem() {
//        withAnimation {
//            let newRecord = Record(context: viewContext)
//            newRecord.uuid = UUID()
//            var dateComponent = DateComponents()
//            dateComponent.year = self.year
//            dateComponent.month = self.month
//            dateComponent.day = Int.random(in: 1 ... 31)
//            newRecord.createDate = Calendar.current.date(from: dateComponent)
//            newRecord.modifiedDate = Date()
//            newRecord.text = "Example"
//            newRecord.title = newRecord.createDate!.formatted(date: .long, time: .shortened)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//        record.text = "asasd"
//        record.title = "ASd"
    }
}

//struct DayTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        DayTextView()
//    }
//}

