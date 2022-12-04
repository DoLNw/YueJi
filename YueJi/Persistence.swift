//
//  Persistence.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/6.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var previewExample: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0 ..< 20 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0 ..< 20 {
            let newRecord = Record(context: viewContext)
            newRecord.createDate = Date()
            newRecord.modifiedDate = Date()
            newRecord.text = ""
            newRecord.title = Date.now.formatted(date: .long, time: .shortened)
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        ValueTransformer.setValueTransformer(TagAttributeTransformer(), forName: NSValueTransformerName("TagAttributeTransformer"))
        
        container = NSPersistentCloudKitContainer(name: "YueJi")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // 有改变，@Fetchrequest会将数据实时反应
        container.viewContext.automaticallyMergesChangesFromParent = true
        // 逐属性比较，如果持久化数据和内存数据都改变且冲突，内存数据胜出
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        do {
              try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
             fatalError("Failed to pin viewContext to the current generation:\(error)")
        }
    }
}
