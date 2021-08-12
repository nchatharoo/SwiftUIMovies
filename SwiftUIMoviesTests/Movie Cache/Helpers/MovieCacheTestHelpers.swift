//
//  MovieCacheTestHelpers.swift
//  SwiftUIMoviesTests
//
//  Created by Nadheer on 17/06/2021.
//

import Foundation
import SwiftUIMoviesiOS

func uniqueItem() -> Movie {
    
    return Movie(id: anyInt(), title: "Bloodshot", backdropPath: "\\/ocUrMYbdjknu2TwzMHKT9PBBQRw.jpg", posterPath: "\\/8WUVHemHFH2ZIP6NWkwlHWsyrEL.jpg", overview: "", voteAverage: 7.1, voteCount: 418, runtime: nil, releaseDate: "2020-03-05", genres: nil, credits: nil, videos: nil)
}

func anyInt() -> Int {
    return [338762, 336845, 338482].randomElement()!
}

func uniqueItems() -> (models: [Movie], local: [LocalMovieItem]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalMovieItem(id: $0.id, title: $0.title, backdropPath: $0.backdropPath, posterPath: $0.posterPath, overview: $0.overview, voteAverage: $0.voteAverage, voteCount: $0.voteCount, runtime: $0.runtime, releaseDate: $0.releaseDate, genres: $0.genres, credits: $0.credits, videos: $0.videos) }
    return (models, local)
}

extension Date {
    
    func minusMoviesCacheMaxAge() -> Date {
        return adding(days: -moviesCacheMaxAgeInDays)
    }
    
    private var moviesCacheMaxAgeInDays: Int {
        return 7
    }

    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
