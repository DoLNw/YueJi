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
import LocalAuthentication

var fullWidth: CGFloat = UIScreen.main.bounds.width
var fullHeight: CGFloat = UIScreen.main.bounds.height

struct ContentView: View {
    @State private var isUnlocked = false
    
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
                    self.isUnlocked = true
                } else {
                    self.isUnlocked = false
                }
            }
        } else {
            self.isUnlocked = false
        }
    }
    
    @StateObject private var myTag = Tags()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.cateDate, ascending: false)],
        animation: .default)
    private var records: FetchedResults<Record>
    private var filteredRecords: [Record] {
        var filteredRecords1 = [Record]()
        
        for record in self.records {
            if currentShowingTagID == Tag.allTag.id || record.wrappedTagIDs.first == currentShowingTagID {
                filteredRecords1.append(record)
            }
        }
        
        return filteredRecords1
    }
    private var cateAndFilteredRecords: [Int: [Int: [Record]]] {
        var cateAndFilteredRecords1 = [Int: [Int: [Record]]]()
        
        for record in self.filteredRecords {
            if !(currentShowingTagID == Tag.allTag.id || record.wrappedTagIDs.first == currentShowingTagID) {
                continue
            }
            
            let components = Calendar.current.dateComponents([.year, .month], from: record.wrappedCateDate)
            
            if let _ = cateAndFilteredRecords1[components.year ?? 0] {
                
            } else {
                cateAndFilteredRecords1[components.year ?? 0] = [Int: [Record]]()
            }
            if let _ = cateAndFilteredRecords1[components.year ?? 0]![components.month ?? 0] {
                
            } else {
                cateAndFilteredRecords1[components.year ?? 0]![components.month ?? 0] = [Record]()
            }

            cateAndFilteredRecords1[components.year ?? 0]![components.month ?? 0]?.append(record)
        }
        
        return cateAndFilteredRecords1
    }
    
    @State private var showingTags = true
    @State private var showAddNewRecord = false
    @State private var showSettingView = false
    // 为了能让record改变后，更新
    @State var refreshID = false
    @State private var currentChangedRecord: Record?
    
//    @State private var flatMode: Bool = UserDefaults.standard.bool(forKey: StaticProperties.USERDEFAULTS_READERMMODE)
    @AppStorage(StaticProperties.USERDEFAULTS_READERMMODE) private var flatMode: Bool = false
    @State private var shouldLock: Bool = UserDefaults.standard.bool(forKey: StaticProperties.USERFEFAULTS_SHOULDLOCK)
    
    @State private var currentTappedTagID: UUID?
    @State private var currentShowingTagID = Tag.allTag.id
    // 为了解决，在标签的滑动，然后跳入下一页的时候，标签都会左移，那么currentShowingTag会变化，导致出错。
    @State private var addButtonAnimationAmount = 1.0
    let selectedChangeGemerator = UISelectionFeedbackGenerator()
    
    var body: some View {
        GeometryReader { fullView in
            ZStack {
                NavigationView {
                    VStack {
                        if flatMode {
                            List {
                                ForEach(cateAndFilteredRecords.sorted(by: {$0.key > $1.key}), id: \.key) { dictYearRecords in
                                    Section(header: Text("\(dictYearRecords.key)年")
                                        .font(.title)) {
                                        ForEach(dictYearRecords.value.sorted(by: {$0.key > $1.key}), id: \.key) { dictMonthRecords in
                                            Section(header: Text("\(dictMonthRecords.key)月")
                                                .font(.title)
                                                .foregroundColor(.secondary)) {
                                                ForEach(dictMonthRecords.value) { record in
                                                    let currentTag = myTag.getTag(from: record.wrappedTagIDs.first!)
                                                    
                                                    NavigationLink {
                                                        DayTextView(record: record)
                                                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                                    } label: {
                                                        HStack {
                                                            Circle()
                                                                .fill(currentTag.color)
                                                                .frame(width: 7, height: 7)
                                                            
                                                            HStack {
                                                                HStack(spacing: 3) {
                                                                    Text(record.wrappedCateDate, format: .dateTime.day())
                                                                        .font(.title2)
                                                                    
                                                                    Text("日")
                                                                        .font(.caption)
                                                                        .offset(y: 10)
                                                                }
                                                                .padding([.leading], 5)
                                                                .padding([.top, .bottom], 10)
                                                                .padding([.trailing], 20)
                                                                
                                                                VStack(alignment: .leading, spacing: 15) {
                                                                    Text(record.wrappedTitle + (refreshID ? "" : ""))
    //                                                                    .foregroundColor(Color(UIColor.darkGray))
                                                                    Text(record.wrappedText)
                                                                        .lineLimit(2)
                                                                        .font(.caption)
                                                                        .foregroundColor(.secondary)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .swipeActions(edge: .leading) {
                                                        Button {
                                                            currentChangedRecord = record
                                                        } label: {
                                                            HStack {
                                                                Text(currentTag.title)
                                                                Label(currentTag.title, systemImage: "tag")
                                                            }
                                                        }
                                                        .tint(currentTag.color)
                                                    }
                                                }
                                            }
    //                                        .headerProminence(.increased)
                                        }
                                    }
                                }
                            }
                            .listStyle(.sidebar)
                        } else {
                            List {
                                ForEach(cateAndFilteredRecords.sorted(by: {$0.key > $1.key}), id: \.key) { dictYearRecords in
                                    Section(header: Text("\(dictYearRecords.key)年")
                                        .font(.title)) {
                                        ForEach(dictYearRecords.value.sorted(by: {$0.key > $1.key}), id: \.key) { dictMonthRecords in
                                            NavigationLink {
                                                MonthCateView(year: dictYearRecords.key, month: dictMonthRecords.key, cateRecords: dictMonthRecords.value, myTag: myTag, currentShowingTagID: $currentShowingTagID)
                                                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                            } label: {
                                                HStack {
                                                    HStack {
                                                        Text("\(dictMonthRecords.key)")
                                                            .font(.largeTitle)
                                                        Text("月")
                                                            .font(.caption)
                                                            .offset(y: 5)
                                                    }

                                                    Spacer()

                                                    VStack(alignment: .leading) {
                                                        Spacer()
                                                        Text("篇数：\(dictMonthRecords.value.count)")
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .padding([.trailing], 5)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .listStyle(.sidebar)
                        }
                        
                        if showingTags {
    //                        ZStack {
    //                            RoundedRectangle(cornerRadius: 15)
    //                                .foregroundColor(Color(.secondarySystemBackground))
    //                                .background(.ultraThinMaterial)
    //                                .shadow(color: .primary.opacity(0.35), radius: 5)

                                GeometryReader { scrollewViewGeo in
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
                                                    
                                                    GeometryReader { geo in
                                                        if (scrollewViewGeo.frame(in: .global).minX > 0 && geo.frame(in: .global).midX >= fullView.size.width / 3 && geo.frame(in: .global).midX <= fullView.size.width / 3 * 2) {
                                                            Text("\(tag.title)")
                                                                .font(.title3)
                                                                .frame(width: geo.size.width)
                                                                .padding([.top, .bottom], 10)
                                                                .background(tag.color)
                                                                .cornerRadius(15)
                                                                .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                                .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 15)
                                                                        .stroke(Color.blue, lineWidth: 2)
                                                                        .scaleEffect(addButtonAnimationAmount)
                                                                        .opacity(-2 * addButtonAnimationAmount + 3)
                                                                        .animation(.easeOut(duration: addButtonAnimationAmount - 1), value: addButtonAnimationAmount)
                                                                        .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                                )
                                                                .onTapGesture {
                                                                    currentTappedTagID = tag.id
                                                                }
                                                                .rotation3DEffect(.degrees(-geo.frame(in: .global).midX + fullView.frame(in: .global).midX) / 8, axis: (x: 0, y: 1, z: 0))
                                                                .task {
                                                                    if currentShowingTagID != tag.id {
                                                                        selectedChangeGemerator.selectionChanged()
                                                                        currentShowingTagID = tag.id

                                                                        if tag.title == Tag.addTag.title {
                                                                            addButtonAnimationAmount = 1.5
                                                                        } else {
                                                                            addButtonAnimationAmount = 1
                                                                        }
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
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 15)
                                                                        .stroke(Color.blue, lineWidth: 0)
                                                                        .offset(CGSize(width: 0, height: geo.size.height / 5))
                                                                )
                                                                .onTapGesture {
                                                                    currentTappedTagID = tag.id
                                                                }
                                                                .rotation3DEffect(.degrees(-geo.frame(in: .global).midX + fullView.frame(in: .global).midX) / 8, axis: (x: 0, y: 1, z: 0))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding([.leading, .trailing], 10)
                                .sheet(item: $currentTappedTagID, content: { tagId in
                                    EditTagView(myTag: myTag, currentTappedTagID: tagId, records: records)
                                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                })
                                .sheet(isPresented: $showAddNewRecord, content: {
                                    AddNewRecordView(records: filteredRecords, myTag: myTag, tagID: currentShowingTagID, year: 0, month: 0)
                                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                })
                                .sheet(item: $currentChangedRecord, content: { record in
                                    ChangeTagView(refreshID: $refreshID, myTag: myTag, record: record)
                                })
                                .sheet(isPresented: $showSettingView, content: {
                                    SettingView(shouldLock: $shouldLock, isUnlocked: $isUnlocked)
                                })
                                .onAppear {
                                    refreshID.toggle()
                                }
    //                        }
                            .frame(maxWidth: .infinity, maxHeight: 0.13 * fullView.size.height)
                        }
                    }
                    .ignoresSafeArea(edges: [.bottom, .leading, .trailing])
                    
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !(currentShowingTagID == Tag.noneTag.id || currentShowingTagID == Tag.addTag.id || currentShowingTagID == Tag.allTag.id) {
                                Button {
                                    selectedChangeGemerator.selectionChanged()
                                    self.showAddNewRecord = true
                                } label: {
                                    Label("Add Item", systemImage: "plus")
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                selectedChangeGemerator.selectionChanged()
                                self.flatMode.toggle()
//                                UserDefaults.standard.set(self.flatMode, forKey: StaticProperties.USERFEFAULTS_FLATMODE)
                            } label: {
                                if self.flatMode {
                                    Label("flatMode", systemImage: "rectangle.fill.on.rectangle.fill")
                                } else {
                                    Label("flatMode", systemImage: "rectangle.on.rectangle")
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                selectedChangeGemerator.selectionChanged()
                                self.showSettingView = true
                            } label: {
                                Label("设置", systemImage: "gear")
                            }
                        }
                    }
                    .navigationTitle("月记：\(myTag.getTag(from: currentShowingTagID).title)")
                }
                
                if shouldLock && !isUnlocked {
                    Text("请使用Face ID解锁")
                        .frame(width: fullWidth, height: fullHeight)
                        .background(.ultraThinMaterial)
                        .onTapGesture {
                            authenticate()
                        }
                }
            }

            // 注意，NavigationView下面的onAppear，只有一次。
            .onAppear {
                if shouldLock && !isUnlocked {
                    authenticate()
                }
                
//                flatMode = UserDefaults.standard.bool(forKey: StaticProperties.USERFEFAULTS_FLATMODE)
                shouldLock = UserDefaults.standard.bool(forKey: StaticProperties.USERFEFAULTS_SHOULDLOCK)
                currentShowingTagID = Tag.allTag.id
                addCurrentItem()
            }
        }
        .ignoresSafeArea(edges: [.bottom, .leading, .trailing])
    }
    
    // 进入app的时候，查看当前是否有今天的日记标签的record，没有的话添加
    private func addCurrentItem() {
        let dateCompoments = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
        
        for record in records {
            let com = Calendar.current.dateComponents([.year, .month, .day], from: record.wrappedCateDate)
            if com.description == dateCompoments.description {
                return
            }
        }
        
        withAnimation {
            let newRecord = Record(context: viewContext)
            newRecord.uuid = UUID()
            newRecord.cateDate = Date.now
            newRecord.modifiedDate = Date()
            newRecord.text = "目前没有内容"
            newRecord.title = "没有标题\(newRecord.cateDate!.formatted(date: .omitted, time: .shortened))"
            newRecord.tagIDs = [Tag.journalTag.id]
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
