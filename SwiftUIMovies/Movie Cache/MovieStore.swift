//
//  MovieStore.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 15/06/2021.
//

import Foundation

public protocol MovieStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCacheMovie(completion: @escaping DeletionCompletion)
    
    func insert(_ items: [Movie], timestamp: Date, completion: @escaping InsertionCompletion)
}
