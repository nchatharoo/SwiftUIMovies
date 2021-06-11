//
//  RemoteMovieLoader.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 03/05/2021.
//

import Foundation

public final class RemoteMovieLoader {
    public let endpoint: MovieListEndpoint
    public let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public enum LoadMovieResult: Equatable {
        case success([Movie])
        case failure(Error)
    }
    
    public init(endpoint: MovieListEndpoint, client: HTTPClient) {
        self.endpoint = endpoint
        self.client = client
    }
    
    public func loadMovies(completion: @escaping (LoadMovieResult) -> Void) {
        client.getMovies(from: endpoint) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteMovieLoader.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    public func loadMovie(id: Int, completion: @escaping (LoadMovieResult) -> Void) {
        client.getMovie(with: id) { result in
            switch result {
            case let .success(data, response):
                completion(RemoteMovieLoader.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> LoadMovieResult {
        do {
            let items = try MovieItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error as! RemoteMovieLoader.Error)
        }
    }
}

final class MovieItemsMapper {
    private struct Root: Decodable {
        let results: [Movie]
    }
    
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
       
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Movie] {
       guard response.statusCode == 200, let root = try? jsonDecoder.decode(Root.self, from: data) else {
        throw RemoteMovieLoader.Error.invalidData
       }
       return root.results
   }
}

private extension Array where Element == Movie {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, title: $0.title, backdropPath: $0.backdropPath, posterPath: $0.posterPath, overview: $0.overview, voteAverage: $0.voteAverage, voteCount: $0.voteCount, runtime: $0.runtime, releaseDate: $0.releaseDate, genres: $0.genres, credits: $0.credits, videos: $0.videos)}
    }
}
