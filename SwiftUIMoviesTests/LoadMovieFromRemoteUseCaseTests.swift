//
//  LoadMovieFromRemoteUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 03/05/2021.
//

import XCTest
import SwiftUIMovies

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestedURL = url
        requestedURLs.append(url)
    }
    var requestedURL: URL?
    var requestedURLs = [URL]()
}

class LoadMovieFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFRomURL() {
        let (sut, client) = makeSUT()
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    
    func test_loadTwice_requestsDataFRomURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()

        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMovieLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, client: client)
        return (sut, client)
    }

}
