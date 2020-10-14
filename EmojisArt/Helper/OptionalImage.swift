//
//  OptionalImage.swift
//  EmojisArt
//
//  Created by Bryce on 2020/10/12.
//

import SwiftUI

struct OptionalImage: View {
    var image: UIImage?
    var body: some View {
        Group {
            if let image = self.image {
                Image(uiImage: image)
            }
        }
    }
}
