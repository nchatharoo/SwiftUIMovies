//
//  URLSessionHTTPClient.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 05/05/2021.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let apiKey = "427837424ba8a780babbc727c4b55918"
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    public func getMovies(from endpoint: MovieListEndpoint, completion: @escaping (HTTPClient.Result) -> Void) {
        guard let url = URL(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            return
        }
        loadURL(url: url, completion: completion)
    }
    
    public func getMovie(with id: Int, completion: @escaping (HTTPClient.Result) -> Void) {
        loadURL(url: URL(string: "\(baseAPIURL)/movie/\(id)")!, completion: completion)
    }
    
    private func loadURL(url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        let params: [String: String] = [
            "append_to_response": "videos,credits"
        ]
        queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        
        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else {
            return
        }
        session.dataTask(with: finalURL) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
