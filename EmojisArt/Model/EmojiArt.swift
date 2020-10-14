//
//  EmojiArt.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/12.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let decodeData = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = decodeData
        } else {
            return nil
        }

    }
    
    init() { }
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(_ text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    
}
