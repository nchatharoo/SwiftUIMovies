//
//  MovieDetailObservable.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 23/08/2021.
//

import Foundation

class MovieDetailObservable: ObservableObject {
    
    private let remoteLoader: MovieLoader
    
    @Published var movie: Movie?
    
    init(remoteLoader: MovieLoader) {
        self.remoteLoader = remoteLoader
    }
    
    func loadMovie(id: Int) {
        self.remoteLoader.loadMovie(id: id) { [weak self] (remote) in
            guard let self = self else { return }
            
            switch remote {
            case .success(let movie):
                DispatchQueue.main.async {
                    self.movie = movie
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
