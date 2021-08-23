//
//  MovieDetailView.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 23/08/2021.
//

import SwiftUI

struct MovieDetailView: View {
    
    let movieId: Int
    @ObservedObject private var movieDetailObservable = MovieDetailObservable(remoteLoader: RemoteMovieLoader(endpoint: .nowPlaying, client: URLSessionHTTPClient()))
    
    var body: some View {
        ZStack {
            
            if movieDetailObservable.movie != nil {
                MovieDetailListView(movie: self.movieDetailObservable.movie!)
            }
        }
        .navigationBarTitle(movieDetailObservable.movie?.title ?? "")
        .onAppear {
            self.movieDetailObservable.loadMovie(id: self.movieId)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movieId: Movie.stubbedMovie.id)
    }
}
