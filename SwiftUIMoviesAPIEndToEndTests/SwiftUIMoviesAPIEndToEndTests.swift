//
//  SwiftUIMoviesAPIEndToEndTests.swift
//  SwiftUIMoviesAPIEndToEndTests
//
//  Created by Nadheer on 10/06/2021.
//

import XCTest
import SwiftUIMovies

class SwiftUIMoviesAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETMoviesResult_matchesFixedTestAccountData() {
        switch getMoviesResult() {
        case let .success(movie):
            movie.enumerated().forEach { (index, item) in
                XCTAssertEqual(item, expectedMovie(at: index), "Unexpected values at index \(index)")
            }
        case let .failure(error):
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func expectedMovie(at index: Int) -> Movie {
        
        let item = makeItem(id: 337404, title: "Cruella", backdropPath: "\\/6MKr3KgOLmzOP6MSuZERO41Lpkt.jpg", posterPath: "\\/rTh4K5uw9HypmpGslcKd4QfHl93.jpg", overview: "In 1970s London amidst the punk rock revolution, a young grifter named Estella is determined to make a name for herself with her designs. She befriends a pair of young thieves who appreciate her appetite for mischief, and together they are able to build a life for themselves on the London streets. One day, Estella’s flair for fashion catches the eye of the Baroness von Hellman, a fashion legend who is devastatingly chic and terrifyingly haute. But their relationship sets in motion a course of events and revelations that will cause Estella to embrace her wicked side and become the raucous, fashionable and revenge-bent Cruella.", voteAverage: 8.7, voteCount: 2359, runtime: nil, releaseDate: "2021-05-26", genres: nil, credits: nil, videos: nil).model
        
        return item
    }
    
    private func makeItem(id: Int, title: String, backdropPath: String?, posterPath: String?, overview: String, voteAverage: Double, voteCount: Int, runtime: Int?, releaseDate: String?, genres: [MovieGenre]?, credits: MovieCredit?, videos: MovieVideoResponse?) -> (model: Movie, json: [String: Any]) {
        let item = Movie(id: id, title: title, backdropPath: backdropPath, posterPath: posterPath, overview: overview, voteAverage: voteAverage, voteCount: voteCount, runtime: runtime, releaseDate: releaseDate, genres: genres, credits: credits, videos: videos)
        
        let json = [
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
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func getMoviesResult(file: StaticString = #file, line: UInt = #line) -> RemoteMovieLoader.LoadMovieResult? {
        let loader = RemoteMovieLoader(endpoint: .nowPlaying, client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: RemoteMovieLoader.LoadMovieResult?
        
        loader.loadMovies { result in
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
