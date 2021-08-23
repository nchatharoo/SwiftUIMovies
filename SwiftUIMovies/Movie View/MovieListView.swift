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
