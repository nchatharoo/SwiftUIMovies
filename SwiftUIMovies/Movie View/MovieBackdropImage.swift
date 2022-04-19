//
//  MovieDetailImage.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 23/08/2021.
//

import SwiftUI

struct MovieBackdropImage: View {
    
    let imageURL: URL
    
    var body: some View {
        ZStack {
            AsyncImage(url: imageURL) { image in
                image.resizable()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
}
