//
//  MoviePresenter.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

/// Protocol cho Movie View
protocol MovieViewProtocol: ViewProtocol {
    func displayMovies(_ movies: [MovieEntity])
    func displayMovieDetail(_ movie: MovieEntity)
    func displayEmptyState()
}

/// Presenter cho Movie List Screen
final class MovieListPresenter: BasePresenter<MovieViewProtocol> {
    private let getPopularMoviesUseCase: GetPopularMoviesUseCase
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var movies: [MovieEntity] = []
    
    init(
        view: MovieViewProtocol,
        getPopularMoviesUseCase: GetPopularMoviesUseCase
    ) {
        self.getPopularMoviesUseCase = getPopularMoviesUseCase
        super.init(view: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovies()
    }
    
    func loadMovies() {
        Task { @MainActor in
            view?.showLoading()
            do {
                let input = GetPopularMoviesInput(page: currentPage)
                let output = try await getPopularMoviesUseCase.execute(input: input)
                
                if currentPage == 1 {
                    movies = output.movies
                } else {
                    movies.append(contentsOf: output.movies)
                }
                
                totalPages = output.totalPages
                currentPage = output.currentPage
                
                if movies.isEmpty {
                    view?.displayEmptyState()
                } else {
                    view?.displayMovies(movies)
                }
            } catch {
                view?.showError(message: error.localizedDescription)
            }
            view?.hideLoading()
        }
    }
    
    func loadMoreMovies() {
        guard currentPage < totalPages else { return }
        currentPage += 1
        loadMovies()
    }
    
    func refreshMovies() {
        currentPage = 1
        movies.removeAll()
        loadMovies()
    }
}

/// Presenter cho Movie Detail Screen
final class MovieDetailPresenter: BasePresenter<MovieViewProtocol> {
    private let getMovieDetailUseCase: GetMovieDetailUseCase
    private let movieId: Int
    
    init(
        view: MovieViewProtocol,
        getMovieDetailUseCase: GetMovieDetailUseCase,
        movieId: Int
    ) {
        self.getMovieDetailUseCase = getMovieDetailUseCase
        self.movieId = movieId
        super.init(view: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovieDetail()
    }
    
    func loadMovieDetail() {
        Task { @MainActor in
            view?.showLoading()
            do {
                let input = GetMovieDetailInput(id: movieId)
                let output = try await getMovieDetailUseCase.execute(input: input)
                view?.displayMovieDetail(output.movie)
            } catch {
                view?.showError(message: error.localizedDescription)
            }
            view?.hideLoading()
        }
    }
}

