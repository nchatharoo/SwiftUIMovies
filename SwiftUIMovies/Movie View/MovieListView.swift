//
//  MovieListView.swift
//  SwiftUIMovies
//
//  Created by Nadheer on 09/08/2021.
//

import SwiftUI
import UIKit

struct MovieListView: View {
    
    @ObservedObject private var nowPlaying = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .nowPlaying, client: URLSessionHTTPClient()))
    
    @ObservedObject private var upcoming = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .upcoming, client: URLSessionHTTPClient()))
    
    @ObservedObject private var topRated = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .topRated, client: URLSessionHTTPClient()))
    
    @ObservedObject private var popular = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .popular, client: URLSessionHTTPClient()))


    var body: some View {
        
        NavigationView {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Now Playing", movies: nowPlaying.movies)
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Upcoming", movies: upcoming.movies)
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Top Rated", movies: topRated.movies)
                    }
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        MoviePosterScrollView(title: "Popular", movies: popular.movies)
                    }
                }
                .padding()
                
            }
            .navigationBarTitle("The MovieDb")
        }
        .onAppear {
            nowPlaying.loadMovies(with: .nowPlaying)
            upcoming.loadMovies(with: .upcoming)
            topRated.loadMovies(with: .topRated)
            popular.loadMovies(with: .popular)
        }
    }
}

struct MoviePosterScrollView: View {
    
    let title: String
    let movies: [Movie]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(movies, id: \.self.id) { movie in
                        MoviePosterView(movie: movie)
                    }
                }
            }
        }
    }
}

struct MoviePosterView: View {
    
    let movie: Movie
    @ObservedObject var imageLoader = ImageLoader()

    var body: some View {
        ZStack {
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                
                Text(movie.title)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 204, height: 306)
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}

private let _imageCache = NSCache<AnyObject, AnyObject>()

class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    @Published var isLoading = false
    
    var imageCache = _imageCache

    func loadImage(with url: URL) {
        let urlString = url.absoluteString
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    return
                }
                self.imageCache.setObject(image, forKey: urlString as AnyObject)
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
