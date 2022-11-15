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
    var cateRecords: [Record]
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Record.createDate, ascending: false)],
//        animation: .default)
//    private var records: FetchedResults<Record>
//    private var cateRecords: [Record] {
//        var cateRecords = [Record]()
//
//        for record in records {
//            let components = Calendar.current.dateComponents([.year, .month, .day], from: record.wrappedCreateDate)
//            if self.year == components.year && components.month == self.month {
//                cateRecords.append(record)
//            }
//        }
//
//        return cateRecords
//    }
    
    var body: some View {
        List {
            ForEach(cateRecords) { record in
                NavigationLink {
                    DayTextView(record: record)
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                } label: {
                    ZStack(alignment: .topLeading) {
                        Circle()
                            .fill(record.wrappedTags[0].color)
                            .frame(width: 5, height: 5)
                        HStack {
                            Text(record.wrappedCreateDate, format: .dateTime.day())
                                .font(.largeTitle)
                            VStack {
                                Text(record.wrappedTitle)
                            }
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems(offsets:))
        }
//        NavigationLink {
//            DayTextView(record: cateRecords.first!)
//                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//        } label: {
//            Text("Test Example")
//        }
        .navigationTitle("\(year)年\(month)月")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addItem) {
                    Label("asd", systemImage: "plus")
                }
            }
        }
    }
    
    // 理论上添加，就只能根据当前的时间来，我现在模拟
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
        cateRecords.first?.text = "asd asd asd ads asd"
//        cateRecords.last?.title = "asdsa"
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
