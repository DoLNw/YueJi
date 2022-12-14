//
//  MonthCateView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/9.
//

import SwiftUI

struct MonthCateView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    let year: Int
    let month: Int
    var cateRecords: [Record]
    
//    let selectedChangeGemerator = UISelectionFeedbackGenerator()
    
    
    @Binding var currentShowingTagID: UUID
    
    @State private var showConfirationDelete = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var personInfo: PersonInfo
    
    // 为了改动record后，能刷新该页面
    @State private var refreshID = true
    @State private var showAddNewRecord = false
    @State private var currentChangedRecord: Record?
    
    @State private var readerMode: Bool = false
    
    init(year: Int, month: Int, cateRecords: [Record], currentShowingTagID: Binding<UUID>) {
        self.year = year
        self.month = month
        self.cateRecords = cateRecords
        self._currentShowingTagID = currentShowingTagID
    }
    
    var body: some View {
        Group {
            if !readerMode {
                List {
                    ForEach(cateRecords) { record in
                        let currentTag = personInfo.getTag(from: record.wrappedTagIDs.first!)
                        NavigationLink {
                            DayTextView(record: record)
                                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                                .environmentObject(viewModel)
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                Circle()
                                    .fill(currentTag.color)
                                    .frame(width: 7, height: 7)
                                
                                HStack {
                                    HStack(spacing: 3) {
                                        let datecom = Calendar.current.dateComponents([.day], from: record.wrappedCateDate)
                                        Text(String(format: "%02d", (datecom.day ?? 0)))
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
                    .onDelete(perform: deleteItems(offsets:))
                    .alert("确定删除吗？\n目前该操作不可修改", isPresented: $showConfirationDelete, actions: {
                        Button("删除", role: .destructive) {
                        }
                    })
                }
            } else {
                List {
                    ForEach(cateRecords) { record in
                        Section {
                            Text(record.wrappedText)
                        } header: {
                            HStack {
                                Circle()
                                    .fill(personInfo.getTag(from: record.wrappedTagIDs.first!).color)
                                    .frame(width: 7, height: 7)
                                Text(record.wrappedTitle)
                                
                                Spacer()
                                
                                Text(record.wrappedCateDate, format: .dateTime.day())
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .sheet(isPresented: $showAddNewRecord, content: {
            AddNewRecordView(records: cateRecords, tagID: currentShowingTagID, year: year, month: month)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(personInfo)
        })
        .sheet(item: $currentChangedRecord, content: { record in
            ChangeTagView(refreshID: $refreshID, record: record)
                .environmentObject(personInfo)
        })
        
        .onAppear {
            readerMode = UserDefaults.standard.bool(forKey: StaticProperties.USERDEFAULTS_READERMMODE)
            refreshID.toggle()
        }
        .navigationTitle("\(year)年\(month)月")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !(currentShowingTagID == Tag.noneTag.id || currentShowingTagID == Tag.addTag.id || currentShowingTagID == Tag.allTag.id) {
                    Button {
//                        selectedChangeGemerator.selectionChanged()
                        showAddNewRecord = true
                    } label: {
                        Label("添加", systemImage: "plus")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
//                    selectedChangeGemerator.selectionChanged()
                    readerMode.toggle()
                    UserDefaults.standard.set(readerMode, forKey: StaticProperties.USERDEFAULTS_READERMMODE)
                } label: {
                    if readerMode {
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                    } else {
                        Image(systemName: "list.bullet.rectangle.portrait")
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { cateRecords[$0] }.forEach(viewContext.delete)
            
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

//struct MonthCateView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonthCateView(year: 12, month: 12)
//    }
//}
