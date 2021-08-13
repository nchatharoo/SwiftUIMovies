//
//  MovieLoader.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 17/06/2021.
//

import Foundation

public protocol MovieLoader {
    typealias Result = Swift.Result<[Movie], Error>
    func loadMovies(from endpoint: MovieListEndpoint, completion: @escaping (Result) -> Void)
    func loadMovie(id: Int, completion: @escaping (Result) -> Void)
}
