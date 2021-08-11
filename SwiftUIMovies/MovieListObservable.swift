//
//  MovieListObservable.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 09/08/2021.
//

import SwiftUI
import Combine

class MovieListObservable: ObservableObject {
    
    @Published var movies = [Movie]()

    private let movieLoader: MovieLoader

    init(movieLoader: MovieLoader) {
        self.movieLoader = movieLoader
    }
    
    func loadMovies(with endpoint: MovieListEndpoint) {
        self.movieLoader.loadMovies { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.movies = data
                    }
                case .failure: break
            }
        }
    }
}
