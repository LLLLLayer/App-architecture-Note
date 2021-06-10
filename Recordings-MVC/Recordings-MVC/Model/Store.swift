//
//  Store.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/8.
//

// MARK: - 存储器 (Store)

import Foundation

final class Store {
    
    // 存储器存储信息改变时发送的通知
    static let changedNotification = Notification.Name("StoreChanged")
    
    // 文件存储根目录
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory,
                                                                        in: .userDomainMask,
                                                                        appropriateFor: nil,
                                                                        create: true)
    
    // 单例存储器
    static let shared = Store(url: documentDirectory)
    
    let baseURL: URL? // 初始化使用的 URL
    var placeholder: URL? // 默认空 URL，兜底使用
    private(set) var rootFolder: Folder // 根文件夹
    
    init(url: URL?) {
        baseURL = url
        placeholder = nil
        // 根文件夹初始化
        if let u = url,
           let data = try? Data(contentsOf: u.appendingPathComponent(.storeLocation)),
           let folder = try? JSONDecoder().decode(Folder.self, from: data) {
            rootFolder = folder
        } else {
            rootFolder = Folder.init(name: "", uuid: UUID())
        }
        rootFolder.store = self
    }
    
    // 获取录音文件 URL
    func fileURL(for recording: Recording) -> URL? {
        return baseURL?.appendingPathComponent(recording.uuid.uuidString + ".m4a") ?? placeholder
    }
    
    // 文件保存
    func save(_ notifying: Item, userInfo: [AnyHashable: Any]) {
        if let url = baseURL, let data = try? JSONEncoder().encode(rootFolder) {
            try! data.write(to: url.appendingPathComponent(.storeLocation))
        }
        NotificationCenter.default.post(name: Store.changedNotification, object: notifying, userInfo: userInfo)
    }
    
    func item(atUUIDPath path: [UUID]) -> Item? {
        return rootFolder.item(atUUIDPath: path[0...])
    }
    
    // 文件删除
    func removeFile(for recording: Recording) {
        if let url = fileURL(for: recording), url != placeholder {
            _ = try? FileManager.default.removeItem(at: url)
        }
    }
}

fileprivate extension String {
    static let storeLocation = "store.json"
}
