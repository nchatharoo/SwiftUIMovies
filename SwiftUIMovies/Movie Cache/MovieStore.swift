//
//  MovieStore.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 15/06/2021.
//

import Foundation

public protocol MovieStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCacheMovie(completion: @escaping DeletionCompletion)
    
    func insert(_ items: [LocalMovieItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalMovieItem: Equatable {
    
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
