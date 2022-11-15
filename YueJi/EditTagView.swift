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
    var currentTappedTag: Tag
    
    var body: some View {
        Form {
            Section("修改标签信息") {
                TextField("tagTitle", text: $tagTitle)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(tagColor)
            }
            
            Section("按钮") {
                Button("保存") {
                    if let index = myTag.tags.firstIndex(where: { $0.title == currentTappedTag.title }) {
                        myTag.editTag(index: index, title: tagTitle, color: tagColor)
                    }
                    
                    dismiss()
                }
            }
        }
        .onAppear {
            tagTitle = currentTappedTag.title
            tagColor = currentTappedTag.color
            print(currentTappedTag.title)
        }
        .navigationTitle("修改标签")
    }
}

//struct EditTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditTagView()
//    }
//}
