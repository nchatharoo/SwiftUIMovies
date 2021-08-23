//
//  MovieDetailListView.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 23/08/2021.
//

import SwiftUI

struct MovieDetailListView: View {
    
    let movie: Movie
    @State private var selectedTrailer: MovieVideo?
    let imageLoader = ImageLoader()
    
    var body: some View {
        
        VStack {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                MovieDetailImage(imageLoader: imageLoader, imageURL: movie.backdropURL)
                
                GeometryReader { moviePoster in
                    MovieCardView(movie: movie)
                        .position(x: moviePoster.size.width / 5, y: moviePoster.size.height / 4)
                }
                .padding(.bottom)
                
                GeometryReader { text in
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(movie.genreText)
                            .font(.footnote)
                            .foregroundColor(Color.gray.opacity(0.8))
                        
                        Text(movie.releaseDate ?? "-")
                            .font(.footnote)
                            .foregroundColor(Color.gray.opacity(0.8))
                        
                        Text(movie.durationText)
                            .font(.footnote)
                            .foregroundColor(Color.gray.opacity(0.8))
                    }
                    .position(x: text.size.width - 90, y: 0)
                }
                .padding(.bottom, 50)
                
                HStack {
                    if !movie.ratingText.isEmpty {
                        Text(movie.ratingText).foregroundColor(.yellow)
                    }
                    Text(movie.scoreText)
                }
                .padding([.top, .leading, .trailing])
                
                VStack(alignment: .leading) {
                    Text("Overview")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(movie.overview)
                }
                .padding([.top, .leading, .trailing])
                
                HStack(alignment: .top, spacing: 4) {
                    if movie.cast != nil && movie.cast!.count > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Starring")
                                .font(.title)
                                .fontWeight(.semibold)
                            
                            ForEach(self.movie.cast!.prefix(9), id: \.self.id) { cast in
                                Text(cast.name)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .leading, .trailing])
                    }
                    
                    if movie.crew != nil && movie.crew!.count > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            if movie.directors != nil && movie.directors!.count > 0 {
                                Text("Director(s)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                
                                ForEach(self.movie.directors!.prefix(2), id: \.self.id) { crew in
                                    Text(crew.name)
                                }
                            }
                            
                            if movie.producers != nil && movie.producers!.count > 0 {
                                Text("Producer(s)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    
                                    .padding(.top)
                                ForEach(self.movie.producers!.prefix(2), id: \.self.id) { crew in
                                    Text(crew.name)
                                }
                            }
                            
                            if movie.screenWriters != nil && movie.screenWriters!.count > 0 {
                                Text("Screenwriter(s)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    
                                    .padding(.top)
                                ForEach(self.movie.screenWriters!.prefix(2), id: \.self.id) { crew in
                                    Text(crew.name)
                                }
                            }
                        }
                        .padding([.top, .trailing])
                    }
                }
                
                if movie.youtubeTrailers != nil && movie.youtubeTrailers!.count > 0 {
                    VStack(alignment: .leading) {
                        Text("Trailers")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            
                            .padding([.top, .leading, .trailing])
                        
                        ForEach(movie.youtubeTrailers!, id: \.self.id) { trailer in
                            Button(action: {
                                self.selectedTrailer = trailer
                            }) {
                                HStack {
                                    Text(trailer.name)
                                    Spacer()
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(Color(UIColor.systemBlue))
                                }
                                .padding([.leading, .trailing])
                            }
                            .padding([.top, .bottom], 4)
                        }
                    }
                }
            }
            .sheet(item: self.$selectedTrailer) { trailer in
                SafariView(url: trailer.youtubeURL!)
            }
        }
        .cornerRadius(25)
    }
}

struct MovieCardView: View {
    
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
                    .fill(Color.gray.opacity(0.8))
                    .cornerRadius(8)
            }
        }
        .frame(width: 100, height: 170)
        .aspectRatio(1, contentMode: .fit)
        .shadow(radius: 8)
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}



struct MovieDetailListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailListView(movie: Movie.stubbedMovies[6])
    }
}
