//
//  MovieCoordinator.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import UIKit

/// Coordinator cho Movie flow
final class MovieCoordinator: BaseCoordinator {
    
    override func start() {
        showMovieList()
    }
    
    private func showMovieList() {
        // Tạo dependencies
        let repository = MovieRepository()
        let getPopularMoviesUseCase = GetPopularMoviesUseCase(repository: repository)
        
        // Tạo ViewController (View trong MVP)
        let viewController = MovieListViewController()
        
        // Tạo Presenter và inject dependencies
        let presenter = MovieListPresenter(
            view: viewController,
            getPopularMoviesUseCase: getPopularMoviesUseCase
        )
        viewController.presenter = presenter
        
        // Push vào navigation stack
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMovieDetail(movieId: Int) {
        // Tạo dependencies
        let repository = MovieRepository()
        let getMovieDetailUseCase = GetMovieDetailUseCase(repository: repository)
        
        // Tạo ViewController
        let viewController = MovieDetailViewController()
        
        // Tạo Presenter và inject dependencies
        let presenter = MovieDetailPresenter(
            view: viewController,
            getMovieDetailUseCase: getMovieDetailUseCase,
            movieId: movieId
        )
        viewController.presenter = presenter
        
        // Push vào navigation stack
        navigationController.pushViewController(viewController, animated: true)
    }
}

