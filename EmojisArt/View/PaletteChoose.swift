//
//  PaletteChoose.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/19.
//

import SwiftUI

struct PaletteChoose: View {
    @ObservedObject var emojiArtDocument: EmojiArtDocument
    @Binding var choosenPalette: String
    
    @State var popoverShowing: Bool = false
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                choosenPalette = emojiArtDocument.palette(after: choosenPalette)
            }, onDecrement: {
                choosenPalette = emojiArtDocument.palette(before: choosenPalette)
            }, label: { EmptyView() })
            Text(self.emojiArtDocument.paletteNames[self.choosenPalette] ?? "")
            Image.init(systemName: "keyboard.chevron.compact.down")
                .imageScale(.large)
                .onTapGesture {
                    popoverShowing = true
                }
                .sheet(isPresented: $popoverShowing) {
                    PaletteEditor(chosenPalette: $choosenPalette, popoverShowing: $popoverShowing)
                        .frame(minWidth:300, minHeight: 500)
                }
        }
        .environmentObject(emojiArtDocument)
        .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
        .onAppear(perform: {
            self.choosenPalette = emojiArtDocument.defaultPalette
        })
    }
}

struct PaletteEditor: View {
    
    @EnvironmentObject var emojiArtDocument: EmojiArtDocument
    @Binding var chosenPalette: String
    
    @Binding var popoverShowing: Bool
    
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button {
                        popoverShowing = false
                    } label: {  Text("Done") }.padding()

                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            emojiArtDocument.renamePalette(chosenPalette, to: paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            chosenPalette = emojiArtDocument.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
                
                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = emojiArtDocument.removeEmoji(emoji, fromPalette: self.chosenPalette)
                        }
                    }
                    .frame(height: self.height)
                }
            }
            Spacer()
        }.onAppear {
            paletteName = emojiArtDocument.paletteNames[chosenPalette] ?? ""
        }
    }
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    let fontSize: CGFloat = 40
}

struct PaletteChoose_Previews: PreviewProvider {
    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
        PaletteChoose(emojiArtDocument: EmojiArtDocument(), choosenPalette: Binding.constant(""))
    }
}
