//
//  Record+CoreDataProperties.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/10.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var modifiedDate: Date?
    @NSManaged public var tags: [Tag]?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var wordCount: Int64
    
    public var wrappedCreateDate: Date {
        createDate ?? Date()
    }
    public var wrappedModifiedDate: Date {
        modifiedDate ?? Date()
    }
    public var wrappedTags: [Tag] {
        tags ?? [Tag.noneTag]
    }
    public var wrappedText: String {
        text ?? "None text"
    }
    public var wrappedTitle: String {
        title ?? "No Title"
    }
}

extension Record : Identifiable {

}
