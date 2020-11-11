//
//  EmojiArtDocumentChooser.swift
//  Memories
//
//  Created by Bryce on 2020/11/10.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtsView(document: document).navigationBarTitle(store.name(for: document), displayMode: .inline)) {
                        EditableText(store.name(for: document), isEditing: editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
    
                }.onDelete { indexSet in
                    indexSet.map{ store.documents[$0]}.forEach { store.removeDocument($0) }
                }
            }
            .navigationBarTitle(store.name)
            .navigationBarItems(leading: Button(action: {
                store.addDocument()
            }, label: {
                Image.init(systemName: "plus").imageScale(.large)
            }), trailing: EditButton())
            .environment(\.editMode, $editMode)
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
