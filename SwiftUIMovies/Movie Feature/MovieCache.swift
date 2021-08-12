//
//  MovieCache.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 12/08/2021.
//

import Foundation

public protocol MovieCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ movies: [Movie], completion: @escaping (MovieCache.Result) -> Void)
}
