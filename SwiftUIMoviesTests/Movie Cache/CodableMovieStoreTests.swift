//
//  CodableMovieStoreTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 18/06/2021.
//

import XCTest
import SwiftUIMovies

class CodableMovieStore {
    private struct Cache: Codable {
        let movies: [CodableMovieItem]
        let timestamp: Date
        
        var localMovies: [LocalMovieItem] {
            return movies.map { $0.local }
        }
    }
    
    private struct CodableMovieItem: Equatable, Codable {
        public let id: Int
        public let title: String
        public let backdropPath: String?
        public let posterPath: String?
        public let overview: String
        public let voteAverage: Double
        public let voteCount: Int
        public let runtime: Int?
        public let releaseDate: String?
        
        public let genres: [MovieGenre]?
        public let credits: MovieCredit?
        public let videos: MovieVideoResponse?
        
        init(_ movie: LocalMovieItem) {
            self.id = movie.id
            self.title = movie.title
            self.backdropPath = movie.backdropPath
            self.posterPath = movie.posterPath
            self.overview = movie.overview
            self.voteAverage = movie.voteAverage
            self.voteCount = movie.voteCount
            self.runtime = movie.runtime
            self.releaseDate = movie.releaseDate
            self.genres = movie.genres
            self.credits = movie.credits
            self.videos = movie.videos
        }
        
        static func == (lhs: CodableMovieItem, rhs: CodableMovieItem) -> Bool {
            lhs.id == rhs.id
        }
        
        var local: LocalMovieItem {
            return LocalMovieItem(id: id, title: title, backdropPath: backdropPath, posterPath: posterPath, overview: overview, voteAverage: voteAverage, voteCount: voteCount, runtime: runtime, releaseDate: releaseDate, genres: genres, credits: credits, videos: videos)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retrieve(completion: @escaping MovieStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(movies: cache.localMovies, timestamp: cache.timestamp))
    }
    
    func insert(_ movies: [LocalMovieItem], timestamp: Date, completion: @escaping MovieStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(movies: movies.map(CodableMovieItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }

}

class CodableMovieStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_HasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let movie = uniqueItems().local
        let timestamp = Date()

        insert((movie, timestamp), to: sut)
        expect(sut, toRetrieve: .found(movies: movie, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let movies = uniqueItems().local
        let timestamp = Date()
        
        insert((movies, timestamp), to: sut)
        expect(sut, toRetrieve: .found(movies: movies, timestamp: timestamp))
    }
    
    //MARK - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableMovieStore {
        let sut = CodableMovieStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableMovieStore, toRetrieve expectedResult: RetrieveCachedMovieResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            
            case (.empty, .empty):
                break
                
            case let (.found(expected), (.found(retrieved))):
                XCTAssertEqual(retrieved.movies, expected.movies)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp)
            
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableMovieStore, toRetrieveTwice expectedResult: RetrieveCachedMovieResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func insert(_ cache: (movies: [LocalMovieItem], timestamp: Date), to sut: CodableMovieStore) {
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.movies, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected movies to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
