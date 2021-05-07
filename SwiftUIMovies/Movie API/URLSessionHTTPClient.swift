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
    private let apiKey = "FAKEAPIKEY"
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    public func getMovies(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        loadURL(url: url, completion: completion)
    }
    
    public func getMovie(with id: Int, completion: @escaping (HTTPClientResult) -> Void) {
        loadURL(url: URL(string: "\(baseAPIURL)/movie/\(id)")!, completion: completion)
    }
    
    private func loadURL(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        
        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else {
            return
        }
        session.dataTask(with: finalURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
