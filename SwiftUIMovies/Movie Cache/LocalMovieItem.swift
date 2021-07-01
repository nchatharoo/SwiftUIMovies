//
//  LocalMovieItem.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 16/06/2021.
//

import Foundation

public struct LocalMovieItem: Equatable, Codable {
    
    public init(id: Int, title: String, backdropPath: String?, posterPath: String?, overview: String, voteAverage: Double, voteCount: Int, runtime: Int?, releaseDate: String?, genres: [MovieGenre]?, credits: MovieCredit?, videos: MovieVideoResponse?) {
        self.id = id
        self.title = title
        self.backdropPath = backdropPath
        self.posterPath = posterPath
        self.overview = overview
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.releaseDate = releaseDate
        self.genres = genres
        self.credits = credits
        self.videos = videos
    }
    
    public static func == (lhs: LocalMovieItem, rhs: LocalMovieItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    public let title: String
    public let backdropPath: String?
    public let posterPath: String?
    public let overview: String
    public let voteAverage: Double
    public let voteCount: Int
    public let runtime: Int?
    public let releaseDate: String?
    
    public let genres: [MovieGenre]?
    public let credits: MovieCredit?
    public let videos: MovieVideoResponse?
}
