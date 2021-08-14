//
//  MoviePosterView.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 13/08/2021.
//

import SwiftUI

struct MoviePosterView: View {
    
    let movie: Movie
    @ObservedObject var imageLoader = ImageLoader()

    var body: some View {
        ZStack {
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                
                Text(movie.title)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 204, height: 306)
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}
