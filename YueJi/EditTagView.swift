//
//  EditTagView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/10.
//

import SwiftUI
import UIKit

struct EditTagView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showConfirmDelete = false
    
    @State private var tagTitle = ""
    @State private var tagColor = Color.white
    
    private var isSysTag: Bool {
        return currentTappedTagID == Tag.noneTag.id || currentTappedTagID == Tag.allTag.id || currentTappedTagID == Tag.journalTag.id || currentTappedTagID == Tag.addTag.id
    }

    @EnvironmentObject var personInfo: PersonInfo
    var currentTappedTagID: UUID

    var records: FetchedResults<Record>?

    var body: some View {
        Group {
            if currentTappedTagID == Tag.addTag.id {
                Form {
                    Section("待添加标签信息") {
                        HStack {
                            Text("标签标题：")
                            TextField("tagTitle", text: $tagTitle)
                        }

                        RoundedRectangle(cornerRadius: 5)
                            .fill(tagColor)

                        ColorPicker("选择标签颜色：", selection: $tagColor)
                    }
                    Section("按钮") {
                        Button("添加标签") {
                            let newTag = Tag(title: tagTitle, color: tagColor)
                            personInfo.add(newTag)
                            
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
            } else {
                Form {
                    Section("修改标签信息") {
                        TextField("tagTitle", text: $tagTitle)
                            .disabled(isSysTag)

                        RoundedRectangle(cornerRadius: 5)
                            .fill(tagColor)

                        ColorPicker("修改标签颜色：", selection: $tagColor)
                    }

                    Section("按钮") {
                        Button("保存") {
                            personInfo.editTag(tagID: currentTappedTagID, title: tagTitle, color: tagColor)

                            if viewContext.hasChanges {
                                print("ad")
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                            
                            print("asdsdasadlll")
                            print(personInfo.wrappedTags[3].title)
                            
                            dismiss()
                        }
                        Button("删除该标签", role: .destructive) {
                            self.showConfirmDelete = true
                        }
                        .disabled(isSysTag)
                    }
                }
            }
        }
        .alert("确定删除吗？\n目前该操作不可撤销。", isPresented: $showConfirmDelete, actions: {
            Button("删除", role: .destructive) {
                if personInfo.delete(currentTappedTagID) {
                    if let records = records {
                        for record in records {
                            if record.wrappedTagIDs.first == currentTappedTagID {
                                record.tagIDs?.removeLast()
                                record.tagIDs?.append(Tag.noneTag.id)
                            }
                        }
                    }

                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }

                dismiss()
            }
            Button("取消", role: .cancel) {}
        })
        .onAppear {
            let tag = personInfo.getTag(from: currentTappedTagID)
            tagTitle = tag.title
            tagColor = tag.color
            print(tag.title)
        }
        .navigationTitle(currentTappedTagID == Tag.addTag.id ? "添加标签" : "修改标签")
    }
}

//struct EditTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTagView()
//    }
//}
