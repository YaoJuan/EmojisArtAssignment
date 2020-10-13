//
//  EmojiArtDocument.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/12.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    static let palette: String = "⭐️⛈🍎🌏🥨⚾️"
    
    static let emojiArtCacheKey = "EmojiArtDocument.emojiArtCacheKey"
    @Published private var emojiArt: EmojiArt {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                UserDefaults.standard.set(self.emojiArt.json, forKey: Self.emojiArtCacheKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.emojiArtCacheKey)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    @Published fileprivate(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK: - Intent(s)
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt = EmojiArt()
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        print(scale)
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }

}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(size) }
    
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
