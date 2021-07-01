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
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("movie.store")

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
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("movie.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("movie.store")
        try? FileManager.default.removeItem(at: storeURL)

    }

    
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
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableMovieStore()
        let movie = uniqueItems().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(movie, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected movie to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedMovie, retrievedTimestamp):
                    XCTAssertEqual(retrievedMovie, movie)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected found result with \(movie) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
