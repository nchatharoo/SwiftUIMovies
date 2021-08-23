//
//  MovieListView.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 09/08/2021.
//

import SwiftUI

struct MovieListView: View {
    
    @ObservedObject var nowPlaying: MovieListObservable
    @ObservedObject var upcoming: MovieListObservable
    @ObservedObject var topRated: MovieListObservable
    @ObservedObject var popular: MovieListObservable

    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Now Playing", movies: nowPlaying.movies)
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Upcoming", movies: upcoming.movies)
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Top Rated", movies: topRated.movies)
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Popular", movies: popular.movies)
                    }
                }
                .padding()
            }
            .navigationBarTitle("The MovieDb")
        }
        .onAppear {
            nowPlaying.loadMovies(from: .nowPlaying)
            upcoming.loadMovies(from: .upcoming)
            topRated.loadMovies(from: .topRated)
            popular.loadMovies(from: .popular)
        }
    }
}

struct MovieListView_Previews: PreviewProvider {
    static private var nowPlaying = MovieListObservable(remoteLoader: RemoteMovieLoader(endpoint: .nowPlaying,
                                                                                                 client: URLSessionHTTPClient()), localLoader:
                                                                                                    LocalMovieLoader(store:
                                                                                                                        CodableMovieStore(storeURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableMovieStore.self)).store")),
                                                                                                                     currentDate: Date.init))
    
    static private var upcoming = MovieListObservable(remoteLoader: RemoteMovieLoader(endpoint: .upcoming,
                                                                                               client: URLSessionHTTPClient()), localLoader:
                                                                                                LocalMovieLoader(store:
                                                                                                                    CodableMovieStore(storeURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableMovieStore.self)).store")),
                                                                                                                 currentDate: Date.init))
    
    static private var topRated = MovieListObservable(remoteLoader: RemoteMovieLoader(endpoint: .topRated,
                                                                                               client: URLSessionHTTPClient()), localLoader:
                                                                                                LocalMovieLoader(store:
                                                                                                                    CodableMovieStore(storeURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableMovieStore.self)).store")),
                                                                                                                 currentDate: Date.init))
    
    static private var popular = MovieListObservable(remoteLoader: RemoteMovieLoader(endpoint: .popular,
                                                                                              client: URLSessionHTTPClient()), localLoader:
                                                                                                LocalMovieLoader(store:
                                                                                                                    CodableMovieStore(storeURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: CodableMovieStore.self)).store")),
                                                                                                                 currentDate: Date.init))

    static var previews: some View {
        MovieListView(nowPlaying: nowPlaying, upcoming: upcoming, topRated: topRated, popular: popular)
    }
}
