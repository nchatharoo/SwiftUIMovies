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
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                LazyHStack {
                    
                    ForEach(movies, id: \.self.id) { movie in
                        
                        NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                            
                            VStack(alignment: .leading) {
                                
                                MoviePosterView(movie: movie)
                                
                                Text(movie.title).lineLimit(1)
                                    .foregroundColor(.primary)
                                    .frame(width: 204, alignment: .leading)
                                
                                HStack {
                                    if !movie.ratingText.isEmpty {
                                        Text(movie.ratingText).foregroundColor(Color("StarsColor"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MoviePosterScrollView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterScrollView(title: "Now playing", movies: Movie.stubbedMovies)
    }
}
