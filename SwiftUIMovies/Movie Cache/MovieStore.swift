//
//  MovieStore.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 15/06/2021.
//

import Foundation

public enum CachedMovie {
    case empty
    case found(movies: [LocalMovieItem], timestamp: Date)
}

public protocol MovieStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalResult = Result<CachedMovie, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalMovieItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
