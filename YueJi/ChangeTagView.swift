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
    @State private var currentTagID: UUID = Tag.noneTag.id
    var record: Record
    
    let selectedChangeGemerator = UISelectionFeedbackGenerator()
    
    var body: some View {
        VStack(spacing: 5) {
            List {
                Section("改变为以下标签：") {
                    ForEach(myTag.tags) { tag in
                        HStack {
                            Image(systemName: "tag")
                            
                            if tag.id == currentTagID {
                                Text("\(tag.title)")
                                    .font(.title3)
                                    .padding([.top, .bottom], 10)
                                    .background(tag.color)
                                    .cornerRadius(15)
                                    .shadow(color: .primary.opacity(0.5), radius: 7)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 3)
                                    )
                            } else {
                                Text("\(tag.title)")
                                    .font(.title3)
                                    .padding([.top, .bottom], 10)
                                    .background(tag.color)
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        selectedChangeGemerator.selectionChanged()
                                        self.currentTagID = tag.id
                                    }
                            }
                        }
                    }
                }
            }
            .listStyle(.grouped)
            
            HStack {
                let preTag = myTag.getTag(from: record.wrappedTagIDs.first!)
                let currentTag = myTag.getTag(from: currentTagID)
                
                Text("\(preTag.title)")
                    .font(.title3)
                    .padding([.top, .bottom], 10)
                    .background(preTag.color)
                    .cornerRadius(15)
                    .padding()
                
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
                        Text("确定转换")
                    }
                
                Spacer()
                
                Text("\(currentTag.title)")
                    .font(.title3)
                    .padding([.top, .bottom], 10)
                    .background(currentTag.color)
                    .cornerRadius(15)
                    .padding()
            }
        }
        
        .onAppear {
            currentTagID = record.wrappedTagIDs.first ?? Tag.noneTag.id
        }
    }
}

//struct ChangeTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeTagView()
//    }
//}
