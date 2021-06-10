//
//  Item.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/8.
//

import Foundation

// MARK: - Folder(文件夹)/Recording(录音) 基类 Item 类

class Item {
    
    private(set) var name: String
    let uuid: UUID
    
    // 存储器
    weak var store: Store?
    // 所属文件夹
    weak var parent: Folder? {
        didSet {
            store = parent?.store
        }
    }
    
    // 构造函数
    init(name: String, uuid: UUID) {
        self.name = name
        self.uuid = uuid
        self.store = nil
    }
    
    // 录音文件命名
    func setName(_ newName: String) {
        name = newName
        if let p = parent {
            let (oldIndex, newIndex) = p.reSort(changedItem: self)
            store?.save(self, userInfo: [Item.changeReasonKey: Item.renamed,
                                         Item.oldValueKey: oldIndex,
                                         Item.newValueKey: newIndex,
                                         Item.parentFolderKey: p])
        }
    }
    
    // 删除
    func deleted() {
        parent = nil
    }
    
    // 从根目录到当前文件 UUID 数组
    var uuidPath: [UUID] {
        var path = parent?.uuidPath ?? []
        path.append(uuid)
        return path
    }
    
    // 当前是否是首个 UUIDPath 对应的 Item
    func item(atUUIDPath path:ArraySlice<UUID>) -> Item? {
        guard let first = path.first, first == uuid else {
            return nil
        }
        return self
    }
}

extension Item {
    static let changeReasonKey = "reason"
    static let newValueKey = "newValue"
    static let oldValueKey = "oldValue"
    static let parentFolderKey = "parentFolder"
    static let renamed = "renamed"
    static let added = "added"
    static let removed = "removed"
}
