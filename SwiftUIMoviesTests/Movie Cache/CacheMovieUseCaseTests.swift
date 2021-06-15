//
//  CacheMovieUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 14/06/2021.
//

import XCTest
import SwiftUIMovies

class LocalMovieLoader {
    private let store: MovieStore
    
    init(store: MovieStore) {
        self.store = store
    }
    
    func save(_ items: [Movie]) {
        store.deleteCacheMovie()
    }
}

class MovieStore {
    var deleteCacheMovieCount = 0
    
    func deleteCacheMovie() {
        deleteCacheMovieCount += 1
    }
}

class CacheMovieUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = MovieStore()
        _ = LocalMovieLoader(store: store)
        XCTAssertEqual(store.deleteCacheMovieCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = MovieStore()
        let sut = LocalMovieLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheMovieCount, 1)
    }
    
    //MARK: - Helpers
    
    private func uniqueItem() -> Movie {
        
        return Movie(id: anyInt(), title: "Bloodshot", backdropPath: "\\/ocUrMYbdjknu2TwzMHKT9PBBQRw.jpg", posterPath: "\\/8WUVHemHFH2ZIP6NWkwlHWsyrEL.jpg", overview: "", voteAverage: 7.1, voteCount: 418, runtime: nil, releaseDate: "2020-03-05", genres: nil, credits: nil, videos: nil)
    }
    
    private func anyInt() -> Int {
        return [338762, 336845, 338482].randomElement()!
    }
}
