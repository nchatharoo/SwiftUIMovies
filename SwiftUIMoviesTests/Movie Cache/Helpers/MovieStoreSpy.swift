//
//  MovieStoreSpy.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 16/06/2021.
//

import Foundation
import SwiftUIMoviesiOS

class MovieStoreSpy: MovieStore {
    enum ReceivedMessage: Equatable {
        case deleteCacheMovie
        case insert([LocalMovieItem], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [MovieStore.DeletionCompletion]()
    private var insertionCompletions = [MovieStore.InsertionCompletion]()
    private var retrievalCompletions = [MovieStore.RetrievalCompletion]()

    func deleteCachedMovies(completion: @escaping MovieStore.DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheMovie)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ items: [LocalMovieItem], timestamp: Date, completion: @escaping MovieStore.InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping MovieStore.RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with movies: [LocalMovieItem], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CachedMovie(movies: movies, timestamp: timestamp)))
    }
}
