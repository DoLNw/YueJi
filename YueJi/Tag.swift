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
    static let saveKey = "tags"
    @Published public var tags: [Tag]
    
    init() {
        tags = []
        
        if let data = UserDefaults.standard.data(forKey: Tags.saveKey) {
            if let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
                tags = decoded
            }
        } else {
            tags.append(Tag.noneTag)
            tags.append(Tag.allTag)
            tags.append(Tag(title: "日记", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "1", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标s签2", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签4", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签asdasdas5", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签6", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签asdasd7", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "标签68", color: Tag.tagColors.randomElement() ?? Color.black))
            tags.append(Tag(title: "添加", color: Tag.tagColors.randomElement() ?? Color.black))
            
            save()
        }
        
    }
    
    func editTag(index: Int, title: String, color: Color) {
        objectWillChange.send()
        tags[index].title = title
        tags[index].color = color
        
        save()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(tags) {
            if let decoded = try? JSONDecoder().decode([Tag].self, from: data) {
                print(decoded.description)
            }
            UserDefaults.standard.set(data, forKey: Tags.saveKey)
        }
    }
    
    func add(_ tag: Tag) {
        tags.append(tag)
        save()
    }
    func delete(_ tag: Tag) {
        if let index = tags.firstIndex(where: {$0.id == tag.id}) {
            tags.remove(at: index)
            save()
        }
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
    static let noneTag = Tag(title: "无", color: .indigo)
    static let allTag = Tag(title: "全部", color: .mint)
    
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
