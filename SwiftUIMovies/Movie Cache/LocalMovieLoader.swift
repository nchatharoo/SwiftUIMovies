//
//  LocalMovieLoader.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 15/06/2021.
//

import Foundation

public final class LocalMovieLoader {
    
    public typealias LoadMovieResult = MovieLoader.Result

    private let store: MovieStore
    private let currentDate: () -> Date
    
    public init(store: MovieStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalMovieLoader: MovieCache {
    public typealias SaveResult = Result<Void, Error>

    public func save(_ movies: [Movie], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedMovies { [weak self] deletionResult in
            guard let self = self else { return }
                        
            switch deletionResult {
            case .success():
                self.cache(movies, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ movies: [Movie], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(movies.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalMovieLoader: MovieLoader {
    public typealias LoadResult = MovieLoader.Result
    
    public func loadMovies(from endpoint: MovieListEndpoint, completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.some(cache)) where MovieCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.movies.toModels()))
                
            case .success:
                completion(.success([]))
            }
        }
    }
    
    public func loadMovie(id: Int, completion: @escaping (UniqueResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .success(.some(cache)):
                let item = self.filter(items: cache.movies.toModels(), for: id)
                completion(item)
                
            case .success(.none):
                completion(.success(nil))
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
                
            case let .success(.some(cache)) where !MovieCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedMovies { _ in }
                
            case .success: break
            }
        }
    }
    
    public func filter(items: [Movie], for id: Int) -> UniqueResult {
        if let item = items.filter({ id == $0.id }).first {
            return .success(Movie(id: item.id, title: item.title, backdropPath: item.backdropPath, posterPath: item.posterPath, overview: item.overview, voteAverage: item.voteAverage, voteCount: item.voteCount, runtime: item.runtime, releaseDate: item.releaseDate, genres: item.genres, credits: item.credits, videos: item.videos))
        } else {
            return .failure(NSError(domain: "no movie found", code: 0))
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
