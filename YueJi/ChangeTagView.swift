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
    
    let selectedChangeGemerator = UISelectionFeedbackGenerator()
    
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
    @State private var preTagColor: Color = .black
    @State private var preTagTitle = ""
    @State private var sysImageName = "arrowshape.turn.up.forward"
    var record: Record
    
    init(refreshID: Binding<Bool>, myTag: Tags, record: Record) {
        self._refreshID = refreshID
        self.myTag = myTag
        self.record = record
    }
    
    var body: some View {
        VStack(spacing: 5) {
            List {
                Section("更改为以下标签：") {
                    ForEach(filteredTags) { tag in
                        HStack {
                            Image(systemName: "tag")
                            
                            if tag.id == currentTagID {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(tag.color)
                                        .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
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
                let currentTag = myTag.getTag(from: currentTagID)
                
                Text("\(preTagTitle)")
                    .padding()
                    .font(.title3)
                    .background(preTagColor)
                    .cornerRadius(15)
                    .padding([.leading], 30)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
                
                Spacer()
                VStack {
                    Button {
                        record.tagIDs = [currentTagID]
                        refreshID.toggle()
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        
                        selectedChangeGemerator.selectionChanged()
                        
                        withAnimation {
                            self.preTagTitle = currentTag.title
                            self.preTagColor = currentTag.color
                            self.sysImageName = "checkmark.circle"
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            selectedChangeGemerator.selectionChanged()
                            dismiss()
                        }
                    } label: {
                        Label("", systemImage: sysImageName)
                            .font(.largeTitle)
                    }
                    .disabled(currentTagID == record.wrappedTagIDs.first)
                    
                    if self.sysImageName != "arrowshape.turn.up.forward" {
                        Text("更改成功")
                            .foregroundColor(currentTag.color)
                    }
                }
                
                
                Spacer()
                
                Text("\(currentTag.title)")
                    .font(.title3)
                    .padding()
                    .background(currentTag.color)
                    .cornerRadius(15)
                    .padding([.trailing], 30)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 3, y: 3)
            }
            
        }
        
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableView.appearance().tableFooterView = UIView()
            
            self.currentTagID = record.wrappedTagIDs.first ?? Tag.noneTag.id
            
            let tag = myTag.getTag(from: record.wrappedTagIDs.first!)
            self.preTagColor = tag.color
            self.preTagTitle = tag.title
        }
    }
}

//struct ChangeTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeTagView()
//    }
//}
