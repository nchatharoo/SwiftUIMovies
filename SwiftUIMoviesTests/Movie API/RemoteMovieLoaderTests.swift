//
//  LoadMovieFromRemoteUseCaseTests.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 03/05/2021.
//

import XCTest
import SwiftUIMoviesiOS

class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private var messagesID = [(id: Int, completion: (HTTPClient.Result) -> Void)]()
    
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func getMovies(from endpoint: MovieListEndpoint, completion: @escaping (HTTPClient.Result) -> Void) {
        guard let url = URL(string: "\("https://api.themoviedb.org/3")/movie/\(endpoint.rawValue)") else {
            return
        }
        messages.append((url, completion))
    }
    
    func getMovie(with id: Int, completion: @escaping (HTTPClient.Result) -> Void) {
        messagesID.append((id, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0, and id: Int) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messagesID[index].completion(.success((data, response)))
    }
}

class RemoteMovieLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteMovieLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach{ index, code in
            expect(sut, toCompleteWith: .failure(RemoteMovieLoader.Error.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteMovieLoader.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
                let emptyListJSON = Data("{\"results\": []}".utf8)
                client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: 338762, title: "Bloodshot", backdropPath: "\\/ocUrMYbdjknu2TwzMHKT9PBBQRw.jpg", posterPath: "\\/8WUVHemHFH2ZIP6NWkwlHWsyrEL.jpg", overview: "After he and his wife are murdered, marine Ray Garrison is resurrected by a team of scientists. Enhanced with nanotechnology, he becomes a superhuman, biotech killing machine???'Bloodshot'. As Ray first trains with fellow super-soldiers, he cannot recall anything from his former life. But when his memories flood back and he remembers the man that killed both him and his wife, he breaks out of the facility to get revenge, only to discover that there's more to the conspiracy than he thought.", voteAverage: 7.1, voteCount: 418, runtime: nil, releaseDate: "2020-03-05", genres: nil, credits: nil, videos: nil)
        
        let item2 = makeItem(id: 618344, title: "Justice League Dark: Apokolips War", backdropPath: "\\/sQkRiQo3nLrQYMXZodDjNUJKHZV.jpg", posterPath: "\\/c01Y4suApJ1Wic2xLmaq1QYcfoZ.jpg", overview: "Earth is decimated after intergalactic tyrant Darkseid has devastated the Justice League in a poorly executed war by the DC Super Heroes. Now the remaining bastions of good ??? the Justice League, Teen Titans, Suicide Squad and assorted others ??? must regroup, strategize and take the war to Darkseid in order to save the planet and its surviving inhabitants.", voteAverage: 8.5, voteCount: 418, runtime: nil, releaseDate: "2020-05-05", genres: nil, credits: nil, videos: nil)
        
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func testDoesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let endpoint = MovieListEndpoint.nowPlaying
        let id = 338762
        let client = HTTPClientSpy()
        var sut: RemoteMovieLoader? = RemoteMovieLoader(endpoint: endpoint, client: client)
        
        var capturedResults = [RemoteMovieLoader.Result]()
        var capturedUniqueResult = [MovieLoader.UniqueResult]()

        sut?.loadMovies(from: endpoint) { capturedResults.append($0) }
        sut?.loadMovie(id: id) { capturedUniqueResult.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItemsForMovieID() {
        let (sut, client) = makeSUT()
        var capturedUniqueResult = [MovieLoader.UniqueResult]()

        let item1 = makeItem(id: 338762, title: "Bloodshot", backdropPath: "\\/ocUrMYbdjknu2TwzMHKT9PBBQRw.jpg", posterPath: "\\/8WUVHemHFH2ZIP6NWkwlHWsyrEL.jpg", overview: "", voteAverage: 7.1, voteCount: 418, runtime: nil, releaseDate: "2020-03-05", genres: nil, credits: nil, videos: nil)
        
        let items = [item1.model]
        sut.loadMovie(id: items.first!.id) { capturedUniqueResult.append($0) }
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }

    // MARK: - Helpers
    
    private func makeSUT(endpoint: MovieListEndpoint = .nowPlaying, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMovieLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMovieLoader(endpoint: endpoint, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteMovieLoader, toCompleteWith expectedResult: RemoteMovieLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadMovies(from: .nowPlaying) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteMovieLoader.Error), .failure(expectedError as RemoteMovieLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: Int, title: String, backdropPath: String?, posterPath: String?, overview: String, voteAverage: Double, voteCount: Int, runtime: Int?, releaseDate: String?, genres: [MovieGenre]?, credits: MovieCredit?, videos: MovieVideoResponse?) -> (model: Movie, json: [String: Any]) {
        let item = Movie(id: id, title: title, backdropPath: backdropPath, posterPath: posterPath, overview: overview, voteAverage: voteAverage, voteCount: voteCount, runtime: runtime, releaseDate: releaseDate, genres: genres, credits: credits, videos: videos)
        
        let json: [String: Any] = [
            "id": item.id,
            "title": item.title,
            "backdropPath": item.backdropPath ?? "",
            "posterPath": item.posterPath ?? "",
            "overview": item.overview,
            "voteAverage": item.voteAverage,
            "voteCount": item.voteCount,
            "runtime": item.runtime ?? 0,
            "releaseDate": item.releaseDate ?? "",
            "genres": item.genres ?? [],
            "credits": item.credits ?? nil,
            "videos": item.videos ?? nil
        ].mapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
