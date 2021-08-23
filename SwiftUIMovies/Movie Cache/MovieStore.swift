//
//  MovieStore.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 15/06/2021.
//

import Foundation

public typealias CachedMovies = (movies: [LocalMovieItem], timestamp: Date)

public protocol MovieStore {
    typealias DeletionResult = Result<Void,Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void,Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Result<CachedMovies?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalMovieItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
