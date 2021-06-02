//
//  MovieListEndpoint.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 02/06/2021.
//

import Foundation

public enum MovieListEndpoint: String, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case nowPlaying = "now_playing"
    case upcoming
    case topRated = "top_rated"
    case popular
    
    var description: String {
        switch self {
            case .nowPlaying: return "Now Playing"
            case .upcoming: return "Upcoming"
            case .topRated: return "Top Rated"
            case .popular: return "Popular"
        }
    }
}
