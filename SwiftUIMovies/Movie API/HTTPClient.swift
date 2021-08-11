//
//  HTTPClient.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 06/05/2021.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func getMovies(from endpoint: MovieListEndpoint, completion: @escaping (Result) -> Void)
    func getMovie(with id: Int, completion: @escaping (Result) -> Void)
}
