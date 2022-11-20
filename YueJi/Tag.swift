//
//  Tag.swift
//  YueJi
//
//  Created by Jcwang on 2022/11/7.
//

import Foundation
import SwiftUI

// 给UserDefaults存储的
public class Tags: ObservableObject {
    @Published public var tags: [Tag]
    
    init() {
        tags = []
        
        if let data = UserDefaults.standard.data(forKey: StaticProperties.USERDEFAULTS_TAGS) {
            if let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
                tags = decoded
                
                // 如果存在，为了让其他static Tag的id一样，只能赋值
                Tag.noneTag = tags[0]
                Tag.allTag = tags[1]
                Tag.journalTag = tags[2]
                Tag.addTag = tags.last!
            }
        } else {
            tags.append(Tag.noneTag)
            tags.append(Tag.allTag)
            tags.append(Tag.journalTag)
            tags.append(Tag(title: "标签1", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签2", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签3", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签4", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签5", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag.addTag)
            
            save()
        }
    }
    
    func getTag(from id: UUID) -> Tag {
        if let tag = tags.first(where: { $0.id == id }) {
            return tag
        }
            
        return Tag.noneTag
    }
    
    func editTag(tagID: UUID, title: String, color: Color) {
        if let index = tags.firstIndex(where: { $0.id == tagID }) {
            objectWillChange.send()
            tags[index].title = title
            tags[index].color = color
            
            save()
        }
        
        
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(tags) {
            if let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
                print(decoded.description)
            }
            UserDefaults.standard.set(data, forKey: StaticProperties.USERDEFAULTS_TAGS)
        }
    }
    
    func add(_ tag: Tag) {
        tags.insert(tag, at: tags.count - 1)
//        tags.append(tag)
        save()
    }
    func delete(_ tagID: UUID) -> Bool {
        if let index = tags.firstIndex(where: {$0.id == tagID}) {
            tags.remove(at: index)
            save()
            
            return true
        }
        
        return false
    }
}

// CoreData和UserDefault都用的
public class Tag: NSObject, Identifiable, Codable, NSSecureCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "mtitle")
        coder.encode(id.description, forKey: "UUID")
        coder.encode(color.uiColor(), forKey: "color")
    }
    
    public required convenience init?(coder: NSCoder) {
        let mid = coder.decodeObject(of: NSString.self, forKey: "UUID") as? String
        let mTitle = coder.decodeObject(of: NSString.self, forKey: "mtitle") as String?
        let mColor = coder.decodeObject(of: UIColor.self, forKey: "color")
        
        self.init(id: UUID(uuidString: mid!)!, title: mTitle!, color: Color(uiColor: mColor!))
    }
    
    public static var supportsSecureCoding: Bool = true
    
    static let tagColors = [Color.yellow, .blue, .indigo, .cyan, .mint, .teal, .pink, .purple, .orange, .brown]
    static var noneTag = Tag(title: "未归类", color: .indigo)
    static var allTag = Tag(title: "全部", color: .mint)
    static var addTag = Tag(title: "添加", color: .accentColor)
    static var journalTag = Tag(title: "日记", color: .orange)
    
    public var id = UUID()
    public var title: String
    public var color: Color
    
    init(id: UUID, title: String, color: Color) {
        self.id = id
        self.title = title
        self.color = color
    }
    
    init(title: String, color: Color) {
        self.title = title
        self.color = color
    }
    
    enum CodingKeys: CodingKey {
        case id, title, color
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(color, forKey: .color)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        color = try container.decode(Color.self, forKey: .color)
    }
}


// 为了能让CoreData能够自己解析编码[Tag]，首先上面的Tag需要先conform to：NSSexureCoding和NSObject
class TagAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [Tag.self]
    }
    
    static func register() {
        let className = String(describing: TagAttributeTransformer.self)
        let name = NSValueTransformerName(className)
        let transformer = TagAttributeTransformer()
        
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

//struct DatePickerExample: View {
//    @State private var date = Date()
//    let dateRange: ClosedRange<Date> = {
//        let calendar = Calendar.current
//        let startComponents = DateComponents(year: 2021, month: 12, day: 15)
//        let endComponents = DateComponents(year: 2021, month: 12, day: 30, hour: 23, minute: 59, second: 59)
//        return calendar.date(from:startComponents)! ... calendar.date(from:endComponents)! }()
//    var body: some View {
//        DatePicker( "Pick a date", selection: $date, in: dateRange, displayedComponents: [.date]) .padding()
//
//    }
//}
