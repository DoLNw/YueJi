//
//  MonthCateView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/9.
//

import SwiftUI

struct MonthCateView: View {
    let year: Int
    let month: Int
    var cateDates: [Record]
    
    @Binding var currentShowingTag: Tag
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    private var didSave = NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    // 为了改动record后，能刷新该页面
    @State private var refreshID = true
    @State private var showAddNewRecord = false
    
    @State private var showingMode = true
    
    init(year: Int, month: Int, cateDates: [Record], currentShowingTag: Binding<Tag>) {
        self.year = year
        self.month = month
        self.cateDates = cateDates
        self._currentShowingTag = currentShowingTag
    }
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Record.cateDate, ascending: false)],
//        animation: .default)
//    private var records: FetchedResults<Record>
//    private var cateDates: [Record] {
//        var cateDates = [Record]()
//
//        for record in records {
//            let components = Calendar.current.dateComponents([.year, .month, .day], from: record.wrappedcateDate)
//            if self.year == components.year && components.month == self.month {
//                cateDates.append(record)
//            }
//        }
//
//        return cateDates
//    }
    
    var body: some View {
        Group {
            if showingMode {
                List {
                    ForEach(cateDates) { record in
                        NavigationLink {
                            DayTextView(record: record)
                                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        } label: {
                            ZStack(alignment: .topLeading) {
                                Circle()
                                    .fill(record.wrappedTags[0].color)
                                    .frame(width: 5, height: 5)
                                HStack {
                                    Text(record.wrappedCateDate, format: .dateTime.day())
                                        .font(.largeTitle)
                                    VStack {
                                        Text(record.wrappedTitle + (refreshID ? "" : ""))
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteItems(offsets:))
        //            .id(refreshID)
        //            .onReceive(self.didSave, perform: { _ in
        //                self.refreshID = UUID()
        //            })
                }
                .sheet(isPresented: $showAddNewRecord, content: {
                    AddNewRecordView(tag: currentShowingTag, year: year, month: month)
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                })
            } else {
                List {
                    ForEach(cateDates) { record in
                        VStack {
                            Text(record.wrappedTitle)
                            Text(record.wrappedText)
                        }
                    }
                }
            }
        }
        .onAppear {
            refreshID.toggle()
            // 没必要，主页添加了
//            addCurrentItem()
        }
//        NavigationLink {
//            DayTextView(record: cateDates.first!)
//                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//        } label: {
//            Text("Test Example")
//        }
        .navigationTitle("\(year)年\(month)月")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddNewRecord = true
                } label: {
                    Label("asd", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingMode.toggle()
                } label: {
                    Text("Mode")
                }
            }
        }
    }
    
    // 理论上添加，就只能根据当前的时间来，我现在模拟
    private func addCurrentItem() {
        let dateComponment = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
        let nowYear = dateComponment.year ?? 0
        let nowMonth = dateComponment.month ?? 0
        let nowDay = dateComponment.day ?? 0
        if nowYear == year && nowMonth == month {
            for record in cateDates {
                let com = Calendar.current.dateComponents([.day], from: record.wrappedCateDate)
                if (com.day ?? 0) == nowDay {
                    return
                }
            }
        }
        
        withAnimation {
            let newRecord = Record(context: viewContext)
            newRecord.uuid = UUID()
            newRecord.cateDate = Date.now
            newRecord.modifiedDate = Date()
            newRecord.text = ""
            newRecord.title = newRecord.cateDate!.formatted(date: .long, time: .omitted)
            
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
//            offsets.map { records[$0] }.forEach(viewContext.delete)

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
