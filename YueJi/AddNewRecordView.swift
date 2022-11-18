//
//  AddNewRecordView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/18.
//

import SwiftUI

struct AddNewRecordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var cateDate: Date = Date()
    @State private var title: String = Date.now.formatted(date: .omitted, time: .shortened)
    let tag: Tag
    var year: Int
    var month: Int
    
    private var startDate: Date {
        // 日期不限，从主页进来
        if year == 0 && month == 0 {
            
        }
        
        // 从副页进来，只能是当前年月的日期
        var components = DateComponents()
        components.year = year
        components.month = month
        let startOfMonth = Calendar.current.date(from: components)!
        return startOfMonth
    }

    private var endDate: Date {
        // 日期不限，从主页进来
        if year == 0 && month == 0 {
            
        }
        
        // 从副页进来，只能是当前年月的日期
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.hour = (components.hour ?? 0) - 1
        let endOfMonth = Calendar.current.date(from: components)!
        return endOfMonth
    }
    
    var body: some View {
        VStack {
            Form {
                Section("待添加记录信息") {
                    HStack {
                        Text("标题：")
                        TextField("标题", text: $title)
                    }
                    if month == 0 {
                        DatePicker("选择日期", selection: $cateDate, displayedComponents: .date)
                    } else {
                        DatePicker("选择日期", selection: $cateDate, in: startDate ... endDate, displayedComponents: .date)
                    }
                }
                
                Section("按钮") {
                    Button {
                        addNewItem()
                    } label: {
                        Text("保存")
                    }

                }
            }
        }
    }
    
    func addNewItem() {
        withAnimation {
            let newRecord = Record(context: viewContext)
            newRecord.uuid = UUID()
            newRecord.cateDate = cateDate
            newRecord.modifiedDate = Date.now
            newRecord.createDate = Date.now
            newRecord.text = ""
            newRecord.title = title
            newRecord.tags = [tag]
            newRecord.wordCount = 0
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            dismiss()
        }
    }
}

//struct AddNewRecordView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddNewRecordView()
//    }
//}
