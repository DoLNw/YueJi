//
//  ChangeTagView.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/20.
//

import SwiftUI

struct ChangeTagView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    // 为了能让record改变后，更新
    @Binding var refreshID: Bool
    
    @ObservedObject var myTag: Tags
    private var filteredTags: [Tag] {
        var tags = [Tag]()
        
//        let recordTagID = record.tagIDs?.first
        for tag in myTag.tags {
//            if !(tag.id == recordTagID || tag.id == Tag.noneTag.id || tag.id == Tag.allTag.id || Tag.addTag.id == tag.id) {
//                tags.append(tag)
//            }
            if !(tag.id == Tag.noneTag.id || tag.id == Tag.allTag.id || Tag.addTag.id == tag.id) {
                tags.append(tag)
            }
        }
        
        return tags
    }
    
    @State private var currentTagID: UUID = Tag.noneTag.id
    var record: Record
    
    let selectedChangeGemerator = UISelectionFeedbackGenerator()
    
    var body: some View {
        
        
        return VStack(spacing: 5) {
            List {
                Section("改变为以下标签：") {
                    ForEach(filteredTags) { tag in
                        HStack {
                            Image(systemName: "tag")
                            
                            if tag.id == currentTagID {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(tag.color)
                                        .shadow(color: .secondary, radius: 7, x: 3, y: 3)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.blue, lineWidth: 3)
                                        )
                                    Text("\(tag.title)")
                                        .font(.title3)
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(tag.color)
                                        .onTapGesture {
                                            selectedChangeGemerator.selectionChanged()
                                            self.currentTagID = tag.id
                                        }
                                    Text("\(tag.title)")
                                        .font(.title3)
                                }
                            }
                        }
                        .padding()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .background(.clear)
            .listStyle(.grouped)
            
            HStack(alignment: .center) {
                let preTag = myTag.getTag(from: record.wrappedTagIDs.first!)
                let currentTag = myTag.getTag(from: currentTagID)
                
                Text("\(preTag.title)")
                    .padding()
                    .font(.title3)
                    .background(preTag.color)
                    .cornerRadius(15)
                    .padding([.leading], 30)
                    .shadow(color: .secondary, radius: 7, x: 3, y: 3)
                
                Spacer()
                    Button {
                        record.tagIDs = [currentTagID]
                        refreshID.toggle()
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        
                        dismiss()
                    } label: {
                        Text("确定转换为")
                    }
                    .disabled(currentTagID == record.wrappedTagIDs.first)
                
                Spacer()
                
                Text("\(currentTag.title)")
                    .font(.title3)
                    .padding()
                    .background(currentTag.color)
                    .cornerRadius(15)
                    .padding([.trailing], 30)
                    .shadow(color: .secondary, radius: 7, x: 3, y: 3)
            }
            
        }
        
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableView.appearance().tableFooterView = UIView()
            
            currentTagID = record.wrappedTagIDs.first ?? Tag.noneTag.id
        }
    }
}

//struct ChangeTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeTagView()
//    }
//}
