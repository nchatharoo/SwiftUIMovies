//
//  SceneDelegate.swift
//  SwiftUIMoviesiOS
//
//  Created by Nadheer on 12/08/2021.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    @ObservedObject private var nowPlaying = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .nowPlaying, client: URLSessionHTTPClient()))
    
    @ObservedObject private var upcoming = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .upcoming, client: URLSessionHTTPClient()))
    
    @ObservedObject private var topRated = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .topRated, client: URLSessionHTTPClient()))
    
    @ObservedObject private var popular = MovieListObservable(movieLoader: RemoteMovieLoader(endpoint: .popular, client: URLSessionHTTPClient()))

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let movieListView = MovieListView(nowPlaying: nowPlaying, upcoming: upcoming, topRated: topRated, popular: popular)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: movieListView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
