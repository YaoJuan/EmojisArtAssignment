//
//  EmojiArtsView.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/12.
//

import SwiftUI

struct EmojiArtsView: View {
    @ObservedObject var emojiArtDocument: EmojiArtDocument = EmojiArtDocument()
    
    @State var choosenPalette: String = ""
    init(document: EmojiArtDocument) {
        self.emojiArtDocument = document
        _choosenPalette = State(wrappedValue: self.emojiArtDocument.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChoose(emojiArtDocument: emojiArtDocument, choosenPalette: $choosenPalette)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(choosenPalette.map { String($0) }, id: \.self) { element in
                            Text(element).onDrag { NSItemProvider(object: element as NSString) }
                        }
                    }
                    .font(Font.system(size: defaultEmojiSize))
                    

                }.layoutPriority(1)
            }.padding(2)

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
                        location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                        location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                        return self.drop(providers: providers, at: location)
                    }
                    .onReceive(self.emojiArtDocument.$backgroundImage) { image in
                        zoomToFit(image, in: geometry.size)
                    }.navigationBarItems(trailing: Button(action: {
                        if let url = UIPasteboard.general.url, url != self.emojiArtDocument.backgroundURL {
                            self.confirmBackgroundPaste = true
                        } else {
                            self.explainBackgroundPaste = true
                        }
                    }, label: {
                        Image(systemName: "doc.on.clipboard").imageScale(.large)
                            .alert(isPresented: self.$explainBackgroundPaste) {
                                return Alert(
                                    title: Text("Paste Background"),
                                    message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                    }))
                    
                    if emojiArtDocument.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(emojiArtDocument.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(position(for: emoji, in: geometry.size))
                                .gesture(self.emojiPanGesture(move: emoji))
                        }
                    }
                    

                }
            }.zIndex(-1)
            .alert(isPresented: $confirmBackgroundPaste, content: { () -> Alert in
                Alert(title: Text("Paste Background"),
                      message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                      primaryButton: .default(Text("OK")) {
                    self.emojiArtDocument.backgroundURL = UIPasteboard.general.url
                }, secondaryButton: .cancel())
            })
           
            .clipped()
            .edgesIgnoringSafeArea([.horizontal, .bottom])
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
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
            self.emojiArtDocument.moveEmoji(emoji, by: (lastDragGestureValue.translation - self .emojiGesturePanOffset) / zoomScale)
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
            self.emojiArtDocument.backgroundURL = url
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
