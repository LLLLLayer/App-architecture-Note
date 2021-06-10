//
//  Recording.swift
//  Recordings-MVC
//
//  Created by 杨杰 on 2021/6/8.
//

// MARK: - Recording(录音) 类

import UIKit

class Recording: Item, Codable {
    
    // 构造函数
    override init(name: String, uuid: UUID) {
        super.init(name: name, uuid: uuid)
    }
    
    // 编码与解码
    enum RecordingKeys: CodingKey { case name, uuid }
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: RecordingKeys.self)
        let name = try c.decode(String.self, forKey: .name)
        let uuid = try c.decode(UUID.self, forKey: .uuid)
        super.init(name: name, uuid: uuid)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: RecordingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(uuid, forKey: .uuid)
    }
    
    // 录音文件地址
    var fileURL: URL? {
        return store?.fileURL(for: self)
    }
    
    // 删除
    override func deleted() {
        store?.removeFile(for: self)
        super.deleted()
    }
}
