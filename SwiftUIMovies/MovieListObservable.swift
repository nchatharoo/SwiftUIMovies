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

    private let remoteLoader: MovieLoader
    private let localLoader: MovieCache & MovieLoader

    init(remoteLoader: MovieLoader, localLoader: MovieLoader & MovieCache) {
        self.remoteLoader = remoteLoader
        self.localLoader = localLoader
    }
    
    func loadMovies(from endpoint: MovieListEndpoint) {
        self.remoteLoader.loadMovies(from: endpoint) { result in
            switch result {
            
            case .success(let remote):
                DispatchQueue.main.async {
                    self.movies = remote
                }
                self.localLoader.save(remote, completion: { _ in })
                
            case .failure:
                self.localLoader.loadMovies(from: endpoint) { result in
                    switch result {
                    case .success(let local):
                        DispatchQueue.main.async {
                            self.movies = local
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
