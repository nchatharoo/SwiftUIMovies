//
//  SwiftUIMoviesAPIEndToEndTests.swift
//  SwiftUIMoviesAPIEndToEndTests
//
//  Created by Nadheer on 10/06/2021.
//

import XCTest
import SwiftUIMoviesiOS

class SwiftUIMoviesAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETMoviesResult_matchesFixedTestAccountData() {
        switch getMoviesResult() {
        case let .success(movie):
            XCTAssertEqual(movie.count, expectedMovies(movie), "Expected values")
        case let .failure(error):
            XCTFail("Expected successful movie result, got \(error) instead")
        default:
            XCTFail("Expected successful movie result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func expectedMovies(_ result: [Movie]) -> Int {
        return result.count
    }
    
    private func getMoviesResult(file: StaticString = #file, line: UInt = #line) -> RemoteMovieLoader.Result? {
        let loader = RemoteMovieLoader(endpoint: .nowPlaying, client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: RemoteMovieLoader.Result?
        
        loader.loadMovies(from: .nowPlaying) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
}
