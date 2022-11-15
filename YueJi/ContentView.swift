//
//  ContentView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/6.
//
// 使用CoreData存储日记，然后使用UserDefaults存储tags

import UIKit
import SwiftUI
import CoreData
import Combine

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ContentView: View {
    @StateObject private var myTag = Tags()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.createDate, ascending: false)],
        animation: .default)
    private var records: FetchedResults<Record>
    private var cateAndFilteredRecords: [Int: [Int: [Record]]] {
        // 当前页面不在自己这里，就不要更新了，太麻烦了，那会不会后面一个层级删除了一个，这里还没更新？到时候再解决吧
        // 正好用normalContentView判断
        var cateAndFilteredRecords1 = [Int: [Int: [Record]]]()
        
        for record in records {
//            if !(currentShowingTag.title == Tag.allTag.title || record.tags?.first?.title == currentShowingTag.title) {
//                continue
//            }
            
            let components = Calendar.current.dateComponents([.year, .month], from: record.wrappedCreateDate)
            
            if let _ = cateAndFilteredRecords1[components.year ?? 0] {
            
            } else {
                cateAndFilteredRecords1[components.year ?? 0] = [Int: [Record]]()
                if let _ = cateAndFilteredRecords1[components.year ?? 0]![components.month ?? 0] {
                    
                } else {
                    cateAndFilteredRecords1[components.year ?? 0]![components.month ?? 0] = [Record]()
                }
            }

            cateAndFilteredRecords1[components.year ?? 0]![components.month ?? 0]?.append(record)
        }
        
        for aa in cateAndFilteredRecords1 {
            for bb in aa.value {
                print(bb.value.count)
            }
        }
        return cateAndFilteredRecords1
    }
    
    @State private var showingTags = true
    @State private var showingTagEditor = false
    @State private var currentTappedTag: Tag = Tag.noneTag
    @State private var currentShowingTag = Tag.noneTag
    // 为了解决，在标签的滑动，然后跳入下一页的时候，标签都会左移，那么currentShowingTag会变化，导致出错。
    @State private var normalContentView = true
    let selectedChangeGemerator = UISelectionFeedbackGenerator()
    
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>

    init() {
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0), scheduler: DispatchQueue.main)
            .first()
            .eraseToAnyPublisher()
        self.detector = detector
    }
    
    var body: some View {
        GeometryReader { fullView in
            NavigationView {
                VStack {
                    List {
                        ForEach(cateAndFilteredRecords.sorted(by: {$0.key > $1.key}), id: \.key) { dictYearRecords in
                            Section("\(dictYearRecords.key)") {
                                ForEach(dictYearRecords.value.sorted(by: {$0.key > $1.key}), id: \.key) { dictMonthRecords in
                                    NavigationLink {
                                        MonthCateView(year: dictYearRecords.key, month: dictMonthRecords.key, cateRecords: dictMonthRecords.value)
                                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                    } label: {
                                        HStack {
                                            Text("\(dictMonthRecords.key)")
                                                .font(.largeTitle)
                                            
                                            VStack(alignment: .leading) {
                                                Spacer()
                                                Text("篇数：\(dictMonthRecords.value.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: deleteItems(offsets:))
                                .background( GeometryReader {
                                    Color.clear
                                        .preference(key: ViewOffsetKey.self, value: -$0.frame(in: .global).origin.y)
                                })
                                .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
                                .onReceive(publisher) { a in
                                    print("\(a)")
                                }
                            }
                        }
                    }
//                            Section("\(dictYearRecords.key)") {
//                                ForEach(dictYearRecords.value.sorted(by: {$0.key > $1.key}), id: \.key) { dictMonthRecords in
//                                    NavigationLink {
//                                        MonthCateView(year: dictYearRecords.key, month: dictMonthRecords.key, cateRecords: dictMonthRecords.value)
//                                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//                                            .task {
//                                                self.normalContentView = false
//                                            }
////                                            .environmentObject(records)
//
//
//                                    } label: {
////                                        HStack {
////        //                                    Text(record.wrappedCreateDate.formatted(date: .omitted, time: .shortened))
////        //                                        .font(.largeTitle)
////                                            Text("\(dictMonthRecords.key)")
////                                                .font(.largeTitle)
////
////                                            VStack(alignment: .leading) {
//////                                                Text(record.wrappedTitle)
////                                                Spacer()
////                                                Text("篇数：\(dictMonthRecords.value.count)")
////                                                    .font(.caption)
////                                                    .foregroundColor(.secondary)
////                                            }
////                                        }
//                                        Text("asd")
//                                    }
//                                }
////                                .onDelete(perform: deleteItems(offsets:))
////                                .background( GeometryReader {
////                                    Color.clear
////                                        .preference(key: ViewOffsetKey.self, value: -$0.frame(in: .global).origin.y)
////                                })
////                                .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
////                                .onReceive(publisher) { a in
////                                    print("\(a)")
////                                }
//                            }
//                        }
//                    }
                    
                    if showingTags {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color(.secondarySystemBackground))
                                .background(.ultraThinMaterial)
                                .shadow(color: .primary.opacity(0.35), radius: 5)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 30) {
                                    ForEach(myTag.tags) { tag in
                                        ZStack {
                                            // 不加这个，下面的Geo不知道大小是多小，所以只能这么办了
                                            Text("\(tag.title)")
                                                .font(.title3)
                                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                                .opacity(0)
                                                .frame(minWidth: fullView.size.width / 4)
    //                                            .background(.blue)

                                            GeometryReader { geo in
                                                if (normalContentView && geo.frame(in: .global).midX >= fullView.size.width / 3 && geo.frame(in: .global).midX <= fullView.size.width / 3 * 2) {
                                                    Text("\(tag.title)")
                                                        .font(.title3)
                                                        .frame(width: geo.size.width)
                                                        .padding([.top, .bottom], 10)
                                                        .background(tag.color)
                                                        .cornerRadius(15)
                                                        .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                    //                                                .position(y: geo.size.height)
                                                    //                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                        .shadow(color: .primary.opacity(0.5), radius: 5)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(Color.blue, lineWidth: 2)
                                                                .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                        )
                                                        .onTapGesture {
                                                            currentTappedTag = tag
                                                            showingTagEditor = true
                                                            print(tag.title)
                                                        }
                                                        .rotation3DEffect(.degrees(-geo.frame(in: .global).midX + fullView.frame(in: .global).midX) / 8, axis: (x: 0, y: 1, z: 0))
                                                        .task {
                                                            print(tag.title)
                                                            print("geo.frame(in: .global).midX: \(geo.frame(in: .global).midX)")
                                                            print("fullView.size.width: \(fullView.size.width)")
                                                            if normalContentView && currentShowingTag != tag {
                                                                selectedChangeGemerator.selectionChanged()
                                                                currentShowingTag = tag
                                                            }
                                                        }
                                                } else {
                                                    Text("\(tag.title)")
                                                        .font(.title3)
                                                        .frame(width: geo.size.width)
                                                        .padding([.top, .bottom], 10)
                                                        .background(tag.color)
                                                        .cornerRadius(15)
                                                        .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                        .shadow(color: .primary.opacity(0.5), radius: 0)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 15)
                                                                .stroke(Color.blue, lineWidth: 0)
                                                                .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                        )
                                                        .onTapGesture {
                                                            currentTappedTag = tag
                                                            showingTagEditor = true
                                                            print(tag.title)
                                                        }
                                                        .rotation3DEffect(.degrees(-geo.frame(in: .global).midX + fullView.frame(in: .global).midX) / 8, axis: (x: 0, y: 1, z: 0))
                                                        .task {
                                                            print(tag.title)
                                                            print("geo.frame(in: .global).midX: \(geo.frame(in: .global).midX)")
                                                            print("fullView.size.width: \(fullView.size.width)")
                                                        }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding([.leading, .trailing], 10)
                            .sheet(isPresented: $showingTagEditor, content: {
                                EditTagView(myTag: myTag, currentTappedTag: currentTappedTag)
                            })

                        }
                        .frame(maxWidth: .infinity, maxHeight: 0.1 * fullView.size.height)
                    }
                }
                .ignoresSafeArea(edges: [.bottom, .leading, .trailing])
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
//                        EditButton()
                        Button(action: show) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                    ToolbarItem {
                        Button(action: randomAddItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .navigationTitle("月记")
                // 注意，不能放在NavigationView下面，这样的话，只有一次了。
                .onAppear {
                    print("ContentView OnAppear")
                    normalContentView = true
                }
                .onDisappear {
                    print("ContentView onDisappear")
//                    normalContentView = false
                }
            }
        }
        .ignoresSafeArea(edges: [.bottom, .leading, .trailing])

    }
    
    private func show() {
        withAnimation {
            showingTags.toggle()
        }
    }
    
    private func randomAddItem() {
        withAnimation {
            let newRecord = Record(context: viewContext)
            newRecord.uuid = UUID()
            var dateComponent = DateComponents()
            dateComponent.year = Int.random(in: 1 ..< 3060)
            dateComponent.month = Int.random(in: 1 ... 12)
            dateComponent.day = Int.random(in: 1 ... 31)
            newRecord.createDate = Calendar.current.date(from: dateComponent)
            newRecord.modifiedDate = Date()
            newRecord.text = "example text"
            newRecord.title = newRecord.createDate!.formatted(date: .long, time: .shortened)
            // 若下面这句没有成功，那么取出的时候，tag默认是无标签的
//            if let tag = myTag.tags.randomElement() {
//                newRecord.tags = [Tag(title: tag.title, color: tag.color)]
//            }
            let tag = myTag.tags[Int.random(in: 1 ..< myTag.tags.count-1)]
            newRecord.tags = [Tag(title: tag.title, color: tag.color)]
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { records[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
