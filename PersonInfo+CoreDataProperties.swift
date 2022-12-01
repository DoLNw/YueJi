//
//  PersonInfo+CoreDataProperties.swift
//  YueJi
//
//  Created by Jcwang on 2022/12/1.
//
//

import Foundation
import CoreData


extension PersonInfo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonInfo> {
        return NSFetchRequest<PersonInfo>(entityName: "PersonInfo")
    }

    @NSManaged public var accumulateDays: Int64

}

extension PersonInfo : Identifiable {

}
