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
    
    func test_retrieve_HasNoSideEffectOnEmptyCache() {
        let sut = CodableMovieStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                
                switch (firstResult, secondResult) {
                
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
            
        }
        wait(for: [exp], timeout: 1.0)
    }
}
