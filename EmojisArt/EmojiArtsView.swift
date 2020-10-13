//
//  EmojiArtsView.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/12.
//

import SwiftUI

struct EmojiArtsView: View {
    @ObservedObject var emojiArtDocument: EmojiArtDocument = EmojiArtDocument()
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { element in
                        Text(element).onDrag { NSItemProvider(object: element as NSString) }
                    }
                }
                .font(Font.system(size: defaultEmojiSize))
                .padding(.horizontal)

            }
            GeometryReader { geometry in
                ZStack {
                    Color.orange.overlay(
                        OptionalImage(image: emojiArtDocument.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                            
                    ).gesture(doubleClickGesture(in: geometry.size))
                    .gesture(panGesture())
                    .gesture(zoomScaleGesture())
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                        
                        var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                        location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                        return self.drop(providers: providers, at: location)
                    }
                    ForEach(emojiArtDocument.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * zoomScale)
                            .position(position(for: emoji, in: geometry.size))
//                            .gesture(self.emojiPanGesture(move: emoji))
//                            .gesture(self.gestureToZoom(emoji))
                    }
                }
            }
           
            .clipped()
            .edgesIgnoringSafeArea([.horizontal, .bottom])
        }
    }
    
    //MARK: -- Gesture(s)
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    
    private func doubleClickGesture(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation {
                zoomToFit(self.emojiArtDocument.backgroundImage, in: size)
            }
        }
    }
    
    private func zoomScaleGesture() -> some Gesture {
        MagnificationGesture().updating($gestureZoomScale) { lastZoomScale, gestureZoomScale, transcation in
            gestureZoomScale = lastZoomScale
        }.onEnded { endZoomScale in
            steadyStateZoomScale *= endZoomScale
        }
    }
    
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }

    private func panGesture() -> some Gesture {
        DragGesture().updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transition in
            gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }.onEnded { finalDrapGestureValue in
            self.steadyStatePanOffset = self.steadyStatePanOffset + finalDrapGestureValue.translation / self.zoomScale
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
            steadyStatePanOffset = CGSize.zero
        }
    }

    @GestureState private var emojiGesturePanOffset: CGSize = .zero
    private func emojiPanGesture(move emoji: EmojiArt.Emoji) -> some Gesture {
        DragGesture().updating($emojiGesturePanOffset) { lastDragGestureValue, emojiGesturePanOffset, transcation in
            self.emojiArtDocument.moveEmoji(emoji, by: lastDragGestureValue.translation - self .emojiGesturePanOffset)
            emojiGesturePanOffset = lastDragGestureValue.translation
        }
    }
    
    @GestureState private var emojiGestureZoomScale: CGFloat = 1
    private func gestureToZoom(_ emoji: EmojiArt.Emoji) -> some Gesture {
        MagnificationGesture().updating($emojiGestureZoomScale) { lastZoomScale, emojiGestureZoomScale, transcation in
            emojiArtDocument.scaleEmoji(emoji, by: lastZoomScale)
        }.onEnded { value in
            
        }
    }
    
    //MARK: -- Intent(s)
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: emoji.location.x * zoomScale + size.width * 0.5 + panOffset.width, y: emoji.location.y * zoomScale + size.height * 0.5 + panOffset.height)
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.emojiArtDocument.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.emojiArtDocument.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
