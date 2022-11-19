//
//  EditTagView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/10.
//

import SwiftUI

struct EditTagView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var tagTitle = ""
    @State private var tagColor = Color.white
    
    @ObservedObject var myTag: Tags
    var currentTappedTagID: String
    
    var body: some View {
        Group {
            if currentTappedTagID == Tag.addTag.id.description {
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
                            if let index = myTag.tags.firstIndex(where: { $0.id.description == currentTappedTagID }) {
                                myTag.editTag(index: index, title: tagTitle, color: tagColor)
                            }
                            
                            dismiss()
                        }
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
        .navigationTitle(currentTappedTagID == Tag.addTag.id.description ? "添加标签" : "修改标签")
    }
}

//struct EditTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTagView()
//    }
//}
