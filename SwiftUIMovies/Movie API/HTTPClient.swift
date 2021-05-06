//
//  HTTPClient.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 06/05/2021.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func getMovies(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    func getMovie(with id: Int, completion: @escaping (HTTPClientResult) -> Void)
}
