//
//  EditTagView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/10.
//

import SwiftUI

struct EditTagView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var tagTitle = ""
    @State private var tagColor = Color.white
    
    @ObservedObject var myTag: Tags
    var currentTappedTagID: UUID
    
    var records: FetchedResults<Record>?
    
    var body: some View {
        Group {
            if currentTappedTagID == Tag.addTag.id {
                Form {
                    Section("待添加标签信息") {
                        HStack {
                            Text("标签标题")
                            TextField("tagTitle", text: $tagTitle)
                        }
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(tagColor)
                        
                        ColorPicker("颜色拾取器", selection: $tagColor)
                    }
                    Section("按钮") {
                        Button("添加标签") {
                            let newTag = Tag(title: tagTitle, color: tagColor)
                            myTag.add(newTag)
                            
                            dismiss()
                        }
                    }
                }
            } else {
                Form {
                    Section("修改标签信息") {
                        TextField("tagTitle", text: $tagTitle)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(tagColor)
                        
                        ColorPicker("颜色拾取器", selection: $tagColor)
                    }
                    
                    Section("按钮") {
                        Button("保存") {
                            myTag.editTag(tagID: currentTappedTagID, title: tagTitle, color: tagColor)
                            
                            dismiss()
                        }
                        Button("删除该标签", role: .destructive) {
                            if myTag.delete(currentTappedTagID) {
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
                        .disabled(currentTappedTagID == Tag.noneTag.id || currentTappedTagID == Tag.allTag.id || currentTappedTagID == Tag.journalTag.id || currentTappedTagID == Tag.addTag.id)
                    }
                }
            }
        }
        .onAppear {
            let tag = myTag.getTag(from: currentTappedTagID)
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
