//
//  LoadMovieFromRemoteUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 03/05/2021.
//

import XCTest

class RemoteMovieLoader {
    private let url: URL
    private let client: HTTPClientSpy
    
    init(url: URL, client: HTTPClientSpy) {
        self.url = url
        self.client = client
    }
}

class HTTPClientSpy {
    var requestedURLs = [Any]()
}

class LoadMovieFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMovieLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMovieLoader(url: url, client: client)
        return (sut, client)
    }

}
