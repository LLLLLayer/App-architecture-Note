//
//  Folder.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/8.
//

// MARK: - Folder(文件夹) 类

import Foundation

class Folder: Item, Codable {
    
    // 当前文件夹包含的内容
    private(set) var contents: [Item]
    // 对应的存储器
    override weak var store: Store? {
        didSet {
            contents.forEach { $0.store = store }
        }
    }
    
    // 构造函数
    override init(name: String, uuid: UUID) {
        contents = []
        super.init(name: name, uuid: uuid)
    }
    
    // 编码与解码的特殊类型
    enum FolderKeys: CodingKey { case name, uuid, contents }
    enum FolderOrRecording: CodingKey { case folder, recording }
    
    // 解码
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: FolderKeys.self)
        contents = [Item]()
        var nester = try c.nestedUnkeyedContainer(forKey: .contents)
        while true {
            let wrapper = try nester.nestedContainer(keyedBy: FolderOrRecording.self)
            if let f = try wrapper.decodeIfPresent(Folder.self, forKey: .folder) {
                contents.append(f)
            } else if let r = try wrapper.decodeIfPresent(Recording.self, forKey: .recording) {
                contents.append(r)
            } else {
                break
            }
        }
        
        let name = try c.decode(String.self, forKey: .name)
        let uuid = try c.decode(UUID.self, forKey: .uuid)
        super.init(name: name, uuid: uuid)
        
        for c in contents {
            c.parent = self
        }
    }
    
    // 编码
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: FolderKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(uuid, forKey: .uuid)
        var nested = c.nestedUnkeyedContainer(forKey: .contents)
        for c in contents {
            var wrapper = nested.nestedContainer(keyedBy: FolderOrRecording.self)
            switch c {
            case let f as Folder:
                try wrapper.encode(f, forKey: .folder)
            case let r as Recording:
                try wrapper.encode(r, forKey: .recording)
            default:
                break
            }
        }
        // TODO 为什么在末尾加空容器？
        _ = nested.nestedContainer(keyedBy: FolderOrRecording.self)
    }
    
    // 添加新文件夹
    func add(_ item: Item) {
        assert(contents.contains(where: { $0 === item }) == false)
        contents.append(item)
        contents.sort(by: { $0.name < $1.name })
        let newIndex = contents.firstIndex(where: { $0 === item })!
        item.parent = self
        store?.save(item, userInfo: [Item.changeReasonKey: Item.added,
                                     Item.newValueKey: newIndex,
                                     Item.parentFolderKey: self])
    }
    
    // 重新排序，用于文件改名后
    func reSort(changedItem: Item) -> (oldIndex: Int, newIndex: Int) {
        let oldIndex = contents.firstIndex(where: { $0 === changedItem })!
        contents.sort(by: { $0.name < $1.name })
        let newIndex = contents.firstIndex(where: { $0 === changedItem })!
        return (oldIndex, newIndex)
    }
    
    // 删除文件夹
    func remove(_ item: Item) {
        guard let index = contents.firstIndex(where: { $0 === item }) else { return }
        item.deleted()
        contents.remove(at: index)
        store?.save(item, userInfo: [
            Item.changeReasonKey: Item.removed,
            Item.oldValueKey: index,
            Item.parentFolderKey: self
        ])
    }
    
    // 
    override func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
        guard path.count > 1 else { return super.item(atUUIDPath: path) }
        guard path.first == uuid else { return nil }
        let subsequent = path.dropFirst()
        guard let second = subsequent.first else { return nil }
        return contents.first { $0.uuid == second }.flatMap { $0.item(atUUIDPath: subsequent) }
    }
}
