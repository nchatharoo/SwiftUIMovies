//
//  RemoteMovieItem.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 16/06/2021.
//

import Foundation

internal struct RemoteMovieItem: Decodable {
    internal let id: Int
    internal let title: String
    internal let backdropPath: String?
    internal let posterPath: String?
    internal let overview: String
    internal let voteAverage: Double
    internal let voteCount: Int
    internal let runtime: Int?
    internal let releaseDate: String?
    
    internal let genres: [MovieGenre]?
    internal let credits: MovieCredit?
    internal let videos: MovieVideoResponse?
}
