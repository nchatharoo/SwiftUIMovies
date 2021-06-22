//
//  CodableMovieStoreTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 18/06/2021.
//

import XCTest
import SwiftUIMovies

class CodableMovieStore {
    func retrieve(completion: @escaping MovieStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableMovieStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableMovieStore()
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
