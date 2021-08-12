//
//  LoadMovieFromCacheUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 16/06/2021.
//

import XCTest
import SwiftUIMoviesiOS

class LoadMovieFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoMoviesOnEmptyCache() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedMoviesOnNonExpiredCache() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredOldTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(movie.models), when: {
            store.completeRetrieval(with: movie.local, timestamp: nonExpiredOldTimestamp)
        })
    }
    
    func test_load_deliversNoMoviesOnCacheExpiration() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: movie.local, timestamp: expirationTimestamp)
        })
    }
    
    func test_load_deliversNoMoviesOnExpiredCache() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: movie.local, timestamp: expiredTimestamp)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
                
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: movie.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: movie.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let movie = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusMoviesCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: movie.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = MovieStoreSpy()
        var sut: LocalMovieLoader? = LocalMovieLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalMovieLoader.LoadResult]()
        
        sut?.load { receivedResults.append($0) }

        sut = nil
        store.completeRetrievalWithEmptyCache()
        
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
    
    private func expect(_ sut: LocalMovieLoader, toCompleteWith expectedResult: LocalMovieLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedMovies), .success(expectedMovies)):
                XCTAssertEqual(receivedMovies, expectedMovies, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
