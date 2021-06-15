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
    private let currentDate: () -> Date

    init(store: MovieStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [Movie]) {
        store.deleteCacheMovie { [unowned self] error in
            if error == nil {
                store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class MovieStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCacheMovieCount = 0
    var insertCallCount = 0
    var insertions = [(items: [Movie], timestamp: Date)]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCacheMovie(completion: @escaping DeletionCompletion) {
        deleteCacheMovieCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [Movie], timestamp: Date) {
        insertCallCount += 1
        insertions.append((items, timestamp))
    }
}

class CacheMovieUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCacheMovieCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheMovieCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }

    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalMovieLoader, store: MovieStore) {
        let store = MovieStore()
        let sut = LocalMovieLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, store)
    }
    
    private func uniqueItem() -> Movie {
        
        return Movie(id: anyInt(), title: "Bloodshot", backdropPath: "\\/ocUrMYbdjknu2TwzMHKT9PBBQRw.jpg", posterPath: "\\/8WUVHemHFH2ZIP6NWkwlHWsyrEL.jpg", overview: "", voteAverage: 7.1, voteCount: 418, runtime: nil, releaseDate: "2020-03-05", genres: nil, credits: nil, videos: nil)
    }
    
    private func anyInt() -> Int {
        return [338762, 336845, 338482].randomElement()!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
