//
//  MoviePosterScrollView.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 13/08/2021.
//

import SwiftUI

struct MoviePosterScrollView: View {
    
    let title: String
    let movies: [Movie]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(movies, id: \.self.id) { movie in
                        MoviePosterView(movie: movie)
                    }
                }
            }
        }
    }
}
