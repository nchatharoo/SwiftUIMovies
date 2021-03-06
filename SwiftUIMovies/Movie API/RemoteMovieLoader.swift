//
//  RemoteMovieLoader.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 03/05/2021.
//

import Foundation

public final class RemoteMovieLoader: MovieLoader {
    public let endpoint: MovieListEndpoint
    public let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public typealias Result = MovieLoader.Result
        
    public init(endpoint: MovieListEndpoint, client: HTTPClient) {
        self.endpoint = endpoint
        self.client = client
    }
    
    public func loadMovies(from endpoint: MovieListEndpoint, completion: @escaping (Result) -> Void) {
        client.getMovies(from: endpoint) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteMovieLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    public func loadMovie(id: Int, completion: @escaping (UniqueResult) -> Void) {
        client.getMovie(with: id) { result in
            switch result {
            case let .success((data, response)):
                completion(RemoteMovieLoader.decode(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try MovieItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error as! RemoteMovieLoader.Error)
        }
    }
    
    private static func decode(_ data: Data, from response: HTTPURLResponse) -> UniqueResult {
        do {
            let item = try MovieItemsMapper.decode(data, from: response)
            return .success(Movie(id: item.id, title: item.title, backdropPath: item.backdropPath, posterPath: item.posterPath, overview: item.overview, voteAverage: item.voteAverage, voteCount: item.voteCount, runtime: item.runtime, releaseDate: item.releaseDate, genres: item.genres, credits: item.credits, videos: item.videos))
        } catch {
            return .failure(error as! RemoteMovieLoader.Error)
        }
    }
}

private extension Array where Element == RemoteMovieItem {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, title: $0.title, backdropPath: $0.backdropPath, posterPath: $0.posterPath, overview: $0.overview, voteAverage: $0.voteAverage, voteCount: $0.voteCount, runtime: $0.runtime, releaseDate: $0.releaseDate, genres: $0.genres, credits: $0.credits, videos: $0.videos)
        }
    }
}

final class MovieItemsMapper {
    private struct Root: Decodable {
        let results: [RemoteMovieItem]
    }
    
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
       
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteMovieItem] {
       guard response.statusCode == 200, let root = try? jsonDecoder.decode(Root.self, from: data) else {
        throw RemoteMovieLoader.Error.invalidData
       }
       return root.results
   }
    
    static func decode(_ data: Data, from response: HTTPURLResponse) throws -> RemoteMovieItem {
       guard response.statusCode == 200, let remoteMovieItem = try? jsonDecoder.decode(RemoteMovieItem.self, from: data) else {
        throw RemoteMovieLoader.Error.invalidData
       }
        return remoteMovieItem
   }
}

private extension Array where Element == Movie {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, title: $0.title, backdropPath: $0.backdropPath, posterPath: $0.posterPath, overview: $0.overview, voteAverage: $0.voteAverage, voteCount: $0.voteCount, runtime: $0.runtime, releaseDate: $0.releaseDate, genres: $0.genres, credits: $0.credits, videos: $0.videos)
        }
    }
}
