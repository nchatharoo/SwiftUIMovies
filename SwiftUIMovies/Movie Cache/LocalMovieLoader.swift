//
//  LocalMovieLoader.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 15/06/2021.
//

import Foundation

public final class LocalMovieLoader {
    
    public typealias LoadMovieResult = Result<[Movie], Error>

    private let store: MovieStore
    private let currentDate: () -> Date
    
    public init(store: MovieStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalMovieLoader {
    public typealias SaveResult = Error?

    public func save(_ items: [Movie], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedMovies { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [Movie], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalMovieLoader {
    public typealias LoadResult = LoadMovieResult

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(movies, timestamp) where MovieCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(movies.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalMovieLoader {
    public func validateCache() {
        self.store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedMovies { _ in }
                
            case let .found(_, timestamp) where !MovieCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedMovies { _ in }
                
            case .empty, .found: break
            }
        }
    }
}


private extension Array where Element == Movie {
    func toLocal() -> [LocalMovieItem] {
        return map { LocalMovieItem(id: $0.id, title: $0.title, backdropPath: $0.backdropPath, posterPath: $0.posterPath, overview: $0.overview, voteAverage: $0.voteAverage, voteCount: $0.voteCount, runtime: $0.runtime, releaseDate: $0.releaseDate, genres: $0.genres, credits: $0.credits, videos: $0.videos)
        }
    }
}

private extension Array where Element == LocalMovieItem {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, title: $0.title, backdropPath: $0.backdropPath, posterPath: $0.posterPath, overview: $0.overview, voteAverage: $0.voteAverage, voteCount: $0.voteCount, runtime: $0.runtime, releaseDate: $0.releaseDate, genres: $0.genres, credits: $0.credits, videos: $0.videos)
        }
    }
}
