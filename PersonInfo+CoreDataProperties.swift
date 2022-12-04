//
//  PersonInfo+CoreDataProperties.swift
//  YueJi
//
//  Created by Jcwang on 2022/12/1.
//
//

import Foundation
import CoreData
import SwiftUI

extension PersonInfo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonInfo> {
        return NSFetchRequest<PersonInfo>(entityName: "PersonInfo")
    }

    @NSManaged public var accumulateDays: Int64
//    @NSManaged public var myTag: MyTag?
    @NSManaged public var tags: [Tag]?
    @NSManaged public var createDate: Date?
    
    public var wrappedCreateDate: Date {
        print("asdsaasdsadsa")
        print(createDate ?? Date.now)
        
        return createDate ?? Date.now
    }
    
    public var wrappedTags: [Tag] {
        var tags = [Tag]()

        if let tempTags = self.tags {
            // 如果存在，为了让其他static Tag的id一样，只能赋值
            Tag.noneTag = tempTags[0]
            Tag.allTag = tempTags[1]
            Tag.journalTag = tempTags[2]
            Tag.addTag = tempTags.last!

            return tempTags
        }


//        tags.append(Tag.noneTag)
//        tags.append(Tag.allTag)
//        tags.append(Tag.journalTag)
//        tags.append(Tag(title: "标签1", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签2", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签3", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签4", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签5", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag.addTag)
//
//        // 保存
//        save()

        return tags
    }
    
//    public var wrappedTags: [Tag] {
//        var tags = [Tag]()
//
//        if let tempTags = self.myTag?.tags {
//            // 如果存在，为了让其他static Tag的id一样，只能赋值
//            Tag.noneTag = tempTags[0]
//            Tag.allTag = tempTags[1]
//            Tag.journalTag = tempTags[2]
//            Tag.addTag = tempTags.last!
//
//            return tempTags
//        }
//
//
//        tags.append(Tag.noneTag)
//        tags.append(Tag.allTag)
//        tags.append(Tag.journalTag)
//        tags.append(Tag(title: "标签1", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签2", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签3", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签4", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag(title: "标签5", color: Tag.tagColors.randomElement() ?? Color.black))
//        tags.append(Tag.addTag)
//
//        // 保存
//
//        save()
//
//        return tags
//    }
    
    func getTag(from id: UUID) -> Tag {
        if let tag = wrappedTags.first(where: { $0.id == id }) {
            return tag
        }
            
        return Tag.noneTag
    }
    
    func editTag(tagID: UUID, title: String, color: Color) {
        if let index = wrappedTags.firstIndex(where: { $0.id == tagID }) {
            objectWillChange.send()
            tags?[index].title = title
            tags?[index].color = color
            
            save()
        }
    }
    
    func save() {
//        if let data = try? JSONEncoder().encode(tags) {
//            if let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
//                print(decoded.description)
//            }
//            UserDefaults.standard.set(data, forKey: StaticProperties.USERDEFAULTS_TAGS)
//        }
        
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
    }
    
    func add(_ tag: Tag) {
        tags?.insert(tag, at: wrappedTags.count - 1)
//        tags.append(tag)
        save()
    }
    func delete(_ tagID: UUID) -> Bool {
        if let index = wrappedTags.firstIndex(where: {$0.id == tagID}) {
            tags?.remove(at: index)
            save()
            
            return true
        }
        
        return false
    }
}

extension PersonInfo : Identifiable {

}
