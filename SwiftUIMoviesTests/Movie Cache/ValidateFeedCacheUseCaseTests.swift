//
//  ValidateFeedCacheUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 17/06/2021.
//

import XCTest
import SwiftUIMoviesiOS

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
                
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheMovie])
    }
    
    func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
                
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: movie.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: movie.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheMovie])
    }
    
    func test_validateCache_deletesCacheExpired() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: movie.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheMovie])
    }
    
    func test_validateCache_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = MovieStoreSpy()
        var sut: LocalMovieLoader? = LocalMovieLoader(store: store, currentDate: Date.init)
        
        let receivedResults = [LocalMovieLoader.LoadResult]()
        
        sut?.validateCache()

        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }

    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalMovieLoader, store: MovieStoreSpy) {
        let store = MovieStoreSpy()
        let sut = LocalMovieLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
}
