//
//  Movie.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 04/05/2021.
//

import Foundation

public struct Movie: Decodable, Equatable {
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
    
    public static func == (lhs: Movie, rhs: Movie) -> Bool {
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
    
    static private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    
    var genreText: String {
        genres?.first?.name ?? "n/a"
    }
    
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "★"
        }
        return ratingText
    }
    
    var scoreText: String {
        guard ratingText.count > 0 else {
            return "n/a"
        }
        return "\(ratingText.count)/10"
    }
    
    var yearText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"

        guard let releaseDate = self.releaseDate, let date = dateFormatter.date(from: releaseDate) else {
            return "n/a"
        }
        return Movie.yearFormatter.string(from: date)
    }
    
    var durationText: String {
        guard let runtime = self.runtime, runtime > 0 else {
            return "n/a"
        }
        return Movie.durationFormatter.string(from: TimeInterval(runtime) * 60) ?? "n/a"
    }
    
    var cast: [MovieCast]? {
        credits?.cast
    }
    
    var crew: [MovieCrew]? {
        credits?.crew
    }
    
    var directors: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "director" }
    }
    
    var producers: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "producer" }
    }
    
    var screenWriters: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "story" }
    }
    
    var youtubeTrailers: [MovieVideo]? {
        videos?.results.filter { $0.youtubeURL != nil }
    }
    
}

public struct MovieGenre: Decodable {
    public init(name: String) {
        self.name = name
    }
    public let name: String
}

public struct MovieCredit: Decodable {
    public init(cast: [MovieCast], crew: [MovieCrew]) {
        self.cast = cast
        self.crew = crew
    }
    
    
    public let cast: [MovieCast]
    public let crew: [MovieCrew]
}

public struct MovieCast: Decodable {
    public init(id: Int, character: String, name: String) {
        self.id = id
        self.character = character
        self.name = name
    }
    
    public let id: Int
    public let character: String
    public let name: String
}

public struct MovieCrew: Decodable {
    public init(id: Int, job: String, name: String) {
        self.id = id
        self.job = job
        self.name = name
    }
    
    public let id: Int
    public let job: String
    public let name: String
}

public struct MovieVideoResponse: Decodable {
    public init(results: [MovieVideo]) {
        self.results = results
    }
    
    
    public let results: [MovieVideo]
}

public struct MovieVideo: Decodable {
    public init(id: String, key: String, name: String, site: String) {
        self.id = id
        self.key = key
        self.name = name
        self.site = site
    }
    
    public let id: String
    public let key: String
    public let name: String
    public let site: String
    
    var youtubeURL: URL? {
        guard site == "YouTube" else {
            return nil
        }
        return URL(string: "https://youtube.com/watch?v=\(key)")
    }
}
