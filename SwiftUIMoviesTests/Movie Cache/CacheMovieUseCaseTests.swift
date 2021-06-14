//
//  CacheMovieUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 14/06/2021.
//

import XCTest

class LocalMovieLoader {
    init(store: MovieStore) {
        
    }
}

class MovieStore {
    var deleteCacheMovieCount = 0
}

class CacheMovieUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = MovieStore()
        _ = LocalMovieLoader(store: store)
        XCTAssertEqual(store.deleteCacheMovieCount, 0)
    }

}
